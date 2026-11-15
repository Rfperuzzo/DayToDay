import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/iana_time_zone_service.dart';

void main() {
  test('GMT e UTC preservam o instante sem impedir inicialização', () {
    final instant = DateTime.utc(2026, 11, 14, 12, 30);
    for (final identifier in ['GMT', 'UTC']) {
      final zone = IanaTimeZoneService.fromIdentifier(identifier);
      final local = zone.toLocal(instant);
      expect(local.hour, 12);
      expect(local.minute, 30);
      expect(zone.localComponentsToUtc(local), instant);
    }
  });

  test('fuso IANA continua usando o deslocamento real', () {
    final zone = IanaTimeZoneService.fromIdentifier('America/Sao_Paulo');
    final local = zone.toLocal(DateTime.utc(2026, 11, 14, 12));
    expect(local.hour, 9);
    expect(
      zone.localComponentsToUtc(DateTime(2026, 11, 14, 9)),
      DateTime.utc(2026, 11, 14, 12),
    );
  });

  test('identificador desconhecido não vira UTC silenciosamente', () {
    expect(
      () => IanaTimeZoneService.fromIdentifier('Invalid/Unknown'),
      throwsA(isA<Exception>()),
    );
  });
}
