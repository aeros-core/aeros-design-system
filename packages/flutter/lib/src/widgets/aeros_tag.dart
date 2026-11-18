import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was blue/grey/dark).
enum AerosTagTone { info, neutral, inverse }

/// A label for a thing — a category, a reference, a keyword.
///
/// The same height as `AerosBadge` ([AerosSizeTokens.badge] for the density),
/// with a tinted fill, a 1px border and a `labelXs` label; the corners are
/// [AerosShapeTokens.item] (a badge is a pill, a tag is not — unless [pill]).
///
/// With [onRemove] the tag is a button that removes it: it shows a ✕, answers
/// hover, press and keyboard focus, and is announced as "Remove <label>". Its
/// tappable box is at least the density's minimum target (24 for a mouse, 48
/// for fingers) around the tag, which keeps its own size.
class AerosTag extends StatelessWidget {
  const AerosTag({
    super.key,
    required this.label,
    this.tone = AerosTagTone.neutral,
    this.onRemove,
    this.pill = false,
    this.expandHitTarget = true,
    this.removeSemanticLabel,
  });

  final String label;
  final AerosTagTone tone;

  /// When non-null the tag shows a trailing ✕ and tapping it (anywhere) calls
  /// this (used by `AerosTagField`).
  final VoidCallback? onRemove;

  /// Fully-rounded ("pill") shape instead of the default [AerosShapeTokens.item].
  final bool pill;

  /// For a removable tag: grow the tappable box to the density's minimum
  /// target (default). Turn off only where the tag sits inside another target
  /// that offers the same action — a tag field, where Backspace also removes.
  final bool expandHitTarget;

  /// Announced for a removable tag. Defaults to "Remove <label>".
  final String? removeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final s = context.aerosSemantic;
    final (Color bg, Color fg, Color border) = switch (tone) {
      AerosTagTone.info => (s.infoBg, s.infoText, s.infoBorder),
      AerosTagTone.neutral => (a.bgSubtle, a.fgSecondary, a.borderDefault),
      AerosTagTone.inverse => (a.bgInverse, a.fgInverse, a.bgInverse),
    };
    final radius = BorderRadius.all(Radius.circular(pill ? AerosShapeTokens.pill : AerosShapeTokens.item));
    final height = AerosDensity.of(context).sizes.badge;
    final removable = onRemove != null;
    const pad = AerosSpacing.s1_5 - AerosMetricTokens.borderHairline;
    final padding = EdgeInsetsDirectional.only(
      start: pill ? AerosSpacing.s2 - AerosMetricTokens.borderHairline : pad,
      end: removable ? AerosSpacing.s1 - AerosMetricTokens.borderHairline : (pill ? AerosSpacing.s2 - AerosMetricTokens.borderHairline : pad),
    );

    // A plain box, not an AerosStateFill: a tag is small enough that its
    // state change needs no animation, and a tag inside a field must not read
    // as a second field frame.
    Widget frame(Color fill, {required bool active}) => Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: AerosMetricTokens.borderHairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1, softWrap: false, style: AerosTypography.labelXs(color: fg)),
              if (removable) ...[
                const SizedBox(width: AerosSpacing.s0_5),
                Icon(
                  Icons.close,
                  size: AerosSizeTokens.iconXs,
                  color: active ? fg : fg.withValues(alpha: AerosMetricTokens.opacityMuted),
                ),
              ],
            ],
          ),
        );

    if (!removable) return frame(bg, active: false);
    return AerosPressable(
      onPressed: onRemove,
      expandHitTarget: expandHitTarget,
      semanticLabel: removeSemanticLabel ?? 'Remove $label',
      excludeSemantics: true,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        radius: radius,
        child: frame(
          // The state overlays are ink and vanish on the inverse fill; there
          // the ✕ alone answers the pointer.
          tone == AerosTagTone.inverse
              ? bg
              : AerosStateLayer.resolve(a, bg, hovered: state.hovered, pressed: state.pressed),
          active: state.hovered || state.pressed || state.focused,
        ),
      ),
    );
  }
}
