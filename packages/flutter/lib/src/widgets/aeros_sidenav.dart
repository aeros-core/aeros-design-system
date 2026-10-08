import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
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

/// Height of the rail's top and bottom blocks ([AerosSidenavHeader], [AerosSidenavFooter]). It is
/// the height of an app header bar, so the rail's first block sits level with the page title.
const double kAerosSidenavBlockHeight = 56;

const double _rowGap = AerosSpacing.s0_5; // between rows, so a hovered pill never fuses with the selected one
const double _labelGap = AerosSpacing.s1_5; // under a group label
const double _iconGap = AerosSpacing.s2_5; // icon to label

/// Gutter between the rail's edge and a row's pill, and the padding inside the pill. Together they
/// put every leading edge — the header mark, icons, group labels, the footer avatar — 20px in.
const double _inset = AerosSpacing.s3;
const double _pad = AerosSpacing.s2;

/// Vertical navigation rail rendered inline on wide layouts or inside a Drawer.
///
/// Spec (shared with the web `Sidebar`):
/// - rows are pills inset [AerosSpacing.s3] from the rail, padded [AerosSpacing.s2], radius
///   [AerosRadii.sm]; with the default padding every leading edge — icon, group label, and the
///   [AerosSidenavHeader] mark / [AerosSidenavFooter] avatar — sits on one line 20px in;
/// - at rest the label is `fgSecondary` and the icon `fgMuted`; hover fills halfway between
///   `bgSurface` and `bgSubtle` (a step lighter than selection in both themes) and lifts the label
///   to `fgPrimary`; the selected row fills `bgSubtle` and is `fgPrimary` at w600; keyboard focus
///   draws a `borderFocus` ring;
/// - group labels are sentence case, 12px w500 `fgMuted` — they sort the destinations, they do not
///   compete with them;
/// - children indent so their labels align with the parent's label; a parent opens by itself when
///   it holds the selected item.
///
/// Put an [AerosSidenavHeader] in [header] (the workspace, and the way to switch it) and an
/// [AerosSidenavFooter] in [footer] (who is signed in, and sign out). Both are
/// [kAerosSidenavBlockHeight] tall.
class AerosSidenav extends StatelessWidget {
  const AerosSidenav({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.density = AerosSidenavDensity.pointer,
    this.padding = const EdgeInsets.fromLTRB(_inset, AerosSpacing.s1, _inset, AerosSpacing.s3),
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

/// Hover sits halfway between the rail and the selected fill. No single alias token does that in
/// both themes: `borderSubtle` is darker than `bgSubtle` in light, `bgCanvas` darker than the
/// surface in dark.
Color _hoverFill(AerosAliasColors a) => Color.lerp(a.bgSurface, a.bgSubtle, 0.5)!;

/// The pill every interactive thing in the rail shares: transparent at rest, [_hoverFill] under the
/// pointer, `bgSubtle` when [selected], a `borderFocus` ring under keyboard focus.
class _RailPill extends StatefulWidget {
  const _RailPill({
    required this.onTap,
    required this.builder,
    this.selected = false,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: _pad),
  });

  final VoidCallback? onTap;
  final bool selected;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<_RailPill> createState() => _RailPillState();
}

class _RailPillState extends State<_RailPill> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hovered = _hovered && widget.onTap != null;
    return Material(
      color: widget.selected ? a.bgSubtle : (hovered ? _hoverFill(a) : Colors.transparent),
      shape: RoundedRectangleBorder(
        borderRadius: AerosRadii.brSm,
        side: _focused ? BorderSide(color: a.borderFocus, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hovered = v),
        onFocusChange: (v) => setState(() => _focused = v),
        borderRadius: AerosRadii.brSm,
        // The fill is the hover and focus state; Material's own overlays would be a second one.
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: SizedBox(
          height: widget.height,
          child: Padding(padding: widget.padding, child: widget.builder(context, hovered)),
        ),
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
      padding: const EdgeInsets.fromLTRB(_pad, AerosSpacing.s5, _pad, _labelGap),
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

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final item = widget.item;
    final d = widget.density;
    final selected = item.selected;

    // A child's label lines up with its parent's label: past the parent's icon and gap, then one
    // step further per extra level.
    final indent = widget.depth == 0
        ? 0.0
        : (widget.parentHasIcon ? d.iconSize + _iconGap : 0.0) + (widget.depth - 1) * AerosSpacing.s3;

    final VoidCallback? onTap =
        item.hasChildren ? () => setState(() => _expanded = !_expanded) : item.onTap;

    final row = Padding(
      key: item.key,
      padding: const EdgeInsets.only(bottom: _rowGap),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        expanded: item.hasChildren ? _expanded : null,
        label: item.count > 0 ? '${item.label}, ${item.count}' : item.label,
        onTap: onTap,
        excludeSemantics: true,
        child: _RailPill(
          onTap: onTap,
          selected: selected,
          height: d.rowHeight,
          padding: EdgeInsets.only(left: _pad + indent, right: _pad),
          builder: (context, hovered) {
            final strong = selected || hovered;
            return Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: d.iconSize,
                    color: selected ? a.fgPrimary : (hovered ? a.fgSecondary : a.fgMuted),
                  ),
                  const SizedBox(width: _iconGap),
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
            );
          },
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
      padding: const EdgeInsets.symmetric(horizontal: _labelGap),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: a.brandPrimary, borderRadius: AerosRadii.brFull),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AerosTypography.labelXs(color: a.fgInverse),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//   Top and bottom blocks
// ═══════════════════════════════════════════════════════════════════════

/// The 24px rounded square that marks a workspace at the head of the rail: an [icon] or a
/// [letter] in `fgInverse` on `brandPrimary`.
class AerosSidenavMark extends StatelessWidget {
  const AerosSidenavMark({super.key, this.icon, this.letter})
      : assert(icon != null || letter != null, 'Give the mark an icon or a letter');

  final IconData? icon;
  final String? letter;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: a.brandPrimary, borderRadius: AerosRadii.brSm),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 14, color: a.fgInverse)
          : Text(
              letter!.isEmpty ? '' : letter!.characters.first.toUpperCase(),
              style: AerosTypography.labelSm(color: a.fgInverse).withWeight(FontWeight.w700),
            ),
    );
  }
}

