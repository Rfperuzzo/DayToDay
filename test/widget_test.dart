import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  testWidgets('inicializa sem interface de produto', (tester) async {
    await tester.pumpWidget(const RotinaJheniferApp());

    expect(tester.takeException(), isNull);
  });
}
