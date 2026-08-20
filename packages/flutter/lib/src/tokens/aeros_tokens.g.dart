// Aeros Design Tokens — generated. Do not edit.
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AerosTokens {
  AerosTokens._();

  // ─── Color ramps ───
  static const Color ink0 = Color(0xFFFFFFFF);
  static const Color ink50 = Color(0xFFFAFAF9);
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

  // ─── Semantic (light / dark) ───
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF15803D);
  static const Color successBorder = Color(0xFFBBF7D0);
  static const Color warning = Color(0xFFCC6D04);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFB45309);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFB91C1C);
  static const Color dangerBorder = Color(0xFFFECACA);
  static const Color info = Color(0xFF57554F);
  static const Color infoBg = Color(0xFFF4F4F2);
  static const Color infoText = Color(0xFF272622);
  static const Color infoBorder = Color(0xFFE7E6E2);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successBgDark = Color(0xFF132B1D);
  static const Color successTextDark = Color(0xFF86EFAC);
  static const Color successBorderDark = Color(0xFF235C36);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningBgDark = Color(0xFF2E2410);
  static const Color warningTextDark = Color(0xFFFCD34D);
  static const Color warningBorderDark = Color(0xFF6B4E16);
  static const Color dangerDark = Color(0xFFF87171);
  static const Color dangerBgDark = Color(0xFF331414);
  static const Color dangerTextDark = Color(0xFFFCA5A5);
  static const Color dangerBorderDark = Color(0xFF7F2A2A);
  static const Color infoDark = Color(0xFFA8A6A0);
  static const Color infoBgDark = Color(0xFF2A2723);
  static const Color infoTextDark = Color(0xFFD6D4CF);
  static const Color infoBorderDark = Color(0xFF46423B);

  // ─── Breakpoints (logical px) ───
  static const double breakpointSm = 640.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double breakpointXl = 1280.0;
  static const double breakpoint2xl = 1536.0;

  // ─── Motion (ms + curves) ───
  static const Duration durationQuick = Duration(milliseconds: 90);
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationBase = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 320);
  static const Cubic easeStandard = Cubic(0.2, 0, 0, 1);
  static const Cubic easeEmphasized = Cubic(0.3, 0, 0, 1);
  static const Cubic easeDecelerate = Cubic(0, 0, 0, 1);
  static const Cubic easeEntrance = Cubic(0.16, 1, 0.3, 1);
  static const Cubic easeSpring = Cubic(0.34, 1.4, 0.64, 1);

  // ─── Theme aliases (light / dark) ───
  static const Color aliasLightBgCanvas = Color(0xFFF7F6F4);
  static const Color aliasLightBgSurface = Color(0xFFFFFFFF);
  static const Color aliasLightBgElevated = Color(0xFFFFFFFF);
  static const Color aliasLightBgSubtle = Color(0xFFF1F0ED);
  static const Color aliasLightBgInverse = Color(0xFF1A1916);
  static const Color aliasLightFgPrimary = Color(0xFF1A1916);
  static const Color aliasLightFgSecondary = Color(0xFF57554F);
  static const Color aliasLightFgMuted = Color(0xFF6C6A63);
  static const Color aliasLightFgInverse = Color(0xFFFFFFFF);
  static const Color aliasLightFgBrand = Color(0xFF1A1916);
  static const Color aliasLightBorderDefault = Color(0xFFE4E2DD);
  static const Color aliasLightBorderStrong = Color(0xFFCECBC4);
  static const Color aliasLightBorderSubtle = Color(0xFFEEEDEA);
  static const Color aliasLightBorderFocus = Color(0xFF1A1916);
  static const Color aliasLightBrandPrimary = Color(0xFF1A1916);
  static const Color aliasLightBrandPrimaryHover = Color(0xFF403E39);
  static const Color aliasLightBrandPrimaryMuted = Color(0xFFF1F0ED);
  static const Color aliasLightFocusRing = Color(0xFF1A1916);
  static const Color aliasLightFocusRingOffset = Color(0xFFFFFFFF);
  static const Color aliasDarkBgCanvas = Color(0xFF1A1815);
  static const Color aliasDarkBgSurface = Color(0xFF221F1B);
  static const Color aliasDarkBgElevated = Color(0xFF2A2723);
  static const Color aliasDarkBgSubtle = Color(0xFF2F2C27);
  static const Color aliasDarkBgInverse = Color(0xFFFAFAF9);
  static const Color aliasDarkFgPrimary = Color(0xFFF5F3EF);
  static const Color aliasDarkFgSecondary = Color(0xFFC4C1BA);
  static const Color aliasDarkFgMuted = Color(0xFF9A978F);
  static const Color aliasDarkFgInverse = Color(0xFF1A1815);
  static const Color aliasDarkFgBrand = Color(0xFFF5F3EF);
  static const Color aliasDarkBorderDefault = Color(0xFF332F2A);
  static const Color aliasDarkBorderStrong = Color(0xFF46423B);
  static const Color aliasDarkBorderSubtle = Color(0xFF2A2723);
  static const Color aliasDarkBorderFocus = Color(0xFFF5F3EF);
  static const Color aliasDarkBrandPrimary = Color(0xFFF5F3EF);
  static const Color aliasDarkBrandPrimaryHover = Color(0xFFC4C1BA);
  static const Color aliasDarkBrandPrimaryMuted = Color(0xFF2F2C27);
  static const Color aliasDarkFocusRing = Color(0xFFF5F3EF);
  static const Color aliasDarkFocusRingOffset = Color(0xFF1A1815);

  // ─── Spacing (dp) ───
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space7 = 28.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space14 = 56.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;
  static const double space24 = 96.0;
  static const double space32 = 128.0;
  static const double spacepx = 1.0;
  static const double space0_5 = 2.0;
  static const double space1_5 = 6.0;
  static const double space2_5 = 10.0;
  static const double space3_5 = 14.0;

  // ─── Radii ───
  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 20.0;
  static const double radius3xl = 24.0;
  static const double radius4xl = 32.0;
  static const double radiusFull = 9999.0;

  // ─── Font families ───
  static const String fontSans = 'Inter';
  static const String fontMono = 'IBM Plex Mono';
}

/// Type scale — mirrors the `text` block in tokens.json.
/// `overline` is uppercased by the consumer (TextStyle has no transform).
class AerosTextStyles {
  AerosTextStyles._();

  static const TextStyle displayXl = TextStyle(
    fontFamily: 'Inter',
    fontSize: 56.0,
    fontWeight: FontWeight.w800,
    height: 1.00,
    letterSpacing: -1.68,
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 42.0,
    fontWeight: FontWeight.w800,
    height: 1.00,
    letterSpacing: -1.26,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.80,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.10,
    letterSpacing: -0.62,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.40,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: -0.30,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: -0.13,
  );
  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.18,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.00,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.00,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0.04,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.40,
    letterSpacing: 0.00,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    height: 1.40,
    letterSpacing: 0.03,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.50,
    letterSpacing: 0.05,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    height: 1.30,
    letterSpacing: 0.55,
  );
  static const TextStyle monoLg = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    height: 1.20,
    letterSpacing: -0.22,
  );
  static const TextStyle monoMd = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.50,
    letterSpacing: 0.00,
  );
  static const TextStyle monoSm = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.00,
  );
  static const TextStyle monoXs = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.00,
  );
  static const TextStyle labelXs = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    height: 1.00,
    letterSpacing: 0.02,
  );
}
