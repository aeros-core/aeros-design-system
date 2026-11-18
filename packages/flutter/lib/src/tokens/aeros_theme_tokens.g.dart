// Aeros Design Tokens — generated from packages/tokens/src/tokens.json. Do not edit.

import 'package:flutter/material.dart';

import 'aeros_tokens.g.dart';

/// Theme-aware status colors — light chips read wrong on dark surfaces, so
/// each tone carries a true dark counterpart (`semantic` / `semanticDark` in
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
    required this.dangerHover,
  });

  final Color success;
  final Color successBg;
  final Color successText;
  final Color successBorder;
  final Color warning;
  final Color warningBg;
  final Color warningText;
  final Color warningBorder;
  final Color danger;
  final Color dangerBg;
  final Color dangerText;
  final Color dangerBorder;
  final Color info;
  final Color infoBg;
  final Color infoText;
  final Color infoBorder;
  final Color dangerHover;

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
    dangerHover: AerosTokens.dangerHover,
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
    dangerHover: AerosTokens.dangerHoverDark,
  );

  static AerosSemanticColors resolve(bool isDark) => isDark ? dark : light;

  /// Interpolates every colour — theme changes animate instead of snapping.
  static AerosSemanticColors lerp(AerosSemanticColors a, AerosSemanticColors b, double t) => AerosSemanticColors(
        success: Color.lerp(a.success, b.success, t)!,
        successBg: Color.lerp(a.successBg, b.successBg, t)!,
        successText: Color.lerp(a.successText, b.successText, t)!,
        successBorder: Color.lerp(a.successBorder, b.successBorder, t)!,
        warning: Color.lerp(a.warning, b.warning, t)!,
        warningBg: Color.lerp(a.warningBg, b.warningBg, t)!,
        warningText: Color.lerp(a.warningText, b.warningText, t)!,
        warningBorder: Color.lerp(a.warningBorder, b.warningBorder, t)!,
        danger: Color.lerp(a.danger, b.danger, t)!,
        dangerBg: Color.lerp(a.dangerBg, b.dangerBg, t)!,
        dangerText: Color.lerp(a.dangerText, b.dangerText, t)!,
        dangerBorder: Color.lerp(a.dangerBorder, b.dangerBorder, t)!,
        info: Color.lerp(a.info, b.info, t)!,
        infoBg: Color.lerp(a.infoBg, b.infoBg, t)!,
        infoText: Color.lerp(a.infoText, b.infoText, t)!,
        infoBorder: Color.lerp(a.infoBorder, b.infoBorder, t)!,
        dangerHover: Color.lerp(a.dangerHover, b.dangerHover, t)!,
      );
}

/// Theme-aware aliases (`alias.light` / `alias.dark` in tokens.json).
/// Resolve via `context.aerosColors`.
@immutable
class AerosAliasColors {
  const AerosAliasColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgSubtle,
    required this.bgInset,
    required this.bgInverse,
    required this.fgPrimary,
    required this.fgSecondary,
    required this.fgMuted,
    required this.fgDisabled,
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
    required this.stateHover,
    required this.statePressed,
    required this.stateSelected,
    required this.scrim,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgSubtle;
  final Color bgInset;
  final Color bgInverse;
  final Color fgPrimary;
  final Color fgSecondary;
  final Color fgMuted;
  final Color fgDisabled;
  final Color fgInverse;
  final Color fgBrand;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderSubtle;
  final Color borderFocus;
  final Color brandPrimary;
  final Color brandPrimaryHover;
  final Color brandPrimaryMuted;
  final Color focusRing;
  final Color focusRingOffset;
  final Color stateHover;
  final Color statePressed;
  final Color stateSelected;
  final Color scrim;

