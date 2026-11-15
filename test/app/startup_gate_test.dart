import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/app/startup_gate.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  testWidgets('falha inicial pode ser recuperada sem reiniciar o processo', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      StartupGate(
        load: () async {
          attempts++;
          if (attempts == 1) throw StateError('detalhe privado');
          return const DayToDayApp(home: Scaffold(body: Text('Rotina pronta')));
        },
        shell: (child) => DayToDayApp(home: child),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('detalhe privado'), findsNothing);
    expect(find.text('Não foi possível iniciar o DayToDay.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Rotina pronta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rebuild não inicia duas cargas simultâneas', (tester) async {
    final completer = Completer<Widget>();
    var attempts = 0;
    Widget app() => StartupGate(
      load: () {
        attempts++;
        return completer.future;
      },
      shell: (child) => DayToDayApp(home: child),
    );
    await tester.pumpWidget(app());
    await tester.pumpWidget(app());
    expect(attempts, 1);
    expect(find.text('Abrindo sua rotina…'), findsOneWidget);
    completer.complete(const DayToDayApp(home: Scaffold(body: Text('Pronta'))));
    await tester.pumpAndSettle();
    expect(find.text('Pronta'), findsOneWidget);
  });
}
