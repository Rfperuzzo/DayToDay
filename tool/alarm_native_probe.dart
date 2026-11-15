// Opt-in AVD harness. Never imported by lib/main.dart; uses only probe alarm IDs.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('DayToDay — ensaio nativo sintético')),
      ),
    ),
  );
  final file = File(
    '/data/user/0/com.senhoritajhenifer.rotina/files/daytoday-native-probe.wav',
  );
  await file.writeAsBytes(_tone());
  await Alarm.init(acknowledgeEventsAutomatically: false);
  const ids = [910001, 910002, 910003, 910004];
  for (final id in ids) {
    await Alarm.stop(id);
  }
  final rings = <int>{};
  final subscription = Alarm.ringing.listen((set) {
    final current = set.alarms.map((a) => a.id).toList();
    rings.addAll(current);
    debugPrint('DAYTODAY_NATIVE_RING ${jsonEncode(current)}');
  });
  Future<void> pair(int first, int second, {bool manualStop = false}) async {
    final at = DateTime.now().add(const Duration(seconds: 8));
    for (final id in [first, second]) {
      final ok = await Alarm.set(
        alarmSettings: AlarmSettings(
          id: id,
          dateTime: manualStop && id == second
              ? at.add(const Duration(seconds: 2))
              : at,
          assetAudioPath: file.path,
          loopAudio: false,
          vibrate: true,
          warningNotificationOnKill: false,
          androidFullScreenIntent: false,
          allowAlarmOverlap: false,
          allowSameSecondScheduling: true,
          androidStopAlarmOnTermination: false,
          volumeSettings: VolumeSettings.fixed(
            volume: 0.1,
            volumeEnforced: false,
          ),
          notificationSettings: NotificationSettings(
            title: 'Ensaio DayToDay $id',
            body: 'Dados sintéticos do AVD',
            stopButton: 'Parar alarme',
          ),
        ),
      );
      if (!ok) throw StateError('Schedule refused $id');
    }
    if (manualStop) {
      await Future<void>.delayed(
        at.difference(DateTime.now()) + const Duration(milliseconds: 1150),
      );
      await Alarm.stop(first);
      debugPrint('DAYTODAY_NATIVE_MANUAL_STOP $first');
      await Future<void>.delayed(const Duration(seconds: 6));
    } else {
      await Future<void>.delayed(const Duration(seconds: 15));
    }
  }

  try {
    await pair(ids[0], ids[1]);
    final phase1 = (await Alarm.getAlarms())
        .where((a) => ids.take(2).contains(a.id))
        .map((a) => a.id)
        .toList();
    await pair(ids[2], ids[3], manualStop: true);
    final remaining = (await Alarm.getAlarms())
        .where((a) => ids.contains(a.id))
        .map((a) => a.id)
        .toList();
    final result = {
      'rings': rings.toList()..sort(),
      'phase1Remaining': phase1,
      'remaining': remaining,
      'passed':
          ids.every(rings.contains) && phase1.isEmpty && remaining.isEmpty,
    };
    await File(
      '/data/user/0/com.senhoritajhenifer.rotina/files/daytoday-native-probe.json',
    ).writeAsString(jsonEncode(result));
    debugPrint('DAYTODAY_NATIVE_RESULT ${jsonEncode(result)}');
  } finally {
    for (final id in ids) {
      await Alarm.stop(id);
    }
    await subscription.cancel();
  }
}

Uint8List _tone() {
  const rate = 16000, samples = 19200;
  final bytes = ByteData(44 + samples * 2);
  void ascii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      bytes.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + samples * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, rate, Endian.little);
  bytes.setUint32(28, rate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, samples * 2, Endian.little);
  for (var i = 0; i < samples; i++) {
    final envelope = math.min(1.0, math.min(i / 300, (samples - i) / 300));
    bytes.setInt16(
      44 + i * 2,
      (math.sin(2 * math.pi * 660 * i / rate) * 3000 * envelope).round(),
      Endian.little,
    );
  }
  return bytes.buffer.asUint8List();
}
