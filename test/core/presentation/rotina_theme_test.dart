import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/presentation/rotina_theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  test('papéis de texto mantêm contraste na paleta acolhedora', () {
    final colors = RotinaTheme.light.colorScheme;
    for (final pair in [
      (colors.onPrimary, colors.primary),
      (colors.onPrimaryContainer, colors.primaryContainer),
      (colors.onSecondary, colors.secondary),
      (colors.onSurface, colors.surface),
      (colors.onSurfaceVariant, colors.surfaceContainer),
      (colors.onTertiaryContainer, colors.tertiaryContainer),
      (colors.onError, colors.error),
    ]) {
      expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
    }
  });

  test('widget nativo usa os mesmos papéis de superfície e ação', () {
    Color solid(String name) {
      final xml = File(
        'android/app/src/main/res/drawable/$name.xml',
      ).readAsStringSync();
      final match = RegExp(
        r'<solid android:color="#([A-Fa-f0-9]{6})"',
      ).firstMatch(xml)!;
      return Color(0xFF000000 | int.parse(match[1]!, radix: 16));
    }

    expect(solid('widget_background'), RotinaColors.primary);
    expect(solid('widget_task_background'), RotinaColors.background);
  });
}
