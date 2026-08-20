import 'package:flutter/material.dart';
import 'aeros_tokens.g.dart';

/// Aeros color ramps and semantic colors.
/// Every value aliases the generated [AerosTokens] constants (emitted from
/// `packages/tokens/src/tokens.json` by `pnpm build:tokens`) — the hand-drift
/// this file used to accumulate is structurally impossible now. CI rebuilds
/// tokens and fails if `aeros_tokens.g.dart` is stale.
class AerosColors {
  AerosColors._();

  // ─── Ink (faint warm neutral — the only ramp; royal/slate were deleted in 2.0) ───
  static const Color ink0   = AerosTokens.ink0;
  static const Color ink50  = AerosTokens.ink50;
  static const Color ink100 = AerosTokens.ink100;
  static const Color ink200 = AerosTokens.ink200;
  static const Color ink300 = AerosTokens.ink300;
  static const Color ink400 = AerosTokens.ink400;
  static const Color ink500 = AerosTokens.ink500;
  static const Color ink600 = AerosTokens.ink600;
  static const Color ink700 = AerosTokens.ink700;
  static const Color ink800 = AerosTokens.ink800;
  static const Color ink900 = AerosTokens.ink900;
  static const Color ink950 = AerosTokens.ink950;

  // ─── Semantic (light values — prefer AerosSemanticColors for theme-aware use) ───
  static const Color success       = AerosTokens.success;
  static const Color successBg     = AerosTokens.successBg;
  static const Color successText   = AerosTokens.successText;
  static const Color successBorder = AerosTokens.successBorder;

  static const Color warning       = AerosTokens.warning;
  static const Color warningBg     = AerosTokens.warningBg;
  static const Color warningText   = AerosTokens.warningText;
  static const Color warningBorder = AerosTokens.warningBorder;

  static const Color danger        = AerosTokens.danger;
  static const Color dangerBg      = AerosTokens.dangerBg;
  static const Color dangerText    = AerosTokens.dangerText;
  static const Color dangerBorder  = AerosTokens.dangerBorder;

  static const Color info          = AerosTokens.info;
  static const Color infoBg        = AerosTokens.infoBg;
  static const Color infoText      = AerosTokens.infoText;
  static const Color infoBorder    = AerosTokens.infoBorder;
}

/// Theme-aware status colors — light chips read wrong on dark surfaces, so
/// each tone carries a true dark counterpart (mirrors `semanticDark` in
/// tokens.json). Resolve via `context.aerosSemantic`.
@immutable
class AerosSemanticColors {
  const AerosSemanticColors({
    required this.success,
    required this.successBg,
    required this.successText,
    required this.successBorder,
    required this.warning,
    required this.warningBg,
    required this.warningText,
    required this.warningBorder,
    required this.danger,
    required this.dangerBg,
    required this.dangerText,
    required this.dangerBorder,
    required this.info,
    required this.infoBg,
    required this.infoText,
    required this.infoBorder,
  });

  final Color success, successBg, successText, successBorder;
  final Color warning, warningBg, warningText, warningBorder;
  final Color danger, dangerBg, dangerText, dangerBorder;
  final Color info, infoBg, infoText, infoBorder;

  static const AerosSemanticColors light = AerosSemanticColors(
    success: AerosTokens.success,
    successBg: AerosTokens.successBg,
    successText: AerosTokens.successText,
    successBorder: AerosTokens.successBorder,
    warning: AerosTokens.warning,
    warningBg: AerosTokens.warningBg,
    warningText: AerosTokens.warningText,
    warningBorder: AerosTokens.warningBorder,
    danger: AerosTokens.danger,
    dangerBg: AerosTokens.dangerBg,
    dangerText: AerosTokens.dangerText,
    dangerBorder: AerosTokens.dangerBorder,
    info: AerosTokens.info,
    infoBg: AerosTokens.infoBg,
    infoText: AerosTokens.infoText,
    infoBorder: AerosTokens.infoBorder,
  );

