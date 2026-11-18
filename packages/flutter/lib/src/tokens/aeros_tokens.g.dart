// Aeros Design Tokens — generated from packages/tokens/src/tokens.json. Do not edit.
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AerosTokens {
  AerosTokens._();

  // ─── Color ramps ───
  static const Color ink0 = Color(0xFFFFFFFF);
  static const Color ink50 = Color(0xFFFAFAFA);
  static const Color ink100 = Color(0xFFF4F4F5);
  static const Color ink200 = Color(0xFFE6E6E9);
  static const Color ink300 = Color(0xFFD2D2D7);
  static const Color ink400 = Color(0xFF9D9DA5);
  static const Color ink500 = Color(0xFF6B6B73);
  static const Color ink600 = Color(0xFF52525A);
  static const Color ink700 = Color(0xFF3B3B42);
  static const Color ink800 = Color(0xFF27272B);
  static const Color ink850 = Color(0xFF1C1C20);
  static const Color ink900 = Color(0xFF141417);
  static const Color ink950 = Color(0xFF0B0B0D);

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
  static const Color info = Color(0xFF52525A);
  static const Color infoBg = Color(0xFFF4F4F5);
  static const Color infoText = Color(0xFF27272B);
  static const Color infoBorder = Color(0xFFE6E6E9);
  static const Color dangerHover = Color(0xFFB91C1C);
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
  static const Color infoDark = Color(0xFF9D9DA5);
  static const Color infoBgDark = Color(0xFF27272B);
  static const Color infoTextDark = Color(0xFFD2D2D7);
  static const Color infoBorderDark = Color(0xFF3B3B42);
  static const Color dangerHoverDark = Color(0xFFFCA5A5);

  // ─── Breakpoints (logical px) ───
  static const double breakpointSm = 640.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double breakpointXl = 1280.0;
  static const double breakpoint2xl = 1536.0;

  // ─── Motion (ms + curves) ───
  static const Duration durationQuick = Duration(milliseconds: 80);
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationBase = Duration(milliseconds: 180);
  static const Duration durationSlow = Duration(milliseconds: 260);
  static const Cubic easeStandard = Cubic(0.2, 0, 0, 1);
  static const Cubic easeEnter = Cubic(0.16, 1, 0.3, 1);
  static const Cubic easeExit = Cubic(0.4, 0, 1, 1);

  // ─── Theme aliases (light / dark) ───
  static const Color aliasLightBgCanvas = Color(0xFFFAFAFA);
  static const Color aliasLightBgSurface = Color(0xFFFFFFFF);
  static const Color aliasLightBgElevated = Color(0xFFFFFFFF);
  static const Color aliasLightBgSubtle = Color(0xFFF4F4F5);
  static const Color aliasLightBgInset = Color(0xFFF4F4F5);
  static const Color aliasLightBgInverse = Color(0xFF141417);
  static const Color aliasLightFgPrimary = Color(0xFF141417);
  static const Color aliasLightFgSecondary = Color(0xFF52525A);
  static const Color aliasLightFgMuted = Color(0xFF6B6B73);
  static const Color aliasLightFgDisabled = Color(0xFF9D9DA5);
  static const Color aliasLightFgInverse = Color(0xFFFFFFFF);
  static const Color aliasLightFgBrand = Color(0xFF141417);
  static const Color aliasLightBorderDefault = Color(0xFFE6E6E9);
  static const Color aliasLightBorderStrong = Color(0xFFD2D2D7);
  static const Color aliasLightBorderSubtle = Color(0xFFF4F4F5);
  static const Color aliasLightBorderFocus = Color(0xFF141417);
  static const Color aliasLightBrandPrimary = Color(0xFF141417);
  static const Color aliasLightBrandPrimaryHover = Color(0xFF3B3B42);
  static const Color aliasLightBrandPrimaryMuted = Color(0xFFF4F4F5);
  static const Color aliasLightFocusRing = Color(0xFF141417);
  static const Color aliasLightStateHover = Color(0x0D141417);
  static const Color aliasLightStatePressed = Color(0x17141417);
  static const Color aliasLightStateSelected = Color(0x12141417);
  static const Color aliasLightScrim = Color(0x660B0B0D);
  static const Color aliasDarkBgCanvas = Color(0xFF0B0B0D);
  static const Color aliasDarkBgSurface = Color(0xFF141417);
  static const Color aliasDarkBgElevated = Color(0xFF1C1C20);
  static const Color aliasDarkBgSubtle = Color(0xFF1C1C20);
  static const Color aliasDarkBgInset = Color(0xFF0B0B0D);
  static const Color aliasDarkBgInverse = Color(0xFFFAFAFA);
  static const Color aliasDarkFgPrimary = Color(0xFFFAFAFA);
  static const Color aliasDarkFgSecondary = Color(0xFFD2D2D7);
  static const Color aliasDarkFgMuted = Color(0xFF9D9DA5);
  static const Color aliasDarkFgDisabled = Color(0xFF52525A);
  static const Color aliasDarkFgInverse = Color(0xFF0B0B0D);
  static const Color aliasDarkFgBrand = Color(0xFFFAFAFA);
  static const Color aliasDarkBorderDefault = Color(0xFF27272B);
  static const Color aliasDarkBorderStrong = Color(0xFF3B3B42);
  static const Color aliasDarkBorderSubtle = Color(0xFF1C1C20);
  static const Color aliasDarkBorderFocus = Color(0xFFFAFAFA);
  static const Color aliasDarkBrandPrimary = Color(0xFFFAFAFA);
  static const Color aliasDarkBrandPrimaryHover = Color(0xFFD2D2D7);
  static const Color aliasDarkBrandPrimaryMuted = Color(0xFF1C1C20);
  static const Color aliasDarkFocusRing = Color(0xFFFAFAFA);
  static const Color aliasDarkStateHover = Color(0x12FAFAFA);
  static const Color aliasDarkStatePressed = Color(0x1FFAFAFA);
  static const Color aliasDarkStateSelected = Color(0x1AFAFAFA);
  static const Color aliasDarkScrim = Color(0xB30B0B0D);

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
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;

  // ─── Font families ───
  static const String fontSans = 'Inter';
  static const String fontMono = 'IBM Plex Mono';
}
