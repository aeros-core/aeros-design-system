import 'package:flutter/material.dart';

/// Aeros color ramps and semantic colors.
/// Values mirror `packages/tokens/src/tokens.json` — keep in sync when the
/// ramp changes (the generated `aeros_tokens.dart` is the source of truth).
class AerosColors {
  AerosColors._();

  // ─── Royal (legacy alias — faint warm neutral) ───
  static const Color royal0   = Color(0xFFFFFFFF);
  static const Color royal50  = Color(0xFFFAFAF9);
  static const Color royal100 = Color(0xFFF4F4F2);
  static const Color royal200 = Color(0xFFE7E6E2);
  static const Color royal300 = Color(0xFFD6D4CF);
  static const Color royal400 = Color(0xFFA8A6A0);
  static const Color royal500 = Color(0xFF7C7A74);
  static const Color royal600 = Color(0xFF57554F);
  static const Color royal700 = Color(0xFF403E39);
  static const Color royal800 = Color(0xFF272622);
  static const Color royal900 = Color(0xFF1A1916);
  static const Color royal950 = Color(0xFF121110);

  // ─── Ink (faint warm neutral) ───
  static const Color ink0   = Color(0xFFFFFFFF);
  static const Color ink50  = Color(0xFFFAFAF9);
  static const Color ink100 = Color(0xFFF4F4F2);
  static const Color ink200 = Color(0xFFE7E6E2);
  static const Color ink300 = Color(0xFFD6D4CF);
  static const Color ink400 = Color(0xFFA8A6A0);
  static const Color ink500 = Color(0xFF7C7A74);
  static const Color ink600 = Color(0xFF57554F);
  static const Color ink700 = Color(0xFF403E39);
  static const Color ink800 = Color(0xFF272622);
  static const Color ink900 = Color(0xFF1A1916);
  static const Color ink950 = Color(0xFF121110);

  // ─── Slate (legacy alias — faint warm neutral) ───
  static const Color slate0   = Color(0xFFFFFFFF);
  static const Color slate50  = Color(0xFFFAFAF9);
  static const Color slate100 = Color(0xFFF4F4F2);
  static const Color slate200 = Color(0xFFE7E6E2);
  static const Color slate300 = Color(0xFFD6D4CF);
  static const Color slate400 = Color(0xFFA8A6A0);
  static const Color slate500 = Color(0xFF7C7A74);
  static const Color slate600 = Color(0xFF57554F);
  static const Color slate700 = Color(0xFF403E39);
  static const Color slate800 = Color(0xFF272622);
  static const Color slate900 = Color(0xFF1A1916);
  static const Color slate950 = Color(0xFF121110);

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
  static const Color infoBorder    = royal200;
}

/// Theme-aware aliases. Two instances: light / dark.
/// Layered surfaces (canvas → surface → elevated) carry depth without heavy
/// shadows; in dark mode each tier steps *lighter* since shadows vanish on near-black.
@immutable
class AerosAliasColors {
  const AerosAliasColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgSubtle,
    required this.bgInverse,
    required this.fgPrimary,
    required this.fgSecondary,
    required this.fgMuted,
    required this.fgInverse,
    required this.fgBrand,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSubtle,
    required this.borderFocus,
    required this.brandPrimary,
    required this.brandPrimaryHover,
    required this.brandPrimaryMuted,
    required this.focusRing,
    required this.focusRingOffset,
  });

  final Color bgCanvas, bgSurface, bgElevated, bgSubtle, bgInverse;
  final Color fgPrimary, fgSecondary, fgMuted, fgInverse, fgBrand;
  final Color borderDefault, borderStrong, borderSubtle, borderFocus;
  final Color brandPrimary, brandPrimaryHover, brandPrimaryMuted;
  final Color focusRing, focusRingOffset;

  static const AerosAliasColors light = AerosAliasColors(
    bgCanvas: AerosColors.ink50,
    bgSurface: AerosColors.ink0,
    bgElevated: AerosColors.ink0,
    bgSubtle: AerosColors.ink100,
    bgInverse: AerosColors.ink900,
    fgPrimary: AerosColors.ink900,
    fgSecondary: AerosColors.ink600,
    fgMuted: Color(0xFF6E6C66),
    fgInverse: AerosColors.ink0,
    fgBrand: AerosColors.ink900,
    borderDefault: AerosColors.ink200,
    borderStrong: AerosColors.ink300,
    borderSubtle: AerosColors.ink100,
    borderFocus: AerosColors.ink900,
    brandPrimary: AerosColors.ink900,
    brandPrimaryHover: AerosColors.ink700,
    brandPrimaryMuted: AerosColors.ink100,
    focusRing: AerosColors.ink900,
    focusRingOffset: AerosColors.ink0,
  );

  static const AerosAliasColors dark = AerosAliasColors(
    bgCanvas: AerosColors.ink950,
    bgSurface: AerosColors.ink900,
    bgElevated: Color(0xFF222220),
    bgSubtle: AerosColors.ink800,
    bgInverse: AerosColors.ink50,
    fgPrimary: AerosColors.ink50,
    fgSecondary: Color(0xFFC9C7C1),
    fgMuted: AerosColors.ink400,
    fgInverse: AerosColors.ink900,
    fgBrand: AerosColors.ink50,
    borderDefault: AerosColors.ink800,
    borderStrong: AerosColors.ink700,
    borderSubtle: Color(0xFF232220),
    borderFocus: AerosColors.ink50,
    brandPrimary: AerosColors.ink50,
    brandPrimaryHover: Color(0xFFC9C7C1),
    brandPrimaryMuted: AerosColors.ink800,
    focusRing: AerosColors.ink50,
    focusRingOffset: AerosColors.ink900,
  );
}
