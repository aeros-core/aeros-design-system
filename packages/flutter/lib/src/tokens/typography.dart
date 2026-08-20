import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aeros typography — Inter (UI) + IBM Plex Mono (data).
///
/// Inter ships bundled as a variable font (`assets/fonts/InterVariable.ttf`,
/// SIL OFL) so first paint is correct with no runtime fetch. Weight is driven
/// by both `fontWeight` and a `wght` axis variation; the `opsz` axis selects
/// Inter's optical cut — the display cut (opsz 32) at large sizes, the text cut
/// (opsz 14) for body/labels. Inter reads sturdier than the previous Plus
/// Jakarta Sans, and the interactive tiers (labels/buttons/nav) are now w600 so
/// UI text no longer looks thin.
///
/// IBM Plex Mono (data) stays on google_fonts; the wordmark keeps Nunito Sans
/// (it needs a width axis Inter lacks). Those are the only intentional
/// non-Inter UI faces — do not "fix" them to Inter.
class AerosTypography {
  AerosTypography._();

  static const String _family = 'Inter';
  static const String _package = 'aeros_design_system';

  // NOTE: role styles inherit the ambient text color (DefaultTextStyle / theme)
  // unless `color:` is passed. Hardcoded light-mode defaults made bare calls
  // render near-black on near-black in dark themes — never reintroduce them.

  /// [opsz] picks Inter's optical size: 14 (text) for body/labels, 32 (display)
  /// for sizes >= 28px.
  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color? color,
    double opsz = 14,
  }) =>
      TextStyle(
        fontFamily: _family,
        package: _package,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontVariations: [
          FontVariation('wght', weight.value.toDouble()),
          FontVariation('opsz', opsz),
        ],
      );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    double height = 1.5,
    double letterSpacing = 0,
    Color? color,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ─── Display (optical cut) ───
  static TextStyle displayXl({Color? color}) => _sans(size: 56, weight: FontWeight.w800, height: 1.0, letterSpacing: -1.68, opsz: 32, color: color);
  static TextStyle displayLg({Color? color}) => _sans(size: 42, weight: FontWeight.w800, height: 1.0, letterSpacing: -1.26, opsz: 32, color: color);
  static TextStyle displayMd({Color? color}) => _sans(size: 32, weight: FontWeight.w700, height: 1.05, letterSpacing: -0.80, opsz: 32, color: color);

  // ─── Headings ───
  static TextStyle h1({Color? color}) => _sans(size: 28, weight: FontWeight.w700, height: 1.1, letterSpacing: -0.62, opsz: 32, color: color);
  static TextStyle h2({Color? color}) => _sans(size: 22, weight: FontWeight.w700, height: 1.15, letterSpacing: -0.40, color: color);
  static TextStyle h3({Color? color}) => _sans(size: 20, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.30, color: color);
  static TextStyle h4({Color? color}) => _sans(size: 16, weight: FontWeight.w600, height: 1.3, letterSpacing: -0.16, color: color);
  static TextStyle titleLg({Color? color}) => _sans(size: 18, weight: FontWeight.w600, height: 1.35, letterSpacing: -0.18, color: color);

  // ─── Body ───
  static TextStyle bodyLg({Color? color}) => _sans(size: 16, weight: FontWeight.w400, height: 1.5, color: color);
  static TextStyle bodyMd({Color? color}) => _sans(size: 14, weight: FontWeight.w400, height: 1.55, color: color);
  static TextStyle bodySm({Color? color}) => _sans(size: 13, weight: FontWeight.w400, height: 1.55, letterSpacing: 0.01, color: color);

  // ─── Labels / UI controls (w600 — sturdy, never thin) ───
  static TextStyle labelMd({Color? color}) => _sans(size: 14, weight: FontWeight.w600, height: 1.4, color: color);
  static TextStyle labelSm({Color? color}) => _sans(size: 13, weight: FontWeight.w600, height: 1.4, letterSpacing: 0.01, color: color);
  static TextStyle labelXs({Color? color}) => _sans(size: 11, weight: FontWeight.w600, height: 1.0, letterSpacing: 0.02, color: color);
  static TextStyle caption({Color? color}) => _sans(size: 12, weight: FontWeight.w500, height: 1.5, letterSpacing: 0.02, color: color);
  static TextStyle overline({Color? color}) =>
      _sans(size: 11, weight: FontWeight.w700, height: 1.3, letterSpacing: 0.55, color: color);

  // ─── Mono (data stays crisp) ───
  static TextStyle monoLg({Color? color}) => _mono(size: 22, weight: FontWeight.w500, height: 1.2, letterSpacing: -0.22, color: color);
  static TextStyle monoMd({Color? color}) => _mono(size: 14, weight: FontWeight.w500, height: 1.5, color: color);
  static TextStyle monoSm({Color? color}) => _mono(size: 12, weight: FontWeight.w400, height: 1.5, color: color);
  static TextStyle monoXs({Color? color}) => _mono(size: 11, weight: FontWeight.w400, height: 1.5, color: color);

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