/// The rail's top block: which workspace this is, and — when [onTap] is set — the way to another
/// one, signalled by an unfold chevron. Where Stripe, Linear and Vercel all keep it.
///
/// [mark] is drawn at 24px; it defaults to an [AerosSidenavMark] with the title's first letter.
class AerosSidenavHeader extends StatelessWidget {
  const AerosSidenavHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.mark,
    this.onTap,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? mark;
  final VoidCallback? onTap;

  /// Announced instead of the title — e.g. 'Switch account — Acme Ltd'.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final sub = subtitle?.trim() ?? '';
    return SizedBox(
      height: kAerosSidenavBlockHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _inset, vertical: AerosSpacing.s2),
        child: Semantics(
          button: onTap != null,
          label: semanticLabel ?? title,
          onTap: onTap,
          excludeSemantics: true,
          child: _RailPill(
            onTap: onTap,
            builder: (context, _) => Row(
              children: [
                SizedBox.square(dimension: 24, child: mark ?? AerosSidenavMark(letter: title)),
                const SizedBox(width: _iconGap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AerosTypography.labelSm(color: a.fgPrimary),
                      ),
                      if (sub.isNotEmpty)
                        Text(
                          sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AerosTypography.caption(color: a.fgMuted).copyWith(height: 1.25),
                        ),
                    ],
                  ),
                ),
                if (onTap != null) Icon(Icons.unfold_more_rounded, size: 16, color: a.fgMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The rail's bottom block: who is signed in, and one action beside them (sign out). Drawn under a
/// `borderSubtle` rule.
///
/// [avatar] is drawn at 24px; it defaults to the name's initial on a `bgSubtle` circle. The action
/// shows when [actionIcon] and [onAction] are both set; [actionLabel] is its tooltip and its
/// announced name.
class AerosSidenavFooter extends StatelessWidget {
  const AerosSidenavFooter({
    super.key,
    required this.name,
    this.subtitle,
    this.avatar,
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.actionKey,
  });

  final String name;
  final String? subtitle;
  final Widget? avatar;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Key for the action button — handy for tests (`ValueKey('action:sign-out')`).
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final who = name.trim();
    final sub = subtitle?.trim() ?? '';
    return Container(
      height: kAerosSidenavBlockHeight,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: a.borderSubtle))),
      padding: const EdgeInsets.only(left: _inset + _pad, right: AerosSpacing.s2),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 24,
            child: avatar ??
                Container(
                  decoration: BoxDecoration(color: a.bgSubtle, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    who.isEmpty ? '' : who.characters.first.toUpperCase(),
                    style: AerosTypography.labelXs(color: a.fgSecondary),
                  ),
                ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  who,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AerosTypography.labelSm(color: a.fgPrimary),
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AerosTypography.caption(color: a.fgMuted).copyWith(height: 1.25),
                  ),
              ],
            ),
          ),
          if (actionIcon != null && onAction != null) _action(context, a),
        ],
      ),
    );
  }

  Widget _action(BuildContext context, AerosAliasColors a) {
    final button = Semantics(
      button: true,
      label: actionLabel,
      onTap: onAction,
      excludeSemantics: true,
      child: SizedBox.square(
        key: actionKey,
        dimension: 32,
        child: _RailPill(
          onTap: onAction,
          padding: EdgeInsets.zero,
          builder: (context, hovered) => Center(
            child: Icon(actionIcon, size: 18, color: hovered ? a.fgPrimary : a.fgSecondary),
          ),
        ),
      ),
    );
    final label = actionLabel ?? '';
    // A web shell often draws its rail above the app's Navigator (`MaterialApp.builder`), where
    // there is no Overlay and a Tooltip throws. The label is still announced without one.
    if (label.isEmpty || Overlay.maybeOf(context) == null) return button;
    return Tooltip(
      message: label,
      waitDuration: AerosMotion.slow,
      excludeFromSemantics: true,
      child: button,
    );
  }
}
