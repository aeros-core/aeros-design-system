import 'package:flutter/widgets.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';

/// The colour of a focus ring.
enum AerosFocusRingTone {
  /// `aliases.focusRing`.
  neutral,

  /// The semantic danger colour — a field in error, a destructive button.
  danger,
}

/// Where the ring sits relative to the edge of its child.
enum AerosFocusRingPlacement {
  /// Outside, with a gap ([AerosMetricTokens.focusOffset]) — buttons, toggles.
  outside,

  /// Straddling the border ([AerosMetricTokens.focusOffsetField]) — fields.
  field,

  /// Inside the edge ([AerosMetricTokens.focusOffsetInset]) — rows and cells
  /// that are clipped by their parent.
  inset,
}

/// The one focus treatment: a ring of [AerosMetricTokens.focusWidth] around
/// [child].
///
/// The ring is painted over the child by a foreground painter, outside its
/// box, so focus never changes the layout. Buttons and toggles pass keyboard
/// focus only (`AerosInteraction.focused`); a text input shows it whenever it
/// has focus.
class AerosFocusRing extends StatelessWidget {
  const AerosFocusRing({
    super.key,
    required this.focused,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(AerosShapeTokens.control)),
    this.tone = AerosFocusRingTone.neutral,
    this.placement = AerosFocusRingPlacement.outside,
  });

  final bool focused;
  final BorderRadius radius;
  final AerosFocusRingTone tone;
  final AerosFocusRingPlacement placement;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      AerosFocusRingTone.neutral => context.aerosColors.focusRing,
      AerosFocusRingTone.danger => context.aerosSemantic.danger,
    };
    final offset = switch (placement) {
      AerosFocusRingPlacement.outside => AerosMetricTokens.focusOffset,
      AerosFocusRingPlacement.field => AerosMetricTokens.focusOffsetField,
      AerosFocusRingPlacement.inset => AerosMetricTokens.focusOffsetInset,
    };
    return CustomPaint(
      foregroundPainter: focused
          ? _FocusRingPainter(color: color, width: AerosMetricTokens.focusWidth, offset: offset, radius: radius)
          : null,
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({required this.color, required this.width, required this.offset, required this.radius});

  final Color color;
  final double width;

  /// Distance from the child's edge to the ring's inner edge (negative = inside).
  final double offset;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    // The stroke is centred on its path, so the path sits half a width
    // further out than the ring's inner edge.
    final delta = offset + width / 2;
    Radius grow(Radius r) => Radius.elliptical(
          (r.x + delta).clamp(0.0, double.infinity),
          (r.y + delta).clamp(0.0, double.infinity),
        );
    final rect = (Offset.zero & size).inflate(delta);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: grow(radius.topLeft),
      topRight: grow(radius.topRight),
      bottomLeft: grow(radius.bottomLeft),
      bottomRight: grow(radius.bottomRight),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.color != color || old.width != width || old.offset != offset || old.radius != radius;
}
