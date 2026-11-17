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

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgSubtle;
  final Color bgInverse;
  final Color fgPrimary;
  final Color fgSecondary;
  final Color fgMuted;
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

  static AerosAliasColors resolve(bool isDark) => isDark ? dark : light;

  /// Interpolates every colour — theme changes animate instead of snapping.
  static AerosAliasColors lerp(AerosAliasColors a, AerosAliasColors b, double t) => AerosAliasColors(
        bgCanvas: Color.lerp(a.bgCanvas, b.bgCanvas, t)!,
        bgSurface: Color.lerp(a.bgSurface, b.bgSurface, t)!,
        bgElevated: Color.lerp(a.bgElevated, b.bgElevated, t)!,
        bgSubtle: Color.lerp(a.bgSubtle, b.bgSubtle, t)!,
        bgInverse: Color.lerp(a.bgInverse, b.bgInverse, t)!,
        fgPrimary: Color.lerp(a.fgPrimary, b.fgPrimary, t)!,
        fgSecondary: Color.lerp(a.fgSecondary, b.fgSecondary, t)!,
        fgMuted: Color.lerp(a.fgMuted, b.fgMuted, t)!,
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
    fontSize: 56.0,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -1.68,
    fontVariations: [FontVariation('wght', 800.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 42.0,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -1.26,
    fontVariations: [FontVariation('wght', 800.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.8,
    fontVariations: [FontVariation('wght', 700.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.62,
    fontVariations: [FontVariation('wght', 700.0), FontVariation('opsz', 32.0)],
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
    fontVariations: [FontVariation('wght', 700.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    fontVariations: [FontVariation('wght', 700.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.13,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle titleLg = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.18,
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
    height: 1.55,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.04,
    fontVariations: [FontVariation('wght', 450.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.0,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.03,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle caption = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.05,
    fontVariations: [FontVariation('wght', 500.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle overline = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.55,
    fontVariations: [FontVariation('wght', 700.0), FontVariation('opsz', 14.0)],
  );
  static const TextStyle monoLg = TextStyle(
    fontFamily: AerosTokens.fontMono,
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.22,
  );
  static const TextStyle monoMd = TextStyle(
    fontFamily: AerosTokens.fontMono,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.0,
  );
  static const TextStyle monoSm = TextStyle(
    fontFamily: AerosTokens.fontMono,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
  );
  static const TextStyle monoXs = TextStyle(
    fontFamily: AerosTokens.fontMono,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
  );
  static const TextStyle labelXs = TextStyle(
    fontFamily: AerosTokens.fontSans,
    package: 'aeros_design_system',
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.02,
    fontVariations: [FontVariation('wght', 600.0), FontVariation('opsz', 14.0)],
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