  static const AerosAliasColors light = AerosAliasColors(
    bgCanvas: AerosTokens.aliasLightBgCanvas,
    bgSurface: AerosTokens.aliasLightBgSurface,
    bgElevated: AerosTokens.aliasLightBgElevated,
    bgSubtle: AerosTokens.aliasLightBgSubtle,
    bgInset: AerosTokens.aliasLightBgInset,
    bgInverse: AerosTokens.aliasLightBgInverse,
    fgPrimary: AerosTokens.aliasLightFgPrimary,
    fgSecondary: AerosTokens.aliasLightFgSecondary,
    fgMuted: AerosTokens.aliasLightFgMuted,
    fgDisabled: AerosTokens.aliasLightFgDisabled,
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
    stateHover: AerosTokens.aliasLightStateHover,
    statePressed: AerosTokens.aliasLightStatePressed,
    stateSelected: AerosTokens.aliasLightStateSelected,
    scrim: AerosTokens.aliasLightScrim,
  );

  static const AerosAliasColors dark = AerosAliasColors(
    bgCanvas: AerosTokens.aliasDarkBgCanvas,
    bgSurface: AerosTokens.aliasDarkBgSurface,
    bgElevated: AerosTokens.aliasDarkBgElevated,
    bgSubtle: AerosTokens.aliasDarkBgSubtle,
    bgInset: AerosTokens.aliasDarkBgInset,
    bgInverse: AerosTokens.aliasDarkBgInverse,
    fgPrimary: AerosTokens.aliasDarkFgPrimary,
    fgSecondary: AerosTokens.aliasDarkFgSecondary,
    fgMuted: AerosTokens.aliasDarkFgMuted,
    fgDisabled: AerosTokens.aliasDarkFgDisabled,
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
    stateHover: AerosTokens.aliasDarkStateHover,
    statePressed: AerosTokens.aliasDarkStatePressed,
    stateSelected: AerosTokens.aliasDarkStateSelected,
    scrim: AerosTokens.aliasDarkScrim,
  );

  static AerosAliasColors resolve(bool isDark) => isDark ? dark : light;

  /// Interpolates every colour — theme changes animate instead of snapping.
  static AerosAliasColors lerp(AerosAliasColors a, AerosAliasColors b, double t) => AerosAliasColors(
        bgCanvas: Color.lerp(a.bgCanvas, b.bgCanvas, t)!,
        bgSurface: Color.lerp(a.bgSurface, b.bgSurface, t)!,
        bgElevated: Color.lerp(a.bgElevated, b.bgElevated, t)!,
        bgSubtle: Color.lerp(a.bgSubtle, b.bgSubtle, t)!,
        bgInset: Color.lerp(a.bgInset, b.bgInset, t)!,
        bgInverse: Color.lerp(a.bgInverse, b.bgInverse, t)!,
        fgPrimary: Color.lerp(a.fgPrimary, b.fgPrimary, t)!,
        fgSecondary: Color.lerp(a.fgSecondary, b.fgSecondary, t)!,
        fgMuted: Color.lerp(a.fgMuted, b.fgMuted, t)!,
        fgDisabled: Color.lerp(a.fgDisabled, b.fgDisabled, t)!,
        fgInverse: Color.lerp(a.fgInverse, b.fgInverse, t)!,
        fgBrand: Color.lerp(a.fgBrand, b.fgBrand, t)!,
        borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
        borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
        borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
        borderFocus: Color.lerp(a.borderFocus, b.borderFocus, t)!,
        brandPrimary: Color.lerp(a.brandPrimary, b.brandPrimary, t)!,
        brandPrimaryHover: Color.lerp(a.brandPrimaryHover, b.brandPrimaryHover, t)!,
        brandPrimaryMuted: Color.lerp(a.brandPrimaryMuted, b.brandPrimaryMuted, t)!,
        focusRing: Color.lerp(a.focusRing, b.focusRing, t)!,
        focusRingOffset: Color.lerp(a.focusRingOffset, b.focusRingOffset, t)!,
        stateHover: Color.lerp(a.stateHover, b.stateHover, t)!,
        statePressed: Color.lerp(a.statePressed, b.statePressed, t)!,
        stateSelected: Color.lerp(a.stateSelected, b.stateSelected, t)!,
        scrim: Color.lerp(a.scrim, b.scrim, t)!,
      );
}

