import 'package:flutter/material.dart';

abstract final class RotinaColors {
  static const background = Color(0xFFFFF8F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFFFF0F1);
  static const surfaceStrong = Color(0xFFFFE1E4);
  static const primary = Color(0xFFBA0034);
  static const primaryBright = Color(0xFFE51245);
  static const primarySoft = Color(0xFFF4DCE4);
  static const text = Color(0xFF321017);
  static const textMuted = Color(0xFF6B5A60);
  static const outline = Color(0xFFE6BCBD);
  static const danger = Color(0xFFB3261E);
}

abstract final class RotinaTheme {
  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: RotinaColors.primary,
      brightness: Brightness.light,
      primary: RotinaColors.primary,
      surface: RotinaColors.surface,
      onSurface: RotinaColors.text,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colors);

    return base.copyWith(
      scaffoldBackgroundColor: RotinaColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: RotinaColors.text,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -0.8,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: RotinaColors.text,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: RotinaColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: RotinaColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: RotinaColors.textMuted,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: RotinaColors.textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: RotinaColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          side: BorderSide(color: RotinaColors.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: RotinaColors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: RotinaColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
