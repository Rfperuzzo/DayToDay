import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/presentation/new_activity_sheet.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_permission_gateway.dart';

void main() {
  testWidgets('não salva se o horário passar durante a liberação de acesso', (
    tester,
  ) async {
    final clock = _MutableClock(DateTime.utc(2026, 8, 29, 12));
    final permissions = _DelayedPermissionGateway(clock);
    var created = false;

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NewActivitySheet(
            initialDay: DateTime(2026, 8, 29),
            timeZone: const _UtcTimeZone(),
            permissions: permissions,
            clock: clock,
            onCreate: (_) async {
              created = true;
              throw StateError('A criação não deveria ser chamada.');
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Teste de alarme');
    final saveButton = find.text('Salvar e preparar alarme');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Ativar acesso'));
    await tester.pump(const Duration(seconds: 1));

    expect(created, isFalse);
    expect(
      find.text(
        'O horário passou enquanto os acessos eram liberados. Escolha um novo horário.',
      ),
      findsOneWidget,
    );
  });
}

final class _MutableClock implements Clock {
  _MutableClock(this.value);

  DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _DelayedPermissionGateway implements AlarmPermissionGateway {
  _DelayedPermissionGateway(this.clock);

  final _MutableClock clock;

  @override
  Future<AlarmCapabilities> check() async => const AlarmCapabilities(
    notifications: false,
    exactScheduling: true,
    fullScreen: false,
    doNotDisturbAccess: false,
  );

  @override
  Future<AlarmCapabilities> requestRequiredAccess() async {
    clock.value = DateTime.utc(2026, 8, 29, 12, 31);
    return const AlarmCapabilities(
      notifications: true,
      exactScheduling: true,
      fullScreen: true,
      doNotDisturbAccess: true,
    );
  }
}

final class _UtcTimeZone implements TimeZoneService {
  const _UtcTimeZone();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) => DateTime.utc(
    localComponents.year,
    localComponents.month,
    localComponents.day,
    localComponents.hour,
    localComponents.minute,
  );

  @override
  DateTime toLocal(DateTime utc) {
    final value = utc.toUtc();
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
    );
  }
}
