import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';

/// A checkbox: a 16px box with a hairline, solid `brandPrimary` when checked
/// (or mixed), with the mark drawn in `fgInverse`.
///
/// Pass `onChanged: null` or `enabled: false` to disable it.
class AerosCheckbox extends StatelessWidget {
  const AerosCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.compact = false,
    this.enabled = true,
    this.semanticLabel,
  });

  /// True, false, or — with [tristate] — null for the mixed state.
  final bool? value;

  /// Null disables the checkbox.
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  /// Shrinks the hit area to the 16px box for dense desktop tables. The
  /// default pads the box to the density's minimum target (24 pointer, 44
  /// touch) — only opt into compact where rows are keyboard/mouse-first.
  final bool compact;

  /// False disables the checkbox even when [onChanged] is set.
  final bool enabled;

  /// Announced by screen readers when the checkbox has no visible label of its own.
  final String? semanticLabel;

  static const double _box = AerosSizeTokens.iconMd;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.item));

  void _toggle() {
    switch (value) {
      case false:
        onChanged!(true);
      case true:
        onChanged!(tristate ? null : false);
      case null:
        onChanged!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final marked = value != false;
    final interactive = enabled && onChanged != null;

    return AerosPressable(
      onPressed: interactive ? _toggle : null,
      button: false,
      checked: value == true,
      mixed: tristate ? value == null : null,
      expandHitTarget: !compact,
      semanticLabel: semanticLabel,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        final fill = marked
            ? (active ? a.brandPrimaryHover : a.brandPrimary)
            : AerosStateLayer.resolve(a, a.bgSurface, hovered: state.hovered, pressed: state.pressed);
        return Opacity(
          opacity: state.enabled ? 1 : AerosMetricTokens.opacityDisabled,
          child: AerosFocusRing(
            focused: state.focused,
            radius: _radius,
            child: AerosStateFill(
              color: fill,
              borderColor: marked ? fill : a.borderStrong,
              radius: _radius,
              constraints: const BoxConstraints.tightFor(width: _box, height: _box),
              child: CustomPaint(
                painter: _MarkPainter(
                  color: a.fgInverse,
                  mark: value == null
                      ? _Mark.dash
                      : value!
                          ? _Mark.check
                          : _Mark.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _Mark { none, check, dash }

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.color, required this.mark});

  final Color color;
  final _Mark mark;

  @override
  void paint(Canvas canvas, Size size) {
    if (mark == _Mark.none) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AerosMetricTokens.borderThick
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final path = Path();
    switch (mark) {
      case _Mark.check:
        path
          ..moveTo(w * 0.20, h * 0.52)
          ..lineTo(w * 0.41, h * 0.73)
          ..lineTo(w * 0.80, h * 0.29);
      case _Mark.dash:
        path
          ..moveTo(w * 0.22, h * 0.5)
          ..lineTo(w * 0.78, h * 0.5);
      case _Mark.none:
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color || old.mark != mark;
}
