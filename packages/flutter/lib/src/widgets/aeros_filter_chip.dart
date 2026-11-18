import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_count_badge.dart';

/// Colour family of an unselected [AerosFilterChip].
enum AerosFilterChipTone {
  /// `bgSubtle` fill, `borderDefault` hairline, `fgSecondary` label — most filters.
  neutral,

  /// Amber — a filter that is itself a call to action ("Needs attention").
  warning,
}

/// One filter in a row of filters: "All", "Mine 6+", "Stage ▾".
///
/// A fully rounded pill, [AerosDensity.controlHeight] tall (28px pointer, 32px touch), with a 1px
/// hairline. At rest it is [tone]-tinted with a w500 label; [selected] fills it `brandPrimary` with
/// a w600 `fgInverse` label. Hover and press change the fill only; keyboard focus draws the focus
/// ring. Optional parts, in order: [leadingIcon], the [label], a quieter [count] ("6", or "6+" with
/// [countIsFloor]), a caret when it opens a menu ([dropdown]), and a clear ✕ when it is [selected]
/// and has [onClear].
///
/// At [AerosDensity.touch] the pill keeps its 32px look but the tap target grows to the minimum
/// target ([touchTargetHeight]), so a row of chips is still thumb-safe; lay the row out with that
/// height.
///
/// Lay several out in a horizontally scrolling row; one filter axis per chip group.
class AerosFilterChip extends StatelessWidget {
  const AerosFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.count,
    this.countIsFloor = false,
    this.leadingIcon,
    this.dropdown = false,
    this.onClear,
    this.tone = AerosFilterChipTone.neutral,
    this.density,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// A count after the label; null shows none.
  final int? count;

  /// [count] is a lower bound — render "N+".
  final bool countIsFloor;

  final IconData? leadingIcon;

  /// The chip opens a menu: draw a caret after the label.
  final bool dropdown;

  /// Shown as a ✕ while [selected]; clears the filter without opening anything.
  final VoidCallback? onClear;

  final AerosFilterChipTone tone;

  /// Overrides the ambient [AerosDensity].
  final AerosDensity? density;

  /// Tap target height at [AerosDensity.touch]: the touch minimum target token.
  static double get touchTargetHeight => AerosSizeTokens.touch.minTarget;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.pill));

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final sem = context.aerosSemantic;
    final d = density ?? AerosDensity.of(context);
    final warning = tone == AerosFilterChipTone.warning;

    final Color fill;
    final Color border;
    final Color fg;
    if (selected) {
      fill = a.brandPrimary;
      border = a.brandPrimary;
      fg = a.fgInverse;
    } else if (warning) {
      fill = sem.warningBg;
      border = sem.warningBorder;
      fg = sem.warningText;
    } else {
      fill = a.bgSubtle;
      border = a.borderDefault;
      fg = a.fgSecondary;
    }
    // The count is quieter than the label, but still readable text: the
    // warning tint is too light to take a faded amber.
    final quiet = selected
        ? fg.withValues(alpha: AerosMetricTokens.opacityMuted)
        : (warning ? fg : a.fgMuted);

    final iconSize = d.isPointer ? AerosSizeTokens.iconSm : AerosSizeTokens.iconMd;
    final gap = d.isPointer ? AerosSpacing.s1 : AerosSpacing.s1_5;
    final padH = (d.isPointer ? AerosSpacing.s2_5 : AerosSpacing.s3) - AerosMetricTokens.borderHairline;
    final labelStyle = AerosTypography.labelSm(color: fg, weight: selected ? FontWeight.w600 : FontWeight.w500);
    final count = this.count;
    final clearable = selected && onClear != null;
    // The ✕ is its own button, laid over the end of the pill: the pill leaves
    // this much room for it.
    final clearSlot = iconSize + AerosSpacing.s1 * 2;
    const clearInset = AerosSpacing.s1;

    final chip = AerosPressable(
      onPressed: onTap,
      selected: selected,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        // The state overlays are ink and vanish on the solid brand fill, so
        // the selected chip swaps to the brand hover colour instead.
        final color = selected
            ? (active ? a.brandPrimaryHover : fill)
            : AerosStateLayer.resolve(a, fill, hovered: state.hovered, pressed: state.pressed);
        return AerosFocusRing(
          focused: state.focused,
          radius: _radius,
          child: AerosStateFill(
            color: color,
            borderColor: selected ? color : border,
            radius: _radius,
            constraints: BoxConstraints.tightFor(height: d.controlHeight),
            padding: EdgeInsetsDirectional.only(
              start: padH,
              end: clearable ? clearSlot + clearInset : padH,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: iconSize, color: fg),
                  SizedBox(width: gap),
                ],
                Text(label, maxLines: 1, softWrap: false, style: labelStyle),
                if (count != null) ...[
                  SizedBox(width: gap),
                  Text(
                    AerosCountBadge.label(count, floor: countIsFloor),
                    maxLines: 1,
                    softWrap: false,
                    style: AerosTypography.labelSm(color: quiet),
                  ),
                ],
                if (dropdown) ...[
                  const SizedBox(width: AerosSpacing.s0_5),
                  Icon(Icons.expand_more_rounded, size: iconSize, color: fg),
                ],
                if (clearable) const SizedBox(width: AerosSpacing.s0_5),
              ],
            ),
          ),
        );
      },
    );

    if (!clearable) return chip;
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        chip,
        PositionedDirectional(
          end: clearInset,
          top: 0,
          bottom: 0,
          child: Center(
            child: AerosPressable(
              onPressed: onClear,
              // Sits inside the chip's own target.
              expandHitTarget: false,
              semanticLabel: 'Clear $label',
              excludeSemantics: true,
              builder: (context, state) => AerosFocusRing(
                focused: state.focused,
                radius: _radius,
                placement: AerosFocusRingPlacement.inset,
                child: SizedBox.square(
                  dimension: clearSlot,
                  child: Icon(
                    Icons.close_rounded,
                    size: iconSize,
                    color: state.hovered || state.pressed || state.focused ? fg : quiet,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
