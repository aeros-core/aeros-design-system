import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_avatar.dart';
import 'aeros_count_badge.dart';

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
///
/// 3.0: the numbers are the `navRow` / `navIcon` / `navLabel` size tokens
/// ([AerosSizeTokens.pointer] and [AerosSizeTokens.touch]); this enum only
/// picks the set.
enum AerosSidenavDensity {
  /// Mouse and trackpad: 32px rows, 16px icons, 13px labels. The row spans the rail, so its target
  /// is ~216×32 — well above WCAG 2.5.8's 24px minimum.
  pointer,

  /// Fingers (and gloves): 48px rows, 20px icons, 14px labels.
  touch;

  /// The size tokens this density reads.
  AerosSizeTokens get sizes => this == pointer ? AerosSizeTokens.pointer : AerosSizeTokens.touch;

  /// The matching [AerosDensity].
  AerosDensity get density => this == pointer ? AerosDensity.pointer : AerosDensity.touch;

  double get rowHeight => sizes.navRow;
  double get iconSize => sizes.navIcon;
  double get labelSize => sizes.navLabel;

  /// A row label: the label role whose size is [labelSize].
  TextStyle labelStyle({Color? color, FontWeight? weight}) => this == pointer
      ? AerosTypography.labelSm(color: color, weight: weight)
      : AerosTypography.labelMd(color: color, weight: weight);
}

/// Height of the rail's top and bottom blocks at touch density.
///
/// 3.0: the blocks are one app header high for the *ambient* density
/// ([AerosSizeTokens.header]: 48 inside an `AerosDensityScope(density:
/// pointer)`, 56 at touch or with no scope), so they line up with
/// `AerosTopnav` and `AerosPageHeader`.
@Deprecated('Use AerosDensity.of(context).sizes.header')
double get kAerosSidenavBlockHeight => AerosSizeTokens.touch.header;

const double _rowGap = AerosSpacing.s0_5; // between rows, so a hovered row never fuses with the selected one
const double _labelGap = AerosSpacing.s1_5; // under a group label
const double _iconGap = AerosSpacing.s2_5; // icon to label

/// Gutter between the rail's edge and a row, and the padding inside the row. Together they put
/// every leading edge — the header mark, icons, group labels, the footer avatar — 20px in.
const double _inset = AerosSpacing.s3;
const double _pad = AerosSpacing.s2;

const BorderRadius _itemRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.item));

/// Forces every [AerosSidenav] below it to show the full rail, whatever its
/// [AerosSidenav.collapsed] says. `AerosScaffold` wraps its drawer in one: an
/// icon-only rail makes no sense in a sheet.
class AerosSidenavExpanded extends InheritedWidget {
  const AerosSidenavExpanded({super.key, required super.child});

  static bool _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AerosSidenavExpanded>() != null;

  @override
  bool updateShouldNotify(AerosSidenavExpanded oldWidget) => false;
}

/// Tells the blocks inside a rail whether it is collapsed to icons.
class _RailScope extends InheritedWidget {
  const _RailScope({required this.collapsed, required super.child});

  final bool collapsed;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RailScope>()?.collapsed ?? false;

  @override
  bool updateShouldNotify(_RailScope oldWidget) => oldWidget.collapsed != collapsed;
}

