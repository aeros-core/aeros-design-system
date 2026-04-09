import 'package:flutter/material.dart';

/// Aeros color ramps and semantic colors.
/// Values mirror `packages/tokens/src/tokens.json` — do not edit by hand.
class AerosColors {
  AerosColors._();

  // ─── Royal (brand) ───
  static const Color royal50  = Color(0xFFEEF1FD);
  static const Color royal100 = Color(0xFFC5CEFA);
  static const Color royal200 = Color(0xFF9DAAED);
  static const Color royal400 = Color(0xFF5B78E8);
  static const Color royal600 = Color(0xFF2347D9);
  static const Color royal800 = Color(0xFF1A2F8A);
  static const Color royal900 = Color(0xFF0B1B6B);

  // ─── Ink (pure grey) ───
  static const Color ink50  = Color(0xFFF5F5F5);
  static const Color ink100 = Color(0xFFE5E5E5);
  static const Color ink200 = Color(0xFFC2C2C2);
  static const Color ink400 = Color(0xFF737373);
  static const Color ink600 = Color(0xFF404040);
  static const Color ink800 = Color(0xFF1A1A1A);
  static const Color ink900 = Color(0xFF0A0A0A);

  // ─── Slate (blue-grey) ───
  static const Color slate50  = Color(0xFFF5F6FA);
  static const Color slate100 = Color(0xFFE2E5F0);
  static const Color slate200 = Color(0xFFBCC2D8);
  static const Color slate400 = Color(0xFF7A85A8);
  static const Color slate600 = Color(0xFF4A5278);
  static const Color slate800 = Color(0xFF1E2540);
  static const Color slate900 = Color(0xFF0A0F2E);

  // ─── Semantic ───
  static const Color success       = Color(0xFF16A34A);
  static const Color successBg     = Color(0xFFDCFCE7);
  static const Color successText   = Color(0xFF15803D);
  static const Color successBorder = Color(0xFFBBF7D0);

  static const Color warning       = Color(0xFFD97706);
  static const Color warningBg     = Color(0xFFFEF3C7);
  static const Color warningText   = Color(0xFFB45309);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color danger        = Color(0xFFDC2626);
  static const Color dangerBg      = Color(0xFFFEE2E2);
  static const Color dangerText    = Color(0xFFB91C1C);
  static const Color dangerBorder  = Color(0xFFFECACA);

  static const Color info          = royal600;
  static const Color infoBg        = royal50;
  static const Color infoText      = royal800;
  static const Color infoBorder    = royal100;
}

/// Theme-aware aliases. Two instances: light / dark.
@immutable
class AerosAliasColors {
  const AerosAliasColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSubtle,
    required this.bgInverse,
    required this.fgPrimary,
    required this.fgSecondary,
    required this.fgMuted,
    required this.fgInverse,
    required this.fgBrand,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.brandPrimary,
    required this.brandPrimaryHover,
    required this.brandPrimaryMuted,
  });

  final Color bgCanvas, bgSurface, bgSubtle, bgInverse;
  final Color fgPrimary, fgSecondary, fgMuted, fgInverse, fgBrand;
  final Color borderDefault, borderStrong, borderFocus;
  final Color brandPrimary, brandPrimaryHover, brandPrimaryMuted;

  static const AerosAliasColors light = AerosAliasColors(
    bgCanvas: AerosColors.slate50,
    bgSurface: Colors.white,
    bgSubtle: AerosColors.slate50,
    bgInverse: AerosColors.slate900,
    fgPrimary: AerosColors.ink900,
    fgSecondary: AerosColors.ink600,
    fgMuted: AerosColors.ink400,
    fgInverse: Colors.white,
    fgBrand: AerosColors.royal600,
    borderDefault: AerosColors.slate100,
    borderStrong: AerosColors.slate200,
    borderFocus: AerosColors.royal400,
    brandPrimary: AerosColors.royal600,
    brandPrimaryHover: AerosColors.royal800,
    brandPrimaryMuted: AerosColors.royal50,
  );

  static const AerosAliasColors dark = AerosAliasColors(
    bgCanvas: AerosColors.ink900,
    bgSurface: AerosColors.slate900,
    bgSubtle: AerosColors.slate800,
    bgInverse: Colors.white,
    fgPrimary: Colors.white,
    fgSecondary: AerosColors.slate100,
    fgMuted: AerosColors.slate400,
    fgInverse: AerosColors.ink900,
    fgBrand: AerosColors.royal400,
    borderDefault: AerosColors.slate800,
    borderStrong: AerosColors.slate600,
    borderFocus: AerosColors.royal400,
    brandPrimary: AerosColors.royal400,
    brandPrimaryHover: AerosColors.royal200,
    brandPrimaryMuted: AerosColors.royal800,
  );
}