/// The type scale (`text` in tokens.json) as const styles.
///
/// Inter is a variable font: the glyph weight follows the `wght` axis, not
/// `fontWeight`, so every sans style pins both (and the `opsz` optical cut).
/// `overline` is uppercased by the caller (TextStyle has no transform).
class AerosTypeScale {
  AerosTypeScale._();

  static const TextStyle displayXl = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 48.0,
    fontWeight: FontWeight.w600,
    height: 1.0833,
    letterSpacing: -1.44,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    height: 1.1111,
    letterSpacing: -0.9,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.6,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3333,
    letterSpacing: -0.48,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.3,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.16,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.4286,
    letterSpacing: -0.07,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle titleLg = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: -0.16,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4286,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.5385,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4286,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 500.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 1.2308,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 500.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle labelXs = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.4545,
    letterSpacing: 0.11,
    fontVariations: [FontVariation('wght', 500.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle caption = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3333,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle overline = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.4545,
    letterSpacing: 0.66,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle monoLg = TextStyle(
    fontFamily: AerosTokens.fontMono,
    package: 'aeros_design_system',
    fontSize: 20.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
  );
  static const TextStyle monoMd = TextStyle(
    fontFamily: AerosTokens.fontMono,
    package: 'aeros_design_system',
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.5385,
    letterSpacing: 0.0,
  );
  static const TextStyle monoSm = TextStyle(
    fontFamily: AerosTokens.fontMono,
    package: 'aeros_design_system',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3333,
    letterSpacing: 0.0,
  );
  static const TextStyle monoXs = TextStyle(
    fontFamily: AerosTokens.fontMono,
    package: 'aeros_design_system',
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.4545,
    letterSpacing: 0.0,
  );
}

/// Shadows (`shadow` / `shadowDark` in tokens.json), parsed from the CSS values.
class AerosShadowTokens {
  AerosShadowTokens._();

  static const List<BoxShadow> xs = <BoxShadow>[
    BoxShadow(color: Color(0x0A0A0A0A), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
  ];
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: Color(0x0D0A0A0A), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
    BoxShadow(color: Color(0x0F0A0A0A), blurRadius: 3.0, offset: Offset(0.0, 1.0)),
  ];
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: Color(0x0D0A0A0A), blurRadius: 4.0, offset: Offset(0.0, 2.0)),
    BoxShadow(color: Color(0x120A0A0A), blurRadius: 12.0, offset: Offset(0.0, 4.0)),
  ];
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(color: Color(0x0F0A0A0A), blurRadius: 8.0, offset: Offset(0.0, 4.0)),
    BoxShadow(color: Color(0x170A0A0A), blurRadius: 24.0, offset: Offset(0.0, 12.0)),
  ];
  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(color: Color(0x120A0A0A), blurRadius: 16.0, offset: Offset(0.0, 8.0)),
    BoxShadow(color: Color(0x1F0A0A0A), blurRadius: 48.0, offset: Offset(0.0, 24.0)),
  ];
  static const List<BoxShadow> focus = <BoxShadow>[
    BoxShadow(color: Color(0x290A0A0A), blurRadius: 0.0, spreadRadius: 3.0),
  ];
  static const List<BoxShadow> focusDanger = <BoxShadow>[
    BoxShadow(color: Color(0x2EDC2626), blurRadius: 0.0, spreadRadius: 3.0),
  ];
  static const List<BoxShadow> hairline = <BoxShadow>[
    BoxShadow(color: Color(0x0F0A0A0A), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> focusSuccess = <BoxShadow>[
    BoxShadow(color: Color(0x2E16A34A), blurRadius: 0.0, spreadRadius: 3.0),
  ];

  static const List<BoxShadow> xsDark = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
    BoxShadow(color: Color(0x0DFFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> smDark = <BoxShadow>[
    BoxShadow(color: Color(0x73000000), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
    BoxShadow(color: Color(0x59000000), blurRadius: 4.0, offset: Offset(0.0, 2.0)),
    BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> mdDark = <BoxShadow>[
    BoxShadow(color: Color(0x73000000), blurRadius: 6.0, offset: Offset(0.0, 2.0)),
    BoxShadow(color: Color(0x66000000), blurRadius: 14.0, offset: Offset(0.0, 6.0)),
    BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> lgDark = <BoxShadow>[
    BoxShadow(color: Color(0x80000000), blurRadius: 12.0, offset: Offset(0.0, 4.0)),
    BoxShadow(color: Color(0x73000000), blurRadius: 28.0, offset: Offset(0.0, 12.0)),
    BoxShadow(color: Color(0x12FFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> xlDark = <BoxShadow>[
    BoxShadow(color: Color(0x8C000000), blurRadius: 20.0, offset: Offset(0.0, 8.0)),
    BoxShadow(color: Color(0x80000000), blurRadius: 48.0, offset: Offset(0.0, 20.0)),
    BoxShadow(color: Color(0x14FFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
  static const List<BoxShadow> focusDark = <BoxShadow>[
    BoxShadow(color: Color(0x38F5F3EF), blurRadius: 0.0, spreadRadius: 3.0),
  ];
  static const List<BoxShadow> focusDangerDark = <BoxShadow>[
    BoxShadow(color: Color(0x47F87171), blurRadius: 0.0, spreadRadius: 3.0),
  ];
  static const List<BoxShadow> focusSuccessDark = <BoxShadow>[
    BoxShadow(color: Color(0x404ADE80), blurRadius: 0.0, spreadRadius: 3.0),
  ];
  static const List<BoxShadow> hairlineDark = <BoxShadow>[
    BoxShadow(color: Color(0x14FFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
  ];
}

/// Elevation intents (`elevation` in tokens.json). Resting surfaces carry a
/// hairline and no shadow; only these intents float. Overlay and modal draw
/// their own 1px edge inside the shadow, in both themes.
@immutable
class AerosElevation {
  const AerosElevation({required this.raised, required this.overlay, required this.modal});

  final List<BoxShadow> raised;
  final List<BoxShadow> overlay;
  final List<BoxShadow> modal;

  static const AerosElevation light = AerosElevation(
    raised: <BoxShadow>[
      BoxShadow(color: Color(0x0F000000), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
    ],
    overlay: <BoxShadow>[
      BoxShadow(color: Color(0x14000000), blurRadius: 0.0, spreadRadius: 1.0),
      BoxShadow(color: Color(0x1A000000), blurRadius: 12.0, spreadRadius: -2.0, offset: Offset(0.0, 4.0)),
      BoxShadow(color: Color(0x0F000000), blurRadius: 4.0, spreadRadius: -2.0, offset: Offset(0.0, 2.0)),
    ],
    modal: <BoxShadow>[
      BoxShadow(color: Color(0x14000000), blurRadius: 0.0, spreadRadius: 1.0),
      BoxShadow(color: Color(0x29000000), blurRadius: 40.0, spreadRadius: -8.0, offset: Offset(0.0, 16.0)),
      BoxShadow(color: Color(0x14000000), blurRadius: 12.0, spreadRadius: -4.0, offset: Offset(0.0, 4.0)),
    ],
  );

  static const AerosElevation dark = AerosElevation(
    raised: <BoxShadow>[
      BoxShadow(color: Color(0x80000000), blurRadius: 2.0, offset: Offset(0.0, 1.0)),
    ],
    overlay: <BoxShadow>[
      BoxShadow(color: Color(0x1AFFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
      BoxShadow(color: Color(0x99000000), blurRadius: 24.0, spreadRadius: -4.0, offset: Offset(0.0, 8.0)),
    ],
    modal: <BoxShadow>[
      BoxShadow(color: Color(0x1AFFFFFF), blurRadius: 0.0, spreadRadius: 1.0),
      BoxShadow(color: Color(0xB3000000), blurRadius: 56.0, spreadRadius: -12.0, offset: Offset(0.0, 24.0)),
    ],
  );

  static AerosElevation resolve(bool isDark) => isDark ? dark : light;

  static AerosElevation lerp(AerosElevation a, AerosElevation b, double t) => AerosElevation(
        raised: BoxShadow.lerpList(a.raised, b.raised, t)!,
        overlay: BoxShadow.lerpList(a.overlay, b.overlay, t)!,
        modal: BoxShadow.lerpList(a.modal, b.modal, t)!,
      );
}

/// Sizes that change with input density (`size` in tokens.json): `pointer` for
/// a mouse, `touch` for fingers.
@immutable
class AerosSizeTokens {
  const AerosSizeTokens({
    required this.controlXs,
    required this.controlSm,
    required this.controlMd,
    required this.controlLg,
    required this.controlXl,
    required this.header,
    required this.row,
    required this.iconButton,
    required this.badge,
    required this.listAvatar,
    required this.inlineAvatar,
    required this.navRow,
    required this.navIcon,
    required this.navLabel,
    required this.minTarget,
  });

  final double controlXs;
  final double controlSm;
  final double controlMd;
  final double controlLg;
  final double controlXl;
  final double header;
  final double row;
  final double iconButton;
  final double badge;
  final double listAvatar;
  final double inlineAvatar;
  final double navRow;
  final double navIcon;
  final double navLabel;
  final double minTarget;

  static const AerosSizeTokens pointer = AerosSizeTokens(
    controlXs: 24.0,
    controlSm: 28.0,
    controlMd: 32.0,
    controlLg: 36.0,
    controlXl: 40.0,
    header: 48.0,
    row: 40.0,
    iconButton: 32.0,
    badge: 18.0,
    listAvatar: 40.0,
    inlineAvatar: 26.0,
    navRow: 32.0,
    navIcon: 16.0,
    navLabel: 13.0,
    minTarget: 24.0,
  );

  static const AerosSizeTokens touch = AerosSizeTokens(
    controlXs: 32.0,
    controlSm: 36.0,
    controlMd: 40.0,
    controlLg: 44.0,
    controlXl: 48.0,
    header: 56.0,
    row: 48.0,
    iconButton: 44.0,
    badge: 20.0,
    listAvatar: 48.0,
    inlineAvatar: 30.0,
    navRow: 48.0,
    navIcon: 20.0,
    navLabel: 14.0,
    minTarget: 48.0,
  );

  // ─── Density-independent ───
  static const double iconXs = 12.0;
  static const double iconSm = 14.0;
  static const double iconMd = 16.0;
  static const double iconLg = 20.0;
  static const double iconXl = 24.0;
  static const double avatarXs = 20.0;
  static const double avatarSm = 24.0;
  static const double avatarMd = 32.0;
  static const double avatarLg = 40.0;
  static const double avatarXl = 56.0;
}

/// Semantic radii (`shape` in tokens.json) — widgets use these, never a raw scale step.
class AerosShapeTokens {
  AerosShapeTokens._();

  static const double item = 4.0;
  static const double control = 6.0;
  static const double surface = 8.0;
  static const double modal = 12.0;
  static const double pill = 9999.0;
}

/// Focus ring, opacity, border width and layout metrics.
class AerosMetricTokens {
  AerosMetricTokens._();

  static const double focusWidth = 2.0;
  static const double focusOffset = 2.0;
  static const double focusOffsetField = -1.0;
  static const double focusOffsetInset = -2.0;
  static const double opacityDisabled = 0.4;
  static const double opacityMuted = 0.6;
  static const double borderHairline = 1.0;
  static const double borderThick = 2.0;
  static const double layoutSidebar = 240.0;
  static const double layoutSidebarRail = 56.0;
  static const double layoutSidebarMobile = 280.0;
  static const double layoutContentMax = 1200.0;
  static const double layoutDialogSm = 400.0;
  static const double layoutDialogMd = 520.0;
  static const double layoutDialogLg = 720.0;
  static const double layoutDialogXl = 960.0;
  static const double layoutDrawerSm = 360.0;
  static const double layoutDrawerMd = 480.0;
  static const double layoutDrawerLg = 640.0;
}
