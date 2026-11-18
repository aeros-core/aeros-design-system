import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';

/// A switch: a 32×18 monochrome track. Off is a hairline outline with a muted
/// thumb; on is solid `brandPrimary` with an `fgInverse` thumb. The same on
/// every platform (no Cupertino variant).
///
/// Pass `onChanged: null` or `enabled: false` to disable it.
class AerosSwitch extends StatelessWidget {
  const AerosSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Shrinks the hit area to the track for dense desktop rows. The default
  /// pads it to the density's minimum target (24 pointer, 44 touch).
  final bool compact;

  /// False disables the switch even when [onChanged] is set.
  final bool enabled;

  /// Announced by screen readers when the switch has no visible label of its own.
  final String? semanticLabel;

  // 14px thumb, inset 2px on every side: an 18px-high track, 32px wide.
  static const double _thumb = AerosSizeTokens.iconSm;
  static const double _inset = AerosMetricTokens.borderThick;
  static const double _trackWidth = AerosSpacing.s8;
  static const double _trackHeight = _thumb + 2 * _inset;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.pill));

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final interactive = enabled && onChanged != null;

    return AerosPressable(
      onPressed: interactive ? () => onChanged!(!value) : null,
      button: false,
      toggled: value,
      expandHitTarget: !compact,
      semanticLabel: semanticLabel,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        final track = value
            ? (active ? a.brandPrimaryHover : a.brandPrimary)
            : AerosStateLayer.resolve(a, a.bgSubtle, hovered: state.hovered, pressed: state.pressed);
        return Opacity(
          opacity: state.enabled ? 1 : AerosMetricTokens.opacityDisabled,
          child: AerosFocusRing(
            focused: state.focused,
            radius: _radius,
            child: AerosStateFill(
              color: track,
              borderColor: value ? track : a.borderStrong,
              radius: _radius,
              constraints: const BoxConstraints.tightFor(width: _trackWidth, height: _trackHeight),
              // The hairline is part of the box and comes off the inset.
              padding: const EdgeInsets.all(_inset - AerosMetricTokens.borderHairline),
              child: AnimatedAlign(
                duration: AerosMotion.resolve(context, AerosMotion.fast),
                curve: AerosMotion.standard,
                alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                child: AnimatedContainer(
                  duration: AerosStateLayer.duration(context),
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    color: value ? a.fgInverse : a.fgMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
