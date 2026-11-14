import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_permission_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_access_sheet.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  testWidgets('mostra estado real e revalida após revisão de acessos', (
    tester,
  ) async {
    final gateway = _Permissions();
    await tester.pumpWidget(
      DayToDayApp(
        home: Scaffold(body: AlarmAccessSheet(permissions: gateway)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('precisa de acesso'), findsNWidgets(4));
    expect(gateway.requests, 0);
    await tester.ensureVisible(find.text('Revisar acessos no Android'));
    await tester.tap(find.text('Revisar acessos no Android'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 1);
    expect(find.text('Notificações: liberado'), findsOneWidget);
    expect(find.textContaining('precisa de acesso'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro de leitura não aparece como acesso liberado', (
    tester,
  ) async {
    final gateway = _Permissions()..fail = true;
    await tester.pumpWidget(
      DayToDayApp(
        home: Scaffold(body: AlarmAccessSheet(permissions: gateway)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Não foi possível verificar'), findsOneWidget);
    expect(find.textContaining(': liberado'), findsNothing);
    gateway.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 0);
    expect(find.textContaining('precisa de acesso'), findsNWidgets(4));
  });
}

final class _Permissions implements AlarmPermissionGateway {
  bool fail = false;
  int requests = 0;
  @override
  Future<AlarmCapabilities> check() async {
    if (fail) throw StateError('fixture');
    return AlarmCapabilities(
      notifications: requests > 0,
      exactScheduling: requests > 0,
      fullScreen: requests > 0,
      doNotDisturbAccess: requests > 0,
    );
  }

  @override
  Future<AlarmCapabilities> requestRequiredAccess() async {
    requests++;
    return check();
  }
}
