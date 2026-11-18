import 'package:flutter/material.dart';

import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/motion.dart';

/// Resolves the fill of an interactive surface for its state.
///
/// Aeros controls change colour only — no ripple, no lift. The hover, pressed
/// and selected states are the translucent `stateHover` / `statePressed` /
/// `stateSelected` aliases composited over the surface the control rests on,
/// so one rule works on any background and in both themes.
class AerosStateLayer {
  AerosStateLayer._();

  /// [base] with the overlay for the given state composited on top.
  ///
  /// Selected sits under hover / pressed, so a selected row still answers the
  /// pointer. Pressed wins over hovered. A disabled control keeps its resting
  /// (or selected) fill.
  static Color resolve(
    AerosAliasColors aliases,
    Color base, {
    bool hovered = false,
    bool pressed = false,
    bool selected = false,
    bool enabled = true,
  }) {
    var color = base;
    if (selected) color = Color.alphaBlend(aliases.stateSelected, color);
    if (!enabled) return color;
    if (pressed) return Color.alphaBlend(aliases.statePressed, color);
    if (hovered) return Color.alphaBlend(aliases.stateHover, color);
    return color;
  }

  /// How long a state change takes: [AerosMotion.quick], or zero when the
  /// platform asks for reduced motion.
  static Duration duration(BuildContext context) => AerosMotion.resolve(context, AerosMotion.quick);

  /// The curve state changes ease along.
  static const Curve curve = AerosMotion.standard;
}

/// A filled, optionally bordered box that animates between state colours with
/// [AerosStateLayer.duration]. Pair it with [AerosStateLayer.resolve].
///
/// The border is always [AerosMetricTokens.borderHairline] wide — pass a
/// transparent [borderColor] for none — so a control never changes size when
/// its border appears.
class AerosStateFill extends StatelessWidget {
  const AerosStateFill({
    super.key,
    required this.color,
    required this.child,
    this.borderColor,
    this.radius = const BorderRadius.all(Radius.circular(AerosShapeTokens.control)),
    this.padding,
    this.constraints,
  });

  final Color color;
  final Color? borderColor;
  final BorderRadius radius;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AerosStateLayer.duration(context),
      curve: AerosStateLayer.curve,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: AerosMetricTokens.borderHairline,
        ),
      ),
      child: child,
    );
  }
}
