import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/density.dart';
import '../tokens/typography.dart';
import 'aeros_count_badge.dart';

/// Colour family of an unselected [AerosFilterChip].
enum AerosFilterChipTone {
  /// `bgSubtle` fill, `fgSecondary` label — most filters.
  neutral,

  /// Amber — a filter that is itself a call to action ("Needs attention").
  warning,
}

/// One filter in a row of filters: "All", "Mine 6+", "Stage ▾".
///
/// A fully rounded pill, [AerosDensity.controlHeight] tall (28px pointer, 32px touch). At rest it
/// is [tone]-filled with a w500 label; [selected] fills it `brandPrimary` with a w600 `fgInverse`
/// label. Optional parts, in order: [leadingIcon], the [label], a quieter [count] ("6", or "6+"
/// with [countIsFloor]), a caret when it opens a menu ([dropdown]), and a clear ✕ when it is
/// [selected] and has [onClear].
///
/// At [AerosDensity.touch] the pill keeps its 32px look but the tap target grows to 44px, so a row
/// of chips is still thumb-safe; lay the row out with that height.
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

  /// Tap target height at [AerosDensity.touch].
  static const double touchTargetHeight = 44;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final sem = context.aerosSemantic;
    final d = density ?? AerosDensity.of(context);
    final warning = tone == AerosFilterChipTone.warning;

    final Color fill;
    final Color fg;
    final Color countFg;
    if (selected) {
      fill = a.brandPrimary;
      fg = a.fgInverse;
      countFg = a.fgInverse.withValues(alpha: 0.72);
    } else if (warning) {
      fill = sem.warningBg;
      fg = sem.warningText;
      countFg = sem.warningText.withValues(alpha: 0.8);
    } else {
      fill = a.bgSubtle;
      fg = a.fgSecondary;
      countFg = a.fgMuted;
    }

    final iconSize = d.isPointer ? 14.0 : 16.0;
    final gap = d.isPointer ? 4.0 : 6.0;
    final labelStyle = d.labelStyle(color: fg, weight: selected ? FontWeight.w600 : FontWeight.w500);
    final count = this.count;
    final clearable = selected && onClear != null;

    final pill = Material(
      color: fill,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: d.controlHeight,
          child: Padding(
            padding: EdgeInsets.only(
              left: d.isPointer ? 10 : 12,
              right: clearable ? (d.isPointer ? 4 : 6) : (d.isPointer ? 10 : 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: iconSize, color: fg),
                  SizedBox(width: gap),
                ],
                Text(label, maxLines: 1, style: labelStyle),
                if (count != null) ...[
                  SizedBox(width: gap),
                  Text(
                    AerosCountBadge.label(count, floor: countIsFloor),
                    maxLines: 1,
                    style: labelStyle.copyWith(color: countFg).withWeight(FontWeight.w500),
                  ),
                ],
                if (dropdown) ...[
                  SizedBox(width: gap / 2),
                  Icon(Icons.expand_more_rounded, size: iconSize + 2, color: fg),
                ],
                if (clearable) ...[
                  SizedBox(width: gap / 2),
                  Semantics(
                    button: true,
                    label: 'Clear $label',
                    child: InkResponse(
                      onTap: onClear,
                      radius: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: iconSize, color: fg),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final semantic = Semantics(
      button: true,
      selected: selected,
      child: pill,
    );

    if (d.isPointer) return semantic;

    // Touch: the pill keeps its 32px look; the transparent band around it still taps it.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: touchTargetHeight),
        child: Center(widthFactor: 1, heightFactor: 1, child: semantic),
      ),
    );
  }
}
