import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Surfaces one [AerosRoutingSignal] from the `cart.preview.routing_signals`
/// array. Severity drives colour; the icon is inferred from severity but can
/// be overridden via [iconOverride].
///
/// One of the badge family: a tinted fill, a 1px border in the severity's
/// border colour, [AerosShapeTokens.item] corners and a `labelXs` label.
/// [dense] is the badge height ([AerosSizeTokens.badge]); the default is one
/// step up ([AerosSizeTokens.controlXs]).
///
/// For multiple signals, render a [Wrap] of these.
class AerosRoutingSignalBadge extends StatelessWidget {
  const AerosRoutingSignalBadge({
    super.key,
    required this.signal,
    this.iconOverride,
    this.dense = false,
    this.onTap,
  });

  final AerosRoutingSignal signal;

  /// Override the auto-picked icon (info / warning / error).
  final IconData? iconOverride;

  /// `true` ⇒ badge-height, suitable for inline use next to a button.
  final bool dense;

  /// Tap callback (e.g. open a sheet with the [AerosRoutingSignal.detail]).
  final VoidCallback? onTap;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.item));

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final palette = AerosSeverityPalette.of(context, _mapSeverity(signal.severity));
    final sizes = AerosDensity.of(context).sizes;

    Widget frame({bool hovered = false, bool pressed = false}) => AerosStateFill(
          color: AerosStateLayer.resolve(a, palette.background, hovered: hovered, pressed: pressed),
          borderColor: palette.border,
          radius: _radius,
          constraints: BoxConstraints.tightFor(height: dense ? sizes.badge : sizes.controlXs),
          padding: EdgeInsets.symmetric(
            horizontal: (dense ? AerosSpacing.s1_5 : AerosSpacing.s2) - AerosMetricTokens.borderHairline,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconOverride ?? palette.icon, size: AerosSizeTokens.iconXs, color: palette.foreground),
              const SizedBox(width: AerosSpacing.s1),
              Flexible(
                child: Text(
                  signal.label,
                  style: AerosTypography.labelXs(color: palette.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

    if (onTap == null) return frame();
    return AerosPressable(
      onPressed: onTap,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        radius: _radius,
        child: frame(hovered: state.hovered, pressed: state.pressed),
      ),
    );
  }

  AerosSeverity _mapSeverity(AerosRoutingSeverity s) {
    switch (s) {
      case AerosRoutingSeverity.info:
        return AerosSeverity.info;
      case AerosRoutingSeverity.warn:
        return AerosSeverity.warn;
      case AerosRoutingSeverity.error:
        return AerosSeverity.error;
    }
  }
}
