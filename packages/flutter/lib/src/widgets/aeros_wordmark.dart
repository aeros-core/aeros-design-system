import 'package:flutter/material.dart';

import '../theme/aeros_theme_extension.dart';

/// Renders the Aeros wordmark: **Nunito Sans Expanded (wdth 125) Medium
/// (500), tracking +0.01em** — the Flutter equivalent of the web
/// design-system's `aeros-logo` CSS class.
///
/// The spec was matched against the reference logo artwork (2026-10-09,
/// pixel overlap 0.93): an open, regular-weight extended mark — not the
/// heavy 800 it used to be.
///
/// The face is **bundled** (`assets/fonts/AerosWordmark-…ttf`, a 2.4 KB
/// subset holding only the glyphs A e r o s) instead of fetched through
/// `google_fonts`: that package serves static normal-width cuts, so the
/// `wdth 125` axis was silently ignored and the mark never rendered
/// expanded. Bundling also means no runtime font fetch on the splash.
/// Because of the subset, this widget can only ever draw "Aeros".
///
/// Use this wherever the literal "Aeros" string is rendered as branding
/// (auth screens, splash, walkthrough, web shell). Never
/// `Text('Aeros', …)` with a default font.
class AerosWordmark extends StatelessWidget {
  const AerosWordmark({
    super.key,
    this.size = 24,
    this.color,
    this.textAlign,
  });

  /// Bundled family name (declared in this package's pubspec).
  static const String fontFamily = 'AerosWordmark';

  /// Font size in logical pixels. Defaults to 24 — matches mobile auth
  /// headers. Use 32–40 for splash / hero / desktop frame, 18–20 for
  /// tight inline use.
  final double size;

  /// Optional override colour. Defaults to `aliases.fgPrimary` via the
  /// theme extension — ink-900 in light mode, white in dark.
  final Color? color;

  /// Optional text alignment.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final aliases = context.aerosColors;
    return Text(
      'Aeros',
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        package: 'aeros_design_system',
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? aliases.fgPrimary,
        letterSpacing: size * 0.01,
        height: 1.0,
      ),
    );
  }
}
