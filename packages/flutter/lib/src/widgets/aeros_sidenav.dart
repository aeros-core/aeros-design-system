import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Single navigation entry — leaf or expandable parent.
class AerosNavItem {
  const AerosNavItem({
    required this.label,
    this.icon,
    this.children,
    this.onTap,
    this.selected = false,
    this.section,
    this.count = 0,
    this.key,
  });

  final String label;
  final IconData? icon;
  final List<AerosNavItem>? children;
  final VoidCallback? onTap;
  final bool selected;

  /// Group label this top-level item sits under; `null` = the unlabelled group at the top. A label
  /// is drawn wherever the section changes, so keep a section's items contiguous.
  final String? section;

  /// Shown as a count pill when above zero (unread, pending). Announced with the label.
  final int count;

  /// Key for the row — handy for tests (`ValueKey('nav:/orders')`).
  final Key? key;

  bool get hasChildren => children != null && children!.isNotEmpty;

  bool get _containsSelection =>
      selected || (children?.any((c) => c._containsSelection) ?? false);
}

/// Row sizing for an [AerosSidenav], by the pointer that will use it.
enum AerosSidenavDensity {
  /// Mouse and trackpad: 32px rows, 16px icons, 13px labels. The row spans the rail, so its target
  /// is ~216×32 — well above WCAG 2.5.8's 24px minimum.
  pointer(rowHeight: 32, iconSize: 16, labelSize: 13),

  /// Fingers (and gloves): 48px rows, 20px icons, 14px labels.
  touch(rowHeight: 48, iconSize: 20, labelSize: 14);

  const AerosSidenavDensity({required this.rowHeight, required this.iconSize, required this.labelSize});

  final double rowHeight;
  final double iconSize;
  final double labelSize;
}

/// Vertical navigation rail rendered inline on wide layouts or inside a Drawer.
///
/// Spec (shared with the web `Sidebar`):
/// - rows are pills inset [AerosSpacing.s3] from the rail, padded [AerosSpacing.s2], radius
///   [AerosRadii.sm]; with the default padding every leading edge — icon, group label, and whatever
///   [header] / [footer] put at `s5` — sits on one line 20px in;
/// - at rest the label is `fgSecondary` and the icon `fgMuted`; hover fills `borderSubtle` (a step
///   lighter than selection in both themes) and lifts the label to `fgPrimary`; the selected row
///   fills `bgSubtle` and is `fgPrimary` at w600; keyboard focus draws a `borderFocus` ring;
/// - group labels are sentence case, 12px w500 `fgMuted` — they sort the destinations, they do not
///   compete with them;
/// - children indent so their labels align with the parent's label; a parent opens by itself when
///   it holds the selected item.
class AerosSidenav extends StatelessWidget {
  const AerosSidenav({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.density = AerosSidenavDensity.pointer,
    this.padding = const EdgeInsets.fromLTRB(
      AerosSpacing.s3,
      AerosSpacing.s1,
      AerosSpacing.s3,
      AerosSpacing.s3,
    ),
  });

  final List<AerosNavItem> items;
  final Widget? header;
  final Widget? footer;
  final AerosSidenavDensity density;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rows = <Widget>[];
    String? section;
    for (final item in items) {
      if (item.section != section) {
        if (item.section != null) rows.add(_SectionLabel(item.section!));
        section = item.section;
      }
      rows.add(_NavEntry(item: item, depth: 0, density: density, parentHasIcon: false));
    }
    return Container(
      color: a.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Expanded(child: ListView(padding: padding, children: rows)),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AerosSpacing.s2,
        AerosSpacing.s5,
        AerosSpacing.s2,
        AerosSpacing.s1_5,
      ),
      child: Semantics(
        header: true,
        child: Text(title, style: AerosTypography.caption(color: context.aerosColors.fgMuted)),
      ),
    );
  }
}

class _NavEntry extends StatefulWidget {
  const _NavEntry({
    required this.item,
    required this.depth,
    required this.density,
    required this.parentHasIcon,
  });

  final AerosNavItem item;
  final int depth;
  final AerosSidenavDensity density;
  final bool parentHasIcon;

  @override
  State<_NavEntry> createState() => _NavEntryState();
}

class _NavEntryState extends State<_NavEntry> {
  late bool _expanded = widget.item._containsSelection;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final item = widget.item;
    final d = widget.density;
    final selected = item.selected;
    final strong = selected || _hovered;

    // A child's label lines up with its parent's label: past the parent's icon and gap, then one
    // step further per extra level.
    final indent = widget.depth == 0
        ? 0.0
        : (widget.parentHasIcon ? d.iconSize + AerosSpacing.s2_5 : 0.0) +
            (widget.depth - 1) * AerosSpacing.s3;

    final VoidCallback? onTap =
        item.hasChildren ? () => setState(() => _expanded = !_expanded) : item.onTap;

    final row = Padding(
      key: item.key,
      padding: const EdgeInsets.only(bottom: AerosSpacing.s0_5),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        expanded: item.hasChildren ? _expanded : null,
        label: item.count > 0 ? '${item.label}, ${item.count}' : item.label,
        onTap: onTap,
        excludeSemantics: true,
        child: Material(
          color: selected
              ? a.bgSubtle
              : (_hovered && onTap != null ? a.borderSubtle : Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: AerosRadii.brSm,
            side: _focused
                ? BorderSide(color: a.borderFocus, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            onHover: (v) => setState(() => _hovered = v),
            onFocusChange: (v) => setState(() => _focused = v),
            borderRadius: AerosRadii.brSm,
            // The fill is the hover and focus state; Material's own overlays would be a second one.
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: SizedBox(
              height: d.rowHeight,
              child: Padding(
                padding: EdgeInsets.only(left: AerosSpacing.s2 + indent, right: AerosSpacing.s2),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: d.iconSize,
                        color: selected ? a.fgPrimary : (_hovered ? a.fgSecondary : a.fgMuted),
                      ),
                      const SizedBox(width: AerosSpacing.s2_5),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AerosTypography.bodySm(color: strong ? a.fgPrimary : a.fgSecondary)
                            .withWeight(selected ? FontWeight.w600 : FontWeight.w500)
                            .copyWith(fontSize: d.labelSize, height: 1.3),
                      ),
                    ),
                    if (item.count > 0) _CountPill(item.count),
                    if (item.hasChildren)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: AerosMotion.resolve(context, AerosMotion.fast),
                        curve: AerosMotion.standard,
                        child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: a.fgMuted),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!item.hasChildren || !_expanded) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        for (final child in item.children!)
          _NavEntry(
            item: child,
            depth: widget.depth + 1,
            density: d,
            parentHasIcon: widget.depth == 0 ? item.icon != null : widget.parentHasIcon,
          ),
      ],
    );
  }
}

/// The one decisive accent in the rail: something is waiting.
class _CountPill extends StatelessWidget {
  const _CountPill(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1_5),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: a.brandPrimary, borderRadius: AerosRadii.brFull),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AerosTypography.labelXs(color: a.fgInverse),
      ),
    );
  }
}
