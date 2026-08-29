import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/day_widget_gateway.dart';

final class AndroidDayWidgetGateway implements DayWidgetGateway {
  static const _channel = MethodChannel(
    'com.senhoritajhenifer.rotina/day_widget',
  );

  final _requests = StreamController<DayWidgetOpenRequest>.broadcast();
  String? _lastSnapshot;
  bool _initialized = false;

  @override
  Stream<DayWidgetOpenRequest> get openRequests => _requests.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openTask') {
        _emitRequest(call.arguments);
      }
    });
    try {
      final pending = await _channel.invokeMapMethod<String, Object?>(
        'takePendingTask',
      );
      _emitRequest(pending);
    } on MissingPluginException {
      // Widgets de tela inicial não existem fora do Android.
    } on PlatformException {
      // Uma falha do widget nunca impede o aplicativo de abrir.
    }
  }

  @override
  Future<void> update(DayWidgetBundle bundle) async {
    final encoded = jsonEncode(bundle.toJson());
    if (_lastSnapshot == encoded) {
      return;
    }
    _lastSnapshot = encoded;
    try {
      await _channel.invokeMethod<void>('updateDayWidget', encoded);
    } on MissingPluginException {
      // Sem integração nativa na plataforma atual.
    } on PlatformException {
      _lastSnapshot = null;
    }
  }

  @override
  Future<void> acknowledgeOpenRequest() async {
    try {
      await _channel.invokeMethod<void>('acknowledgePendingTask');
    } on MissingPluginException {
      // Sem integração nativa na plataforma atual.
    } on PlatformException {
      // A próxima abertura poderá tentar entregar novamente a solicitação.
    }
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _requests.close();
  }

  void _emitRequest(Object? raw) {
    if (raw is! Map) {
      return;
    }
    final occurrenceId = raw['occurrenceId'];
    final activityId = raw['activityId'];
    if (occurrenceId is! String ||
        occurrenceId.isEmpty ||
        activityId is! String ||
        activityId.isEmpty) {
      return;
    }
    _requests.add(
      DayWidgetOpenRequest(occurrenceId: occurrenceId, activityId: activityId),
    );
  }
}