/// Vertical navigation rail rendered inline on wide layouts or inside a Drawer.
///
/// Spec (shared with the web `Sidebar`):
/// - it is [AerosMetricTokens.layoutSidebar] (240) wide — its parent sets the width — and
///   [AerosMetricTokens.layoutSidebarRail] (56) when [collapsed] to icons;
/// - rows are inset [AerosSpacing.s3] from the rail and padded [AerosSpacing.s2], with
///   [AerosShapeTokens.item] corners; every leading edge — icon, group label, and the
///   [AerosSidenavHeader] mark / [AerosSidenavFooter] avatar — sits on one line 20px in;
/// - row height, icon size and label size are the `navRow` / `navIcon` / `navLabel` size tokens for
///   the [density];
/// - at rest the label is `fgSecondary` and the icon `fgMuted`; hover and press lay the
///   `stateHover` / `statePressed` overlay on the rail and lift the label to `fgPrimary`; the
///   selected row fills `bgSubtle` and is `fgPrimary` at w600; keyboard focus draws the focus ring;
///   nothing ripples;
/// - group labels are sentence case, `caption` in `fgMuted` — they sort the destinations, they do
///   not compete with them;
/// - children indent so their labels align with the parent's label; a parent opens by itself when
///   it holds the selected item.
///
/// Put an [AerosSidenavHeader] in [header] (the workspace, and the way to switch it) and an
/// [AerosSidenavFooter] in [footer] (who is signed in, and sign out). Both are one app header high
/// ([AerosSizeTokens.header] for the ambient [AerosDensity]), like `AerosTopnav`.
///
/// [collapsed] shows icons only: labels become tooltips, group labels become hairlines, children
/// are hidden (tapping a parent calls [onExpandRequested]), and the header and footer keep only
/// their mark and avatar. Every row is still announced by its full label.
class AerosSidenav extends StatelessWidget {
  const AerosSidenav({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.density = AerosSidenavDensity.pointer,
    this.collapsed = false,
    this.onExpandRequested,
    this.padding = const EdgeInsets.fromLTRB(_inset, AerosSpacing.s2, _inset, AerosSpacing.s3),
  });

  final List<AerosNavItem> items;
  final Widget? header;
  final Widget? footer;
  final AerosSidenavDensity density;

  /// Icon-only rail ([AerosMetricTokens.layoutSidebarRail] wide).
  final bool collapsed;

