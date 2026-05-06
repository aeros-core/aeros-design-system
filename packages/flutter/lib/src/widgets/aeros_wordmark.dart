import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/aeros_theme_extension.dart';

/// Renders the Aeros wordmark in **Nunito Sans wdth-125, weight 800** —
/// the Flutter equivalent of the web design-system's `aeros-logo` CSS
/// class (`font-stretch: 125%`).
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
      // GoogleFonts.X() does not expose `fontVariations` as a named
      // param, so we apply the wdth-125 axis via copyWith. Nunito Sans
      // is hosted by Google Fonts as a variable font with wdth + wght
      // axes, so this resolves without bundling a static wdth=125 cut.
      style: GoogleFonts.nunitoSans(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? aliases.fgPrimary,
        letterSpacing: -0.5,
        height: 1.0,
      ).copyWith(
        // Matches the web `aeros-logo` class (`font-stretch: 125%`).
        fontVariations: const [FontVariation('wdth', 125)],
      ),
    );
  }
}
