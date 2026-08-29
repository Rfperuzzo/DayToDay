import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../application/alarm_response_service.dart';
import '../domain/alarm_gateway.dart';
import 'alarm_screen.dart';

final class AlarmRouter extends ConsumerStatefulWidget {
  const AlarmRouter({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AlarmRouter> createState() => _AlarmRouterState();
}

final class _AlarmRouterState extends ConsumerState<AlarmRouter> {
  StreamSubscription<List<RingingAlarmBinding>>? _subscription;
  Timer? _missedTaskTimer;
  RingingAlarmBinding? _activeAlarm;
  RingingAlarmBinding? _pendingAlarm;
  AlarmResponseResult? _result;
  var _isResponding = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _subscription = ref
        .read(alarmGatewayProvider)
        .ringing
        .listen(
          _onRingingChanged,
          onError: (Object error, StackTrace stackTrace) {
            if (mounted) {
              setState(() {
                _errorMessage =
                    'Não foi possível acompanhar o estado do alarme.';
              });
            }
          },
        );
  }

  @override
  void dispose() {
    _missedTaskTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAlarm = _activeAlarm;
    if (activeAlarm == null) {
      return widget.child;
    }
    if (_result case final result?) {
      return AlarmResolvedScreen(
        title: activeAlarm.title,
        result: result,
        timeZone: ref.watch(timeZoneServiceProvider),
        onDone: _finishResolution,
      );
    }
    return AlarmRingingScreen(
      alarm: activeAlarm,
      isResponding: _isResponding,
      errorMessage: _errorMessage,
      onRespond: (response) => _respond(activeAlarm, response),
    );
  }

  void _onRingingChanged(List<RingingAlarmBinding> alarms) {
    if (!mounted) {
      return;
    }
    if (alarms.isEmpty) {
      _missedTaskTimer?.cancel();
      if (!_isResponding && _result == null && _activeAlarm != null) {
        setState(() {
          _activeAlarm = null;
          _errorMessage = null;
        });
      }
      return;
    }
    final first = alarms.first;
    if (_isResponding) {
      setState(() => _pendingAlarm = first);
      return;
    }
    if (_result != null) {
      _scheduleMissedTaskRecovery(first);
      setState(() {
        _activeAlarm = first;
        _result = null;
        _errorMessage = null;
      });
      return;
    }
    if (first.occurrenceId == _activeAlarm?.occurrenceId) {
      return;
    }
    _scheduleMissedTaskRecovery(first);
    setState(() {
      _activeAlarm = first;
      _errorMessage = null;
    });
  }

  Future<void> _respond(
    RingingAlarmBinding alarm,
    AlarmResponse response,
  ) async {
    _missedTaskTimer?.cancel();
    setState(() {
      _isResponding = true;
      _errorMessage = null;
    });
    try {
      final result = await ref
          .read(alarmResponseServiceProvider)
          .respond(occurrenceId: alarm.occurrenceId, response: response);
      if (!mounted) {
        return;
      }
      if (_pendingAlarm case final pending?) {
        _scheduleMissedTaskRecovery(pending);
        setState(() {
          _activeAlarm = pending;
          _pendingAlarm = null;
          _isResponding = false;
          _result = null;
        });
      } else {
        setState(() {
          _isResponding = false;
          _result = result;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isResponding = false;
          _errorMessage =
              'Não foi possível registrar a resposta. Tente novamente.';
        });
      }
    }
  }

  void _finishResolution() {
    if (_pendingAlarm case final pending?) {
      _scheduleMissedTaskRecovery(pending);
      setState(() {
        _activeAlarm = pending;
        _pendingAlarm = null;
        _result = null;
        _errorMessage = null;
      });
      return;
    }
    setState(() {
      _activeAlarm = null;
      _result = null;
      _errorMessage = null;
    });
  }

  void _scheduleMissedTaskRecovery(RingingAlarmBinding alarm) {
    _missedTaskTimer?.cancel();
    final duration = alarm.estimatedDuration;
    if (duration == null) {
      return;
    }
    final deadline = alarm.scheduledAtUtc.add(duration);
    final remaining = deadline.difference(DateTime.now().toUtc());
    _missedTaskTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () => unawaited(_recoverMissedTask(alarm)),
    );
  }

  Future<void> _recoverMissedTask(RingingAlarmBinding alarm) async {
    if (!mounted ||
        _isResponding ||
        _activeAlarm?.occurrenceId != alarm.occurrenceId) {
      return;
    }
    setState(() {
      _isResponding = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(missedTaskRecoveryServiceProvider)
          .recover(alarm.occurrenceId);
      if (mounted) {
        setState(() {
          _activeAlarm = null;
          _pendingAlarm = null;
          _result = null;
          _isResponding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isResponding = false;
          _errorMessage =
              'A tarefa perdeu o horário, mas não foi possível reorganizar a sequência.';
        });
      }
    }
  }
}