  static const AerosSemanticColors dark = AerosSemanticColors(
    success: AerosTokens.successDark,
    successBg: AerosTokens.successBgDark,
    successText: AerosTokens.successTextDark,
    successBorder: AerosTokens.successBorderDark,
    warning: AerosTokens.warningDark,
    warningBg: AerosTokens.warningBgDark,
    warningText: AerosTokens.warningTextDark,
    warningBorder: AerosTokens.warningBorderDark,
    danger: AerosTokens.dangerDark,
    dangerBg: AerosTokens.dangerBgDark,
    dangerText: AerosTokens.dangerTextDark,
    dangerBorder: AerosTokens.dangerBorderDark,
    info: AerosTokens.infoDark,
    infoBg: AerosTokens.infoBgDark,
    infoText: AerosTokens.infoTextDark,
    infoBorder: AerosTokens.infoBorderDark,
  );

  static AerosSemanticColors resolve(bool isDark) => isDark ? dark : light;
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
    bgCanvas: AerosTokens.aliasLightBgCanvas,
    bgSurface: AerosTokens.aliasLightBgSurface,
    bgElevated: AerosTokens.aliasLightBgElevated,
    bgSubtle: AerosTokens.aliasLightBgSubtle,
    bgInverse: AerosTokens.aliasLightBgInverse,
    fgPrimary: AerosTokens.aliasLightFgPrimary,
    fgSecondary: AerosTokens.aliasLightFgSecondary,
    fgMuted: AerosTokens.aliasLightFgMuted,
    fgInverse: AerosTokens.aliasLightFgInverse,
    fgBrand: AerosTokens.aliasLightFgBrand,
    borderDefault: AerosTokens.aliasLightBorderDefault,
    borderStrong: AerosTokens.aliasLightBorderStrong,
    borderSubtle: AerosTokens.aliasLightBorderSubtle,
    borderFocus: AerosTokens.aliasLightBorderFocus,
    brandPrimary: AerosTokens.aliasLightBrandPrimary,
    brandPrimaryHover: AerosTokens.aliasLightBrandPrimaryHover,
    brandPrimaryMuted: AerosTokens.aliasLightBrandPrimaryMuted,
    focusRing: AerosTokens.aliasLightFocusRing,
    focusRingOffset: AerosTokens.aliasLightFocusRingOffset,
  );

  static const AerosAliasColors dark = AerosAliasColors(
    bgCanvas: AerosTokens.aliasDarkBgCanvas,
    bgSurface: AerosTokens.aliasDarkBgSurface,
    bgElevated: AerosTokens.aliasDarkBgElevated,
    bgSubtle: AerosTokens.aliasDarkBgSubtle,
    bgInverse: AerosTokens.aliasDarkBgInverse,
    fgPrimary: AerosTokens.aliasDarkFgPrimary,
    fgSecondary: AerosTokens.aliasDarkFgSecondary,
    fgMuted: AerosTokens.aliasDarkFgMuted,
    fgInverse: AerosTokens.aliasDarkFgInverse,
    fgBrand: AerosTokens.aliasDarkFgBrand,
    borderDefault: AerosTokens.aliasDarkBorderDefault,
    borderStrong: AerosTokens.aliasDarkBorderStrong,
    borderSubtle: AerosTokens.aliasDarkBorderSubtle,
    borderFocus: AerosTokens.aliasDarkBorderFocus,
    brandPrimary: AerosTokens.aliasDarkBrandPrimary,
    brandPrimaryHover: AerosTokens.aliasDarkBrandPrimaryHover,
    brandPrimaryMuted: AerosTokens.aliasDarkBrandPrimaryMuted,
    focusRing: AerosTokens.aliasDarkFocusRing,
    focusRingOffset: AerosTokens.aliasDarkFocusRingOffset,
  );
}
