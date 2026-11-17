import 'package:flutter/material.dart';

import 'aeros_theme_tokens.g.dart';

/// Aeros typography — Inter (UI) + IBM Plex Mono (data).
///
/// A thin wrapper over the generated [AerosTypeScale] (emitted from
/// `tokens.json`): every size, line height, tracking value, weight and optical
/// size lives there, none here. Each role returns the generated style with the
/// optional [Color] applied and, when `weight:` is given, re-weighted so the
/// glyphs actually change (see [AerosTextStyleWeight.withWeight]).
///
/// Both faces ship bundled (SIL OFL), so first paint is correct with no
/// runtime fetch: Inter as a variable font (`assets/fonts/InterVariable.ttf`;
/// weight is the `wght` axis, the `opsz` axis selects the display cut at large
/// sizes) and IBM Plex Mono as static Regular + Medium.
///
/// The wordmark keeps Nunito Sans (it needs a width axis Inter lacks). Mono and
/// the wordmark are the only intentional non-Inter faces — do not "fix" them to
/// Inter.
class AerosTypography {
  AerosTypography._();

  /// The package that bundles the fonts. The generated mono styles name the
  /// family only; this resolves them to this package's asset for consuming apps.
  static const String _package = 'aeros_design_system';

  // NOTE: role styles inherit the ambient text color (DefaultTextStyle / theme)
  // unless `color:` is passed. Hardcoded light-mode defaults made bare calls
  // render near-black on near-black in dark themes — never reintroduce them.

  static TextStyle _sans(TextStyle base, Color? color, FontWeight? weight) {
    final style = color == null ? base : base.copyWith(color: color);
    return weight == null ? style : style.withWeight(weight);
  }

  static TextStyle _mono(TextStyle base, Color? color, FontWeight? weight) =>
      _sans(base.copyWith(package: _package), color, weight);

  // ─── Display (optical cut) ───
  static TextStyle displayXl({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.displayXl, color, weight);
  static TextStyle displayLg({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.displayLg, color, weight);
  static TextStyle displayMd({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.displayMd, color, weight);

  // ─── Headings ───
  static TextStyle h1({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.h1, color, weight);
  static TextStyle h2({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.h2, color, weight);
  static TextStyle h3({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.h3, color, weight);
  static TextStyle h4({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.h4, color, weight);
  static TextStyle titleLg({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.titleLg, color, weight);

  // ─── Body (wght 450 — the brand text weight) ───
  static TextStyle bodyLg({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.bodyLg, color, weight);
  static TextStyle bodyMd({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.bodyMd, color, weight);
  static TextStyle bodySm({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.bodySm, color, weight);

  // ─── Labels / UI controls (w600 — sturdy, never thin) ───
  static TextStyle labelMd({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.labelMd, color, weight);
  static TextStyle labelSm({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.labelSm, color, weight);
  static TextStyle labelXs({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.labelXs, color, weight);
  static TextStyle caption({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.caption, color, weight);
  static TextStyle overline({Color? color, FontWeight? weight}) => _sans(AerosTypeScale.overline, color, weight);

  // ─── Mono (data stays crisp) ───
  static TextStyle monoLg({Color? color, FontWeight? weight}) => _mono(AerosTypeScale.monoLg, color, weight);
  static TextStyle monoMd({Color? color, FontWeight? weight}) => _mono(AerosTypeScale.monoMd, color, weight);
  static TextStyle monoSm({Color? color, FontWeight? weight}) => _mono(AerosTypeScale.monoSm, color, weight);
  static TextStyle monoXs({Color? color, FontWeight? weight}) => _mono(AerosTypeScale.monoXs, color, weight);

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

/// Re-weights an Aeros text style so the glyphs actually change.
///
/// Inter is bundled as a variable font and every Aeros sans style pins its `wght` axis — which is
/// what the renderer follows. `style.copyWith(fontWeight: FontWeight.w600)` therefore renders at the
/// style's original weight (measured: identical advance widths for w400 and a copyWith'd w600).
/// Use `AerosTypography.bodySm(weight: FontWeight.w600)` or
/// `AerosTypography.bodySm().withWeight(FontWeight.w600)` instead; both move the axis with it and
/// keep every other variation (the `opsz` optical cut).
///
/// Mono styles are static faces (Regular 400, Medium 500): there `fontWeight` picks the nearest
/// bundled face and the axis is ignored.
extension AerosTextStyleWeight on TextStyle {
  TextStyle withWeight(FontWeight weight) => copyWith(
        fontWeight: weight,
        fontVariations: [
          for (final v in fontVariations ?? const <FontVariation>[])
            if (v.axis != 'wght') v,
          FontVariation('wght', weight.value.toDouble()),
        ],
      );
}
