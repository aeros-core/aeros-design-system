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

  // Light: white card planes lift off a warmer canvas; elevation is carried by
  // soft shadow (see AerosShadows), not a second fill. Borders are true
  // hairlines.
  static const AerosAliasColors light = AerosAliasColors(
    bgCanvas: Color(0xFFF7F6F4),
    bgSurface: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFF1F0ED),
    bgInverse: Color(0xFF1A1916),
    fgPrimary: Color(0xFF1A1916),
    fgSecondary: Color(0xFF57554F),
    fgMuted: Color(0xFF73716B),
    fgInverse: Color(0xFFFFFFFF),
    fgBrand: Color(0xFF1A1916),
    borderDefault: Color(0xFFE4E2DD),
    borderStrong: Color(0xFFCECBC4),
    borderSubtle: Color(0xFFEEEDEA),
    borderFocus: Color(0xFF1A1916),
    brandPrimary: Color(0xFF1A1916),
    brandPrimaryHover: Color(0xFF403E39),
    brandPrimaryMuted: Color(0xFFF1F0ED),
    focusRing: Color(0xFF1A1916),
    focusRingOffset: Color(0xFFFFFFFF),
  );

  // Dark: lifted off near-black to a warm charcoal; a soft 4-tier ladder
  // (canvas -> surface -> elevated -> subtle) steps lighter since shadows
  // vanish on dark. Foreground is warm off-white, never pure white glare.
  static const AerosAliasColors dark = AerosAliasColors(
    bgCanvas: Color(0xFF1A1815),
    bgSurface: Color(0xFF221F1B),
    bgElevated: Color(0xFF2A2723),
    bgSubtle: Color(0xFF2F2C27),
    bgInverse: Color(0xFFFAFAF9),
    fgPrimary: Color(0xFFF5F3EF),
    fgSecondary: Color(0xFFC4C1BA),
    fgMuted: Color(0xFF9A978F),
    fgInverse: Color(0xFF1A1815),
    fgBrand: Color(0xFFF5F3EF),
    borderDefault: Color(0xFF332F2A),
    borderStrong: Color(0xFF46423B),
    borderSubtle: Color(0xFF2A2723),
    borderFocus: Color(0xFFF5F3EF),
    brandPrimary: Color(0xFFF5F3EF),
    brandPrimaryHover: Color(0xFFC4C1BA),
    brandPrimaryMuted: Color(0xFF2F2C27),
    focusRing: Color(0xFFF5F3EF),
    focusRingOffset: Color(0xFF1A1815),
  );
}
