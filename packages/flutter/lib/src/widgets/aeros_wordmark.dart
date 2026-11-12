import 'package:flutter/material.dart';

import '../theme/aeros_theme_extension.dart';
import 'aeros_logo_paths.dart';

/// The Aeros logo: the **woven A** symbol beside the outlined "Aeros"
/// wordmark (brand kit, 11 Nov 2026).
///
/// It is painted from the brand kit's outlines (`aeros_logo_paths.dart`,
/// generated from `aeros-logo-ink.svg`), never typed: the wordmark is
/// Inter Medium outlined at −0.03 em with kerning, the symbol is four
/// strands crossing four strands. Lockup proportions come straight from
/// the artwork — wordmark cap height 0.62 × symbol height, gap 0.32 ×.
///
/// The logo is **monochrome**: one colour, defaulting to
/// `aliases.fgPrimary` (ink on light grounds, paper on dark).
///
/// Use this wherever "Aeros" appears as branding (auth screens, splash,
/// drawer, web shell). Never `Text('Aeros', …)`.
class AerosWordmark extends StatelessWidget {
  const AerosWordmark({
    super.key,
    this.size = 24,
    this.color,
    this.textAlign,
    this.showSymbol = true,
  });

  /// Height of the logo in logical pixels (the symbol's height; the
  /// wordmark's capitals are 0.62 × this). Defaults to 24.
  final double size;

  /// Optional override colour. Defaults to `aliases.fgPrimary` via the
  /// theme extension — ink in light mode, paper in dark.
  final Color? color;

  /// Horizontal placement when the parent forces a wider box (kept from the
  /// text-based wordmark so existing call sites behave the same).
  final TextAlign? textAlign;

  /// `false` draws the outlined wordmark alone, without the woven A.
  final bool showSymbol;

  /// Width ÷ height of what this widget draws.
  double get aspectRatio =>
      showSymbol ? kAerosLockupAspect : kAerosLockupAspect - kAerosWordmarkLeft;

  @override
  Widget build(BuildContext context) {
    final paint = color ?? context.aerosColors.fgPrimary;
    final logo = Semantics(
      label: 'Aeros',
      image: true,
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(size * aspectRatio, size),
        painter: AerosLogoPainter(color: paint, showSymbol: showSymbol),
      ),
    );
    if (textAlign == null) return logo;
    final AlignmentGeometry alignment = switch (textAlign!) {
      TextAlign.center || TextAlign.justify => Alignment.center,
      TextAlign.right => Alignment.centerRight,
      TextAlign.left => Alignment.centerLeft,
      TextAlign.end => AlignmentDirectional.centerEnd,
      TextAlign.start => AlignmentDirectional.centerStart,
    };
    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: logo,
    );
  }
}

/// Paints the logo outlines into its box, scaled to the box height.
class AerosLogoPainter extends CustomPainter {
  AerosLogoPainter({required this.color, this.showSymbol = true});

  final Color color;
  final bool showSymbol;

  static Path _build(List<double> ops) {
    final p = Path();
    var i = 0;
    while (i < ops.length) {
      switch (ops[i++].toInt()) {
        case 0:
          p.moveTo(ops[i], ops[i + 1]);
          i += 2;
        case 1:
          p.lineTo(ops[i], ops[i + 1]);
          i += 2;
        case 2:
          p.quadraticBezierTo(ops[i], ops[i + 1], ops[i + 2], ops[i + 3]);
          i += 4;
        default:
          p.close();
      }
    }
    return p;
  }

  static final Path _symbol = _build(kAerosSymbolPath);
  static final Path _wordmark = _build(kAerosWordmarkPath);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas
      ..save()
      ..scale(size.height);
    if (showSymbol) {
      canvas.drawPath(_symbol, fill);
    } else {
      canvas.translate(-kAerosWordmarkLeft, 0);
    }
    canvas
      ..drawPath(_wordmark, fill)
      ..restore();
  }

  @override
  bool shouldRepaint(AerosLogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.showSymbol != showSymbol;
}
