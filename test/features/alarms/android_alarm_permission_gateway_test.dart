import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/android_alarm_permission_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const native = MethodChannel(
    'com.senhoritajhenifer.rotina/alarm_permissions',
  );
  const plugin = MethodChannel('flutter.baseflow.com/permissions/methods');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() => messenger.setMockMethodCallHandler(plugin, (_) async => 1));
  tearDown(() {
    messenger.setMockMethodCallHandler(plugin, null);
    messenger.setMockMethodCallHandler(native, null);
  });
  test(
    'acesso exato negado solicita somente uma tela especial e mantém estado negado',
    () async {
      final requests = <String>[];
      messenger.setMockMethodCallHandler(native, (call) async {
        if (call.method == 'canScheduleExactAlarms') return false;
        if (call.method == 'canUseFullScreenIntent') return false;
        requests.add(call.method);
        return null;
      });
      final state = await const AndroidAlarmPermissionGateway()
          .requestRequiredAccess();
      expect(requests, ['requestExactAlarms']);
      expect(state.exactScheduling, false);
      expect(state.fullyOperational, false);
    },
  );
  test('acesso exato já autorizado não abre solicitação novamente', () async {
    final requests = <String>[];
    messenger.setMockMethodCallHandler(native, (call) async {
      if (call.method.startsWith('can')) return true;
      requests.add(call.method);
      return null;
    });
    final state = await const AndroidAlarmPermissionGateway()
        .requestRequiredAccess();
    expect(requests, isEmpty);
    expect(state.fullyOperational, true);
  });
}
