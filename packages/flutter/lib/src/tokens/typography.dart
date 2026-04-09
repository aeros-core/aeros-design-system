import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aeros typography — Plus Jakarta Sans (UI) + IBM Plex Mono (data).
///
/// Sizes/weights mirror `packages/tokens/src/tokens.json` text scale.
class AerosTypography {
  AerosTypography._();

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = const Color(0xFF0A0A0A),
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = const Color(0xFF0A0A0A),
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ─── Display ───
  static TextStyle displayXl({Color? color}) => _sans(size: 56, weight: FontWeight.w800, height: 1.0, letterSpacing: -2.24, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle displayLg({Color? color}) => _sans(size: 42, weight: FontWeight.w800, height: 1.0, letterSpacing: -1.68, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle displayMd({Color? color}) => _sans(size: 32, weight: FontWeight.w800, height: 1.05, letterSpacing: -0.96, color: color ?? const Color(0xFF0A0A0A));

  // ─── Headings ───
  static TextStyle h1({Color? color}) => _sans(size: 28, weight: FontWeight.w800, height: 1.1, letterSpacing: -0.84, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle h2({Color? color}) => _sans(size: 22, weight: FontWeight.w800, height: 1.15, letterSpacing: -0.44, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle h3({Color? color}) => _sans(size: 20, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.4, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle h4({Color? color}) => _sans(size: 16, weight: FontWeight.w700, height: 1.3, letterSpacing: -0.16, color: color ?? const Color(0xFF0A0A0A));

  // ─── Body ───
  static TextStyle bodyLg({Color? color}) => _sans(size: 16, weight: FontWeight.w500, height: 1.5, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle bodyMd({Color? color}) => _sans(size: 14, weight: FontWeight.w500, height: 1.55, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle bodySm({Color? color}) => _sans(size: 13, weight: FontWeight.w500, height: 1.55, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle caption({Color? color}) => _sans(size: 12, weight: FontWeight.w500, height: 1.5, color: color ?? const Color(0xFF404040));
  static TextStyle overline({Color? color}) =>
      _sans(size: 11, weight: FontWeight.w600, height: 1.3, letterSpacing: 0.88, color: color ?? const Color(0xFF7A85A8));

  // ─── Mono ───
  static TextStyle monoLg({Color? color}) => _mono(size: 22, weight: FontWeight.w500, height: 1.2, letterSpacing: -0.22, color: color ?? const Color(0xFF0A0A0A));
  static TextStyle monoMd({Color? color}) => _mono(size: 14, weight: FontWeight.w500, height: 1.5, color: color ?? const Color(0xFF1A2F8A));
  static TextStyle monoSm({Color? color}) => _mono(size: 12, weight: FontWeight.w400, height: 1.5, color: color ?? const Color(0xFF737373));
  static TextStyle monoXs({Color? color}) => _mono(size: 11, weight: FontWeight.w400, height: 1.5, color: color ?? const Color(0xFF737373));

  /// Full Material TextTheme from Aeros scale.
  static TextTheme textTheme({required Color fg, required Color fgMuted}) {
    return TextTheme(
      displayLarge: displayLg(color: fg),
      displayMedium: displayMd(color: fg),
      headlineLarge: h1(color: fg),
      headlineMedium: h2(color: fg),
      headlineSmall: h3(color: fg),
      titleLarge: h4(color: fg),
      titleMedium: bodyLg(color: fg),
      titleSmall: bodyMd(color: fg),
      bodyLarge: bodyLg(color: fg),
      bodyMedium: bodyMd(color: fg),
      bodySmall: bodySm(color: fg),
      labelLarge: bodyMd(color: fg).copyWith(fontWeight: FontWeight.w600),
      labelMedium: caption(color: fgMuted),
      labelSmall: overline(color: fgMuted),
    );
  }
}
