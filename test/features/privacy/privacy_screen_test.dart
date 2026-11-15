import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/main.dart';
import 'package:rotina_jhenifer/features/privacy/presentation/privacy_screen.dart';

void main() {
  const channel = MethodChannel('com.senhoritajhenifer.rotina/privacy');
  testWidgets('política offline e contato acessíveis com texto 2x em 320dp', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(
      () => rootBundle.loadString('assets/legal/privacy_policy.md'),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const PrivacyScreen(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('thalesmelodasilva@gmail.com'), findsWidgets);
    expect(find.text('Política de privacidade — DayToDay'), findsOneWidget);
    await tester.ensureVisible(find.text('Conservação e exclusão'));
    await tester.pumpAndSettle();
    expect(find.textContaining('desativar atividades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('abrir política usa somente o método nativo previsto', (
    tester,
  ) async {
    String? method;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      method = call.method;
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.runAsync(
      () => rootBundle.loadString('assets/legal/privacy_policy.md'),
    );
    await tester.pumpWidget(const DayToDayApp(home: PrivacyScreen()));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir política pública'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(method, 'openPublicPolicy');
    expect(
      publicPrivacyPolicyUrl,
      'https://rfperuzzo.github.io/DayToDay/privacidade.html',
    );
  });
  testWidgets('sem navegador mantém a política e orienta copiar o link', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      _,
    ) async {
      throw PlatformException(code: 'no_browser');
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.runAsync(
      () => rootBundle.loadString('assets/legal/privacy_policy.md'),
    );
    await tester.pumpWidget(const DayToDayApp(home: PrivacyScreen()));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir política pública'));
    await tester.pump();
    expect(find.textContaining('Copie o link abaixo'), findsOneWidget);
    expect(find.text('Política de privacidade — DayToDay'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
