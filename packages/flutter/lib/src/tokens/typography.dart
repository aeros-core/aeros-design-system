import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aeros typography — Plus Jakarta Sans (UI) + IBM Plex Mono (data).
///
/// Sizes/weights/tracking mirror the `text` scale in tokens.json. Headings are
/// Bold (w700) with relaxed tracking; body uses the `book` weight (w450 on web,
/// rounded to w400 here as Flutter has no 450 instance). Mono is unchanged.
class AerosTypography {
  AerosTypography._();

  static const Color _fg = Color(0xFF1A1916);
  static const Color _fgSecondary = Color(0xFF57554F);
  static const Color _fgMuted = Color(0xFF6E6C66);

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = _fg,
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
    Color color = _fg,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ─── Display ───
  static TextStyle displayXl({Color? color}) => _sans(size: 56, weight: FontWeight.w700, height: 1.0, letterSpacing: -1.40, color: color ?? _fg);
  static TextStyle displayLg({Color? color}) => _sans(size: 42, weight: FontWeight.w700, height: 1.0, letterSpacing: -1.05, color: color ?? _fg);
  static TextStyle displayMd({Color? color}) => _sans(size: 32, weight: FontWeight.w700, height: 1.05, letterSpacing: -0.64, color: color ?? _fg);

  // ─── Headings ───
  static TextStyle h1({Color? color}) => _sans(size: 28, weight: FontWeight.w700, height: 1.1, letterSpacing: -0.56, color: color ?? _fg);
  static TextStyle h2({Color? color}) => _sans(size: 22, weight: FontWeight.w700, height: 1.15, letterSpacing: -0.33, color: color ?? _fg);
  static TextStyle h3({Color? color}) => _sans(size: 20, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.24, color: color ?? _fg);
  static TextStyle h4({Color? color}) => _sans(size: 16, weight: FontWeight.w600, height: 1.3, letterSpacing: -0.13, color: color ?? _fg);
  static TextStyle titleLg({Color? color}) => _sans(size: 18, weight: FontWeight.w600, height: 1.35, letterSpacing: -0.18, color: color ?? _fg);

  // ─── Body ───
  static TextStyle bodyLg({Color? color}) => _sans(size: 16, weight: FontWeight.w400, height: 1.5, color: color ?? _fg);
  static TextStyle bodyMd({Color? color}) => _sans(size: 14, weight: FontWeight.w400, height: 1.55, color: color ?? _fg);
  static TextStyle bodySm({Color? color}) => _sans(size: 13, weight: FontWeight.w400, height: 1.55, letterSpacing: 0.04, color: color ?? _fg);
  static TextStyle labelMd({Color? color}) => _sans(size: 14, weight: FontWeight.w500, height: 1.4, color: color ?? _fg);
  static TextStyle labelSm({Color? color}) => _sans(size: 13, weight: FontWeight.w500, height: 1.4, letterSpacing: 0.03, color: color ?? _fg);
  static TextStyle caption({Color? color}) => _sans(size: 12, weight: FontWeight.w400, height: 1.5, letterSpacing: 0.05, color: color ?? _fgSecondary);
  static TextStyle overline({Color? color}) =>
      _sans(size: 11, weight: FontWeight.w600, height: 1.3, letterSpacing: 0.66, color: color ?? _fgMuted);

  // ─── Mono (unchanged — data stays crisp) ───
  static TextStyle monoLg({Color? color}) => _mono(size: 22, weight: FontWeight.w500, height: 1.2, letterSpacing: -0.22, color: color ?? _fg);
  static TextStyle monoMd({Color? color}) => _mono(size: 14, weight: FontWeight.w500, height: 1.5, color: color ?? const Color(0xFF272622));
  static TextStyle monoSm({Color? color}) => _mono(size: 12, weight: FontWeight.w400, height: 1.5, color: color ?? const Color(0xFF7C7A74));
  static TextStyle monoXs({Color? color}) => _mono(size: 11, weight: FontWeight.w400, height: 1.5, color: color ?? const Color(0xFF7C7A74));

  /// Full Material TextTheme from Aeros scale.
  static TextTheme textTheme({required Color fg, required Color fgMuted}) {
    return TextTheme(
      displayLarge: displayLg(color: fg),
      displayMedium: displayMd(color: fg),
      headlineLarge: h1(color: fg),
      headlineMedium: h2(color: fg),
      headlineSmall: h3(color: fg),
      titleLarge: titleLg(color: fg),
      titleMedium: h4(color: fg),
      titleSmall: labelMd(color: fg),
      bodyLarge: bodyLg(color: fg),
      bodyMedium: bodyMd(color: fg),
      bodySmall: bodySm(color: fg),
      labelLarge: labelMd(color: fg),
      labelMedium: caption(color: fgMuted),
      labelSmall: overline(color: fgMuted),
    );
  }
}
