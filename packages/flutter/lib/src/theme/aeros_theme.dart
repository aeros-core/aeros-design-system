import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';
import 'aeros_theme_extension.dart';

/// Aeros Material theme factories. Use these to seed `MaterialApp`.
class AerosTheme {
  AerosTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        aliases: AerosAliasColors.light,
        extension: AerosThemeExtension.light,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        aliases: AerosAliasColors.dark,
        extension: AerosThemeExtension.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required AerosAliasColors aliases,
    required AerosThemeExtension extension,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: aliases.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: aliases.brandPrimaryMuted,
      onPrimaryContainer: aliases.fgPrimary,
      secondary: AerosColors.ink600,
      onSecondary: Colors.white,
      secondaryContainer: aliases.bgSubtle,
      onSecondaryContainer: aliases.fgPrimary,
      tertiary: AerosColors.ink600,
      onTertiary: Colors.white,
      error: AerosColors.danger,
      onError: Colors.white,
      errorContainer: AerosColors.dangerBg,
      onErrorContainer: AerosColors.dangerText,
      surface: aliases.bgSurface,
      onSurface: aliases.fgPrimary,
      surfaceContainerLowest: aliases.bgSurface,
      surfaceContainerLow: aliases.bgCanvas,
      surfaceContainer: aliases.bgSubtle,
      surfaceContainerHigh: aliases.bgSubtle,
      surfaceContainerHighest: aliases.bgSubtle,
      onSurfaceVariant: aliases.fgSecondary,
      outline: aliases.borderDefault,
      outlineVariant: aliases.borderDefault,
      inverseSurface: aliases.bgInverse,
      onInverseSurface: aliases.fgInverse,
      inversePrimary: AerosColors.ink200,
      scrim: Colors.black54,
      shadow: const Color(0xFF0A0F2E),
    );

    final textTheme = AerosTypography.textTheme(
      fg: aliases.fgPrimary,
      fgMuted: aliases.fgMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: aliases.bgCanvas,
      canvasColor: aliases.bgSurface,
      dividerColor: aliases.borderDefault,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: AerosColors.ink900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AerosTypography.h4(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: aliases.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AerosRadii.brXl,
          side: BorderSide(color: aliases.borderDefault),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: aliases.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AerosTypography.bodyMd(color: AerosColors.ink200),
        labelStyle: AerosTypography.bodySm(color: aliases.fgSecondary).copyWith(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: AerosRadii.brMd,
          borderSide: BorderSide(color: aliases.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AerosRadii.brMd,
          borderSide: BorderSide(color: aliases.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AerosRadii.brMd,
          borderSide: BorderSide(color: aliases.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AerosRadii.brMd,
          borderSide: const BorderSide(color: AerosColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AerosRadii.brMd,
          borderSide: const BorderSide(color: AerosColors.danger, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: aliases.brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          minimumSize: const Size(0, 40),
          textStyle: AerosTypography.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: AerosRadii.brMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: aliases.fgPrimary,
          side: BorderSide(color: aliases.borderDefault),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          minimumSize: const Size(0, 40),
          textStyle: AerosTypography.bodyMd(color: aliases.fgPrimary).copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: AerosRadii.brMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: aliases.brandPrimary,
          textStyle: AerosTypography.bodyMd(color: aliases.brandPrimary).copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: const Size(0, 36),
          shape: const RoundedRectangleBorder(borderRadius: AerosRadii.brMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: aliases.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 20,
        shape: const RoundedRectangleBorder(borderRadius: AerosRadii.brXl),
        titleTextStyle: AerosTypography.h4(color: aliases.fgPrimary),
        contentTextStyle: AerosTypography.bodyMd(color: aliases.fgSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: aliases.bgInverse,
        contentTextStyle: AerosTypography.bodySm(color: aliases.fgInverse),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AerosRadii.brMd),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AerosColors.ink900,
          borderRadius: AerosRadii.brMd,
        ),
        textStyle: AerosTypography.caption(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      extensions: [extension],
    );
  }
}
