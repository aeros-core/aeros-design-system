import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';

/// A radio button: a 16px circle with a hairline, solid `brandPrimary` with an
/// `fgInverse` dot when it is the selected value of its group.
///
/// Pass `onChanged: null` or `enabled: false` to disable it.
class AerosRadio<T> extends StatelessWidget {
  const AerosRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.compact = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final T value;
  final T? groupValue;

  /// Called with [value] when this radio is chosen. Null disables it.
  final ValueChanged<T?>? onChanged;

  /// Shrinks the hit area to the 16px circle for dense desktop tables. The
  /// default pads it to the density's minimum target (24 pointer, 44 touch).
  final bool compact;

  /// False disables the radio even when [onChanged] is set.
  final bool enabled;

  /// Announced by screen readers when the radio has no visible label of its own.
  final String? semanticLabel;

  static const double _size = AerosSizeTokens.iconMd;
  static const double _dot = AerosSpacing.s1_5;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.pill));

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final selected = value == groupValue;
    final interactive = enabled && onChanged != null;

    return AerosPressable(
      onPressed: interactive ? () => onChanged!(value) : null,
      button: false,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      expandHitTarget: !compact,
      semanticLabel: semanticLabel,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        final fill = selected
            ? (active ? a.brandPrimaryHover : a.brandPrimary)
            : AerosStateLayer.resolve(a, a.bgSurface, hovered: state.hovered, pressed: state.pressed);
        return Opacity(
          opacity: state.enabled ? 1 : AerosMetricTokens.opacityDisabled,
          child: AerosFocusRing(
            focused: state.focused,
            radius: _radius,
            child: AerosStateFill(
              color: fill,
              borderColor: selected ? fill : a.borderStrong,
              radius: _radius,
              constraints: const BoxConstraints.tightFor(width: _size, height: _size),
              child: Center(
                child: CustomPaint(
                  size: const Size.square(_dot),
                  painter: selected ? _DotPainter(a.fgInverse) : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.color != color;
}