  /// Called when a collapsed rail should open: a parent row was tapped, and its children have
  /// nowhere to show.
  final VoidCallback? onExpandRequested;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rail = collapsed && !AerosSidenavExpanded._of(context);
    final rows = <Widget>[];
    String? section;
    for (final item in items) {
      if (item.section != section) {
        if (item.section != null) rows.add(_SectionLabel(item.section!, rail: rail));
        section = item.section;
      }
      rows.add(_NavEntry(
        item: item,
        depth: 0,
        density: density,
        parentHasIcon: false,
        rail: rail,
        onExpandRequested: onExpandRequested,
      ));
    }
    return _RailScope(
      collapsed: rail,
      child: Container(
        color: a.bgSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header!,
            Expanded(child: ListView(padding: padding, children: rows)),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

/// The fill every interactive thing in the rail shares: the rail's own colour at rest, the state
/// overlay under the pointer, `bgSubtle` when [selected] — inside the focus ring.
class _RailFill extends StatelessWidget {
  const _RailFill({
    required this.state,
    required this.child,
    this.selected = false,
    this.height,
    this.padding,
  });

  final AerosInteraction state;
  final bool selected;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return AerosFocusRing(
      focused: state.focused,
      radius: _itemRadius,
      // Rows are clipped by the scrolling list: the ring goes inside.
      placement: AerosFocusRingPlacement.inset,
      child: AerosStateFill(
        color: AerosStateLayer.resolve(
          a,
          selected ? a.bgSubtle : a.bgSurface,
          hovered: state.hovered,
          pressed: state.pressed,
        ),
        radius: _itemRadius,
        constraints: BoxConstraints.tightFor(height: height),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Shows [label] as a tooltip when there is an Overlay to show it in.
///
/// A web shell often draws its rail above the app's Navigator (`MaterialApp.builder`), where there
/// is no Overlay and a Tooltip throws. The label is still announced without one.
Widget _withTooltip(BuildContext context, String label, Widget child) {
  if (label.isEmpty || Overlay.maybeOf(context) == null) return child;
  return Tooltip(
    message: label,
    waitDuration: AerosMotion.slow,
    excludeFromSemantics: true,
    child: child,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.rail});
  final String title;
  final bool rail;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    if (rail) {
      // No room for the words: a hairline marks the group, the name is still announced.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AerosSpacing.s2),
        child: Semantics(
          header: true,
          label: title,
          child: ColoredBox(
            color: a.borderDefault,
            child: const SizedBox(height: AerosMetricTokens.borderHairline),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(_pad, AerosSpacing.s4, _pad, _labelGap),
      child: Semantics(
        header: true,
        child: Text(title, style: AerosTypography.caption(color: a.fgMuted)),
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
    required this.rail,
    required this.onExpandRequested,
  });

  final AerosNavItem item;
  final int depth;
  final AerosSidenavDensity density;
  final bool parentHasIcon;
  final bool rail;
  final VoidCallback? onExpandRequested;

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
    final rail = widget.rail;
    // In the rail a parent stands for its children: it is the current place when one of them is.
    final selected = item.selected || (rail && item._containsSelection);

    // A child's label lines up with its parent's label: past the parent's icon and gap, then one
    // step further per extra level.
    final indent = widget.depth == 0
        ? 0.0
        : (widget.parentHasIcon ? d.iconSize + _iconGap : 0.0) + (widget.depth - 1) * AerosSpacing.s3;

    final VoidCallback? onTap = item.hasChildren
        ? (rail ? widget.onExpandRequested : () => setState(() => _expanded = !_expanded))
        : item.onTap;

    final announced = item.count > 0 ? '${item.label}, ${item.count}' : item.label;

    Widget content(AerosInteraction state) {
      final strong = selected || state.hovered || state.pressed;
      final iconColor = selected ? a.fgPrimary : (strong ? a.fgSecondary : a.fgMuted);
      if (rail) {
        return Center(
          child: item.icon != null
              ? Icon(item.icon, size: d.iconSize, color: iconColor)
              : Text(
                  item.label.isEmpty ? '' : item.label.characters.first.toUpperCase(),
                  style: d.labelStyle(color: strong ? a.fgPrimary : a.fgSecondary, weight: FontWeight.w600),
                ),
        );
      }
      return Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: d.iconSize, color: iconColor),
            const SizedBox(width: _iconGap),
          ],
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: d.labelStyle(
                color: strong ? a.fgPrimary : a.fgSecondary,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (item.count > 0) AerosCountBadge(count: item.count, density: d.density),
          if (item.hasChildren)
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: AerosMotion.resolve(context, AerosMotion.fast),
              curve: AerosMotion.standard,
              child: Icon(Icons.keyboard_arrow_down_rounded, size: AerosSizeTokens.iconMd, color: a.fgMuted),
            ),
        ],
      );
    }

    Widget row = AerosPressable(
      onPressed: onTap,
      selected: selected,
      // The row brings its own height (the navRow token) and spans the rail.
      expandHitTarget: false,
      builder: (context, state) => Semantics(
        label: announced,
        expanded: item.hasChildren && !rail ? _expanded : null,
        child: ExcludeSemantics(
          child: _RailFill(
            state: state,
            selected: selected,
            height: d.rowHeight,
            // The fill's hairline is part of the box, so it comes off the padding.
            padding: rail
                ? EdgeInsets.zero
                : EdgeInsetsDirectional.only(
                    start: _pad + indent - AerosMetricTokens.borderHairline,
                    end: _pad - AerosMetricTokens.borderHairline,
                  ),
            child: content(state),
          ),
        ),
      ),
    );
    if (rail) row = _withTooltip(context, item.label, row);
    row = Padding(key: item.key, padding: const EdgeInsets.only(bottom: _rowGap), child: row);

    if (rail || !item.hasChildren || !_expanded) return row;
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
            rail: false,
            onExpandRequested: widget.onExpandRequested,
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//   Top and bottom blocks
// ═══════════════════════════════════════════════════════════════════════

/// The 24px rounded square ([AerosSizeTokens.avatarSm]) that marks a workspace at the head of the
/// rail: an [icon] or a [letter] in `fgInverse` on `brandPrimary`.
class AerosSidenavMark extends StatelessWidget {
  const AerosSidenavMark({super.key, this.icon, this.letter})
      : assert(icon != null || letter != null, 'Give the mark an icon or a letter');

  final IconData? icon;
  final String? letter;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      width: AerosSizeTokens.avatarSm,
      height: AerosSizeTokens.avatarSm,
      decoration: BoxDecoration(color: a.brandPrimary, borderRadius: _itemRadius),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: AerosSizeTokens.iconSm, color: a.fgInverse)
          : Text(
              letter!.isEmpty ? '' : letter!.characters.first.toUpperCase(),
              style: AerosTypography.labelSm(color: a.fgInverse, weight: FontWeight.w600),
            ),
    );
  }
}

/// A name over an optional second line — the header's workspace, the footer's user.
class _TwoLines extends StatelessWidget {
  const _TwoLines(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AerosTypography.labelSm(color: a.fgPrimary),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AerosTypography.caption(color: a.fgMuted),
          ),
      ],
    );
  }
}

/// The rail's top block: which workspace this is, and — when [onTap] is set — the way to another
/// one, signalled by an unfold chevron. Where Stripe, Linear and Vercel all keep it.
///
/// One app header high ([AerosSizeTokens.header] for the ambient [AerosDensity]) over a hairline,
/// so it sits level with `AerosTopnav` and `AerosPageHeader`. [mark] is drawn at 24px; it defaults
/// to an [AerosSidenavMark] with the title's first letter. In a collapsed rail only the mark shows.
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
    final rail = _RailScope.of(context);
    final markBox = SizedBox.square(
      dimension: AerosSizeTokens.avatarSm,
      child: mark ?? AerosSidenavMark(letter: title),
    );
    final content = rail
        ? Center(child: markBox)
        : Row(
            children: [
              markBox,
              const SizedBox(width: _iconGap),
              Expanded(child: _TwoLines(title, subtitle?.trim() ?? '')),
              if (onTap != null) Icon(Icons.unfold_more_rounded, size: AerosSizeTokens.iconMd, color: a.fgMuted),
            ],
          );
    // The pressable fill's hairline is part of its box, so it comes off the padding there.
    const hairline = AerosMetricTokens.borderHairline;

    return Container(
      height: AerosDensity.of(context).sizes.header,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: a.borderDefault, width: hairline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: _inset, vertical: AerosSpacing.s1_5),
      child: onTap == null
          ? Semantics(
              label: semanticLabel ?? title,
              excludeSemantics: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rail ? 0 : _pad),
                child: content,
              ),
            )
          : AerosPressable(
              onPressed: onTap,
              expandHitTarget: false,
              semanticLabel: semanticLabel ?? title,
              excludeSemantics: true,
              builder: (context, state) => _RailFill(
                state: state,
                padding: EdgeInsets.symmetric(horizontal: rail ? 0 : _pad - hairline),
                child: content,
              ),
            ),
    );
  }
}

/// The rail's bottom block: who is signed in, and one action beside them (sign out). Drawn over a
/// hairline, one app header high ([AerosSizeTokens.header] for the ambient [AerosDensity]).
///
/// [avatar] is drawn at 24px; it defaults to the name's initial in a neutral [AerosAvatar]. The
/// action shows when [actionIcon] and [onAction] are both set; [actionLabel] is its tooltip and its
/// announced name. In a collapsed rail only the avatar shows.
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
    final rail = _RailScope.of(context);
    final who = name.trim();
    final avatarBox = SizedBox.square(
      dimension: AerosSizeTokens.avatarSm,
      child: avatar ??
          AerosAvatar(
            initials: who.isEmpty ? '' : who.characters.first.toUpperCase(),
            size: AerosAvatarSize.sm,
          ),
    );
    return Container(
      height: AerosDensity.of(context).sizes.header,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline)),
      ),
      padding: rail
          ? EdgeInsets.zero
          : const EdgeInsetsDirectional.only(start: _inset + _pad, end: AerosSpacing.s2),
      child: rail
          ? Semantics(label: who, excludeSemantics: true, child: Center(child: avatarBox))
          : Row(
              children: [
                avatarBox,
                const SizedBox(width: _iconGap),
                Expanded(child: _TwoLines(who, subtitle?.trim() ?? '')),
                if (actionIcon != null && onAction != null) _action(context),
              ],
            ),
    );
  }

  Widget _action(BuildContext context) {
    final a = context.aerosColors;
    final sizes = AerosDensity.of(context).sizes;
    final button = SizedBox.square(
      key: actionKey,
      dimension: sizes.iconButton,
      child: AerosPressable(
        onPressed: onAction,
        // Already an icon button's size for the density.
        expandHitTarget: false,
        semanticLabel: actionLabel,
        excludeSemantics: true,
        builder: (context, state) => _RailFill(
          state: state,
          child: Center(
            child: Icon(
              actionIcon,
              size: sizes.navIcon,
              color: state.hovered || state.pressed ? a.fgPrimary : a.fgSecondary,
            ),
          ),
        ),
      ),
    );
    return _withTooltip(context, actionLabel ?? '', button);
  }
}
