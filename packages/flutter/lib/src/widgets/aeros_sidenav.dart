import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'aeros_menu.dart';
import 'aeros_popover.dart';

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
    this.countEmphasis = false,
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

  /// Shown when above zero (unread, pending) and announced with the label: a quiet number at the
  /// row's end, and a dot on the icon in the collapsed rail.
  final int count;

  /// Draw [count] as a filled pill, for a count that needs attention.
  final bool countEmphasis;

  /// Key for the row — handy for tests (`ValueKey('nav:/orders')`).
  final Key? key;

  bool get hasChildren => children != null && children!.isNotEmpty;

  bool get _containsSelection => selected || (children?.any((c) => c._containsSelection) ?? false);
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

/// Gutter between the rail's edge and a row, and the padding inside a row for text that starts it
/// (group labels, children).
const double _inset = AerosSpacing.s3;
const double _pad = AerosSpacing.s2;

/// The line every icon, the header mark and the footer avatar are centred on: half the collapsed
/// rail. Because it is the same line expanded and collapsed, collapsing never moves an icon.
const double _centre = AerosMetricTokens.layoutSidebarRail / 2;

/// Start padding inside a row (which already sits [_inset] in) that centres a [size] box on [_centre].
double _leadFor(double size) => _centre - _inset - size / 2;

const BorderRadius _itemRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.item));

/// Forces every [AerosSidenav] below it to show the full rail, whatever its
/// [AerosSidenav.collapsed] says. `AerosScaffold` wraps its drawer in one: an
/// icon-only rail makes no sense in a sheet.
class AerosSidenavExpanded extends InheritedWidget {
  const AerosSidenavExpanded({super.key, required super.child});

  static bool _of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AerosSidenavExpanded>() != null;

  @override
  bool updateShouldNotify(AerosSidenavExpanded oldWidget) => false;
}

/// What an [AerosSidenav] tells the widgets inside it — read it from a custom
/// header or footer to follow the rail:
///
/// ```dart
/// final collapsed = AerosSidenavScope.of(context).collapsed;
/// return collapsed ? const AerosSidenavMark(letter: 'a') : const AerosWordmark(size: 20);
/// ```
///
/// Read-only: [AerosSidenav] places it; an app never builds one itself. The
/// calling widget rebuilds when the rail collapses or expands.
class AerosSidenavScope extends InheritedWidget {
  const AerosSidenavScope._({required this.collapsed, required this.density, required super.child});

  /// The sidenav is showing as the icon-only rail
  /// ([AerosMetricTokens.layoutSidebarRail] wide). Always false in the
  /// scaffold's drawer, whatever [AerosSidenav.collapsed] says.
  final bool collapsed;

  /// The row sizing of the sidenav.
  final AerosSidenavDensity density;

  /// The scope of the nearest [AerosSidenav] above [context]. Throws when
  /// there is none.
  static AerosSidenavScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(() {
      if (scope == null) {
        throw FlutterError(
          'AerosSidenavScope.of() was called with a context that is not inside an AerosSidenav.\n'
          'Use AerosSidenavScope.maybeOf() for a widget that is also used outside one.',
        );
      }
      return true;
    }());
    return scope!;
  }

  /// Like [of], but null outside an [AerosSidenav].
  static AerosSidenavScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AerosSidenavScope>();

  static bool _collapsedOf(BuildContext context) => maybeOf(context)?.collapsed ?? false;

  @override
  bool updateShouldNotify(AerosSidenavScope oldWidget) =>
      oldWidget.collapsed != collapsed || oldWidget.density != density;
}

/// Vertical navigation rail rendered inline on wide layouts or inside a Drawer.
///
/// Spec (shared with the web `Sidebar`):
/// - it is [AerosMetricTokens.layoutSidebar] (240) wide — its parent sets the width — and
///   [AerosMetricTokens.layoutSidebarRail] (56) when [collapsed] to icons;
/// - rows are inset [AerosSpacing.s3] from the rail, with [AerosShapeTokens.item] corners; every
///   icon, the [AerosSidenavHeader] mark and the [AerosSidenavFooter] avatar are centred 28px in
///   (half the collapsed rail), expanded and collapsed alike, so collapsing never moves them;
/// - row height, icon size and label size are the `navRow` / `navIcon` / `navLabel` size tokens for
///   the [density];
/// - at rest the label is `fgSecondary` and the icon `fgMuted`; hover and press lay the
///   `stateHover` / `statePressed` overlay on the rail and lift the label to `fgPrimary`; the
///   selected row takes the `stateSelected` overlay and `fgPrimary` at the same weight (so labels
///   never reflow); keyboard focus draws the focus ring; nothing ripples;
/// - group labels are sentence case, `caption` in `fgMuted` — they sort the destinations, they do
///   not compete with them;
/// - children sit under a hairline guide below the parent's icon; a parent opens by itself when
///   it comes to hold the selected item.
///
/// Put an [AerosSidenavHeader] in [header] (the workspace, and the way to switch it) and an
/// [AerosSidenavFooter] in [footer] (who is signed in, and sign out). Both are one app header high
/// ([AerosSizeTokens.header] for the ambient [AerosDensity]), like `AerosTopnav`.
///
/// [collapsed] shows icons only: labels become tooltips beside the row, group labels become
/// hairlines, a count becomes a dot, a parent opens its children in a menu beside it, and the
/// header and footer keep only their mark and avatar. Every row is still announced by its full
/// label.
///
/// [density] defaults to the `AerosDensityScope` above it, and to pointer rows with no scope.
class AerosSidenav extends StatelessWidget {
  const AerosSidenav({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.density,
    this.collapsed = false,
    this.onExpandRequested,
    this.onNavigate,
    this.semanticLabel = 'Navigation',
    this.padding = const EdgeInsets.fromLTRB(_inset, AerosSpacing.s2, _inset, AerosSpacing.s3),
  });

  final List<AerosNavItem> items;
  final Widget? header;
  final Widget? footer;

  /// Row sizing. Null (the default) follows the `AerosDensityScope` above; pointer with none.
  final AerosSidenavDensity? density;

  /// Icon-only rail ([AerosMetricTokens.layoutSidebarRail] wide).
  final bool collapsed;

  /// Called when a parent row is tapped in a collapsed rail that has no Navigator to open its
  /// menu in (a rail drawn above the app's Navigator). Otherwise the parent opens a menu.
  final VoidCallback? onExpandRequested;

  /// Called after any destination is chosen, from a row or from a rail menu. `AerosScaffold` sets
  /// it to close its drawer or floating sidebar.
  final VoidCallback? onNavigate;

  /// The name of the navigation landmark.
  final String semanticLabel;
  final EdgeInsetsGeometry padding;

  /// This sidenav with some values replaced. `AerosScaffold` uses it to present the app's sidenav
  /// as a rail, a floating panel or a drawer.
  AerosSidenav copyWith({
    bool? collapsed,
    AerosSidenavDensity? density,
    VoidCallback? onNavigate,
  }) =>
      AerosSidenav(
        key: key,
        items: items,
        header: header,
        footer: footer,
        density: density ?? this.density,
        collapsed: collapsed ?? this.collapsed,
        onExpandRequested: onExpandRequested,
        onNavigate: onNavigate ?? this.onNavigate,
        semanticLabel: semanticLabel,
        padding: padding,
      );

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rail = collapsed && !AerosSidenavExpanded._of(context);
    // With no density of its own the sidenav follows an AerosDensityScope above it; with neither
    // it keeps the pointer rows it always had.
    final density = this.density ??
        (AerosDensityScope.maybeOf(context) == AerosDensity.touch
            ? AerosSidenavDensity.touch
            : AerosSidenavDensity.pointer);
    final rows = <Widget>[];
    String? section;
    for (final item in items) {
      if (item.section != section) {
        if (item.section != null) rows.add(_SectionLabel(item.section!, rail: rail, first: rows.isEmpty));
        section = item.section;
      }
      rows.add(_NavEntry(
        item: item,
        depth: 0,
        density: density,
        rail: rail,
        onExpandRequested: onExpandRequested,
        onNavigate: onNavigate,
      ));
    }
    return AerosSidenavScope._(
      collapsed: rail,
      density: density,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.navigation,
        label: semanticLabel,
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
      ),
    );
  }
}

/// The fill every interactive thing in the rail shares: the rail's own colour at rest, the state
/// overlay under the pointer, the `stateSelected` overlay when [selected] — inside the focus ring.
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
          a.bgSurface,
          hovered: state.hovered,
          pressed: state.pressed,
          selected: selected,
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

/// A rail row's name, shown beside it (toward the page) the moment the row is hovered or takes
/// keyboard focus. Material's Tooltip can only sit above or below, and waits.
class _SideTip extends StatefulWidget {
  const _SideTip({required this.show, required this.message, required this.child});

  final bool show;
  final String message;
  final Widget child;

  @override
  State<_SideTip> createState() => _SideTipState();
}

class _SideTipState extends State<_SideTip> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _sync() {
    final want = widget.show && widget.message.isNotEmpty;
    if (want == _portal.isShowing) return;
    // Showing an overlay child changes the tree: not during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final want = widget.show && widget.message.isNotEmpty;
      if (want && !_portal.isShowing) _portal.show();
      if (!want && _portal.isShowing) _portal.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    // A rail drawn above the app's Navigator has no Overlay; the row is still announced.
    if (Overlay.maybeOf(context) == null) return widget.child;
    _sync();
    final a = context.aerosColors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: rtl ? Alignment.centerLeft : Alignment.centerRight,
            followerAnchor: rtl ? Alignment.centerRight : Alignment.centerLeft,
            // Clear of the rail's edge: the row ends one inset short of it.
            offset: Offset((rtl ? -1 : 1) * (_inset + AerosSpacing.s1_5), 0),
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2, vertical: AerosSpacing.s1),
                  decoration: BoxDecoration(color: a.bgInverse, borderRadius: _itemRadius),
                  child: Text(widget.message, maxLines: 1, style: AerosTypography.caption(color: a.fgInverse)),
                ),
              ),
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.rail, this.first = false});
  final String title;
  final bool rail;

  /// The first row of the list: in the rail it draws no hairline, the header's is right above.
  final bool first;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final caption = AerosTypography.caption(color: a.fgMuted);
    // The same block expanded and collapsed, so rows keep their positions: in the rail the words
    // give way to a hairline, and the name is still announced.
    return Padding(
      padding: EdgeInsets.fromLTRB(rail ? 0 : _pad, AerosSpacing.s4, rail ? 0 : _pad, _labelGap),
      child: Semantics(
        header: true,
        label: title,
        excludeSemantics: true,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (!rail)
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: caption,
              )
            else ...[
              // As tall as the words it replaces.
              SizedBox(height: MediaQuery.textScalerOf(context).scale(caption.fontSize!) * (caption.height ?? 1)),
              if (!first)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1),
                  child: ColoredBox(
                    color: a.borderDefault,
                    child: const SizedBox(height: AerosMetricTokens.borderHairline, width: double.infinity),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavEntry extends StatefulWidget {
  const _NavEntry({
    required this.item,
    required this.depth,
    required this.density,
    required this.rail,
    required this.onExpandRequested,
    required this.onNavigate,
  });

  final AerosNavItem item;
  final int depth;
  final AerosSidenavDensity density;
  final bool rail;
  final VoidCallback? onExpandRequested;
  final VoidCallback? onNavigate;

  @override
  State<_NavEntry> createState() => _NavEntryState();
}

class _NavEntryState extends State<_NavEntry> {
  late bool _expanded = widget.item._containsSelection;

  @override
  void didUpdateWidget(_NavEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Opens when it comes to hold the current page; the user can still close it.
    if (widget.item._containsSelection && !oldWidget.item._containsSelection) _expanded = true;
  }

  void _choose(AerosNavItem item) {
    item.onTap?.call();
    widget.onNavigate?.call();
  }

  /// The children of a rail parent, as menu entries: a nested parent becomes a label over its own.
  List<AerosMenuEntry> _menuEntries(List<AerosNavItem> children) => [
        for (final child in children)
          if (child.hasChildren) ...[
            AerosMenuLabel(child.label),
            ..._menuEntries(child.children!),
          ] else
            AerosMenuItem<void>(
              label: child.count > 0 ? '${child.label} · ${child.count}' : child.label,
              onSelected: () => _choose(child),
            ),
      ];

  /// In the rail a parent opens its children in a menu beside it; the sidebar stays collapsed.
  void _openMenu() {
    if (Navigator.maybeOf(context) == null) {
      // A rail drawn above the app's Navigator cannot push a menu: ask the app to expand instead.
      widget.onExpandRequested?.call();
      return;
    }
    final row = AerosPopover.anchorRectOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The menu hangs below-start of its anchor: a point just past the rail, level with the row.
    final x = rtl ? row.left - _inset - AerosSpacing.s1_5 : row.right + _inset + AerosSpacing.s1_5;
    AerosMenu.show<void>(
      context,
      anchorRect: Rect.fromLTWH(x, row.top - AerosPopover.gap, 0, 0),
      semanticLabel: widget.item.label,
      items: [AerosMenuLabel(widget.item.label), ..._menuEntries(widget.item.children!)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final item = widget.item;
    final d = widget.density;
    final rail = widget.rail;
    final top = widget.depth == 0;
    // In the rail a parent stands for its children: it is the current place when one of them is.
    final selected = item.selected || (rail && item._containsSelection);

    final VoidCallback? onTap = item.hasChildren
        ? (rail ? _openMenu : () => setState(() => _expanded = !_expanded))
        : (item.onTap == null && widget.onNavigate == null ? null : () => _choose(item));

    final announced = item.count > 0 ? '${item.label}, ${item.count}' : item.label;
    final countText = item.count > 99 ? '99+' : '${item.count}';

    Widget content(AerosInteraction state) {
      final strong = selected || state.hovered || state.pressed;
      final iconColor = selected ? a.fgPrimary : (strong ? a.fgSecondary : a.fgMuted);
      // Top-level rows always lead with an icon-sized box centred on the rail's centre line: the
      // icon, or the label's first letter when there is none.
      final Widget? lead = !top
          ? null
          : SizedBox.square(
              dimension: d.iconSize,
              child: item.icon != null
                  ? Icon(item.icon, size: d.iconSize, color: iconColor)
                  : Center(
                      child: Text(
                        item.label.isEmpty ? '' : item.label.characters.first.toUpperCase(),
                        style: d.labelStyle(color: strong ? a.fgPrimary : a.fgSecondary, weight: FontWeight.w600),
                      ),
                    ),
            );
      if (rail) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              lead!,
              if (item.count > 0)
                // A count has no room here: a dot on the icon's corner, the number in the tooltip.
                PositionedDirectional(
                  top: -AerosSpacing.s0_5,
                  end: -AerosSpacing.s0_5,
                  child: Container(
                    width: AerosSpacing.s2,
                    height: AerosSpacing.s2,
                    decoration: BoxDecoration(
                      color: a.fgPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: a.bgSurface, width: AerosMetricTokens.borderHairline),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
      return Row(
        children: [
          if (lead != null) ...[lead, const SizedBox(width: _iconGap)],
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // The weight never changes with selection, so labels do not reflow.
              style: top
                  ? d.labelStyle(color: strong ? a.fgPrimary : a.fgSecondary, weight: FontWeight.w500)
                  : (d == AerosSidenavDensity.pointer ? AerosTypography.bodySm : AerosTypography.bodyMd)(
                      color: strong ? a.fgPrimary : a.fgSecondary,
                    ),
            ),
          ),
          if (item.count > 0)
            item.countEmphasis
                ? AerosCountBadge(count: item.count, density: d.density)
                : Padding(
                    padding: const EdgeInsetsDirectional.only(end: AerosSpacing.s1),
                    child: Text(
                      countText,
                      style: AerosTypography.caption(color: a.fgMuted)
                          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
          if (item.hasChildren)
            AnimatedRotation(
              turns: _expanded ? 0.25 : 0,
              duration: AerosMotion.resolve(context, AerosMotion.fast),
              curve: AerosMotion.standard,
              child: Icon(Icons.chevron_right_rounded, size: AerosSizeTokens.iconMd, color: a.fgMuted),
            ),
        ],
      );
    }

    // The fill's hairline is part of the box, so it comes off the padding.
    const hairline = AerosMetricTokens.borderHairline;
    final lead = (top ? _leadFor(d.iconSize) : _pad) - hairline;

    Widget row = AerosPressable(
      onPressed: onTap,
      selected: selected,
      // The row brings its own height (the navRow token) and spans the rail.
      expandHitTarget: false,
      builder: (context, state) {
        final fill = Semantics(
          label: announced,
          expanded: item.hasChildren && !rail ? _expanded : null,
          child: ExcludeSemantics(
            child: _RailFill(
              state: state,
              selected: selected,
              height: d.rowHeight,
              padding: EdgeInsetsDirectional.only(start: lead, end: rail ? 0 : _pad - hairline),
              child: content(state),
            ),
          ),
        );
        if (!rail) return fill;
        return _SideTip(
          show: state.hovered || state.focused,
          message: item.count > 0 ? '${item.label} · ${item.count}' : item.label,
          child: fill,
        );
      },
    );
    row = Padding(key: item.key, padding: const EdgeInsets.only(bottom: _rowGap), child: row);

    if (rail || !item.hasChildren || !_expanded) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        // Children hang from a hairline guide under the parent's icon centre (or its text edge,
        // one level further down).
        Container(
          margin: EdgeInsetsDirectional.only(
            start: top ? _centre - _inset : _pad + AerosSpacing.s0_5,
          ),
          padding: const EdgeInsetsDirectional.only(start: AerosSpacing.s2),
          decoration: BoxDecoration(
            border: BorderDirectional(start: BorderSide(color: a.borderDefault, width: hairline)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final child in item.children!)
                _NavEntry(
                  item: child,
                  depth: widget.depth + 1,
                  density: d,
                  rail: false,
                  onExpandRequested: widget.onExpandRequested,
                  onNavigate: widget.onNavigate,
                ),
            ],
          ),
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
///
/// For anything that is not a mark and two lines of text — a wordmark, a logo, a badge — use
/// [AerosSidenavHeader.custom]: the same block (height, hairline, the rail's leading edge) around a
/// widget of your own, which reads [AerosSidenavScope] to follow the rail.
class AerosSidenavHeader extends StatelessWidget {
  const AerosSidenavHeader({
    super.key,
    required String this.title,
    this.subtitle,
    this.mark,
    this.onTap,
    this.semanticLabel,
  }) : child = null;

  /// The header block around [child], in place of the mark and the two lines of text.
  ///
  /// [child] starts on the rail's leading edge (20px in, like every icon and group label) and is
  /// centred in a collapsed rail, where it has [AerosMetricTokens.layoutSidebarRail] to fit in:
  /// switch what it shows on `AerosSidenavScope.of(context).collapsed`.
  ///
  /// ```dart
  /// AerosSidenavHeader.custom(
  ///   semanticLabel: 'Aeros',
  ///   child: Builder(
  ///     builder: (context) => AerosSidenavScope.of(context).collapsed
  ///         ? const AerosSidenavMark(letter: 'a')
  ///         : const AerosWordmark(size: 20),
  ///   ),
  /// )
  /// ```
  ///
  /// With [onTap] the whole block is one button. [semanticLabel], when given, is announced in
  /// place of whatever [child] says.
  const AerosSidenavHeader.custom({
    super.key,
    required Widget this.child,
    this.onTap,
    this.semanticLabel,
  })  : title = null,
        subtitle = null,
        mark = null;

  /// The workspace name. Null for [AerosSidenavHeader.custom].
  final String? title;
  final String? subtitle;
  final Widget? mark;
  final VoidCallback? onTap;

  /// Announced instead of the title — e.g. 'Switch account — Acme Ltd'.
  final String? semanticLabel;

  /// The content of an [AerosSidenavHeader.custom]; null otherwise.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rail = AerosSidenavScope._collapsedOf(context);
    final custom = child;
    final Widget content;
    if (custom != null) {
      content = rail ? Center(child: custom) : Align(alignment: AlignmentDirectional.centerStart, child: custom);
    } else {
      final markBox = SizedBox.square(
        dimension: AerosSizeTokens.avatarSm,
        child: mark ?? AerosSidenavMark(letter: title!),
      );
      content = rail
          ? Align(alignment: AlignmentDirectional.centerStart, child: markBox)
          : Row(
              children: [
                markBox,
                const SizedBox(width: _iconGap),
                Expanded(child: _TwoLines(title!, subtitle?.trim() ?? '')),
                if (onTap != null) Icon(Icons.unfold_more_rounded, size: AerosSizeTokens.iconMd, color: a.fgMuted),
              ],
            );
    }
    // The pressable fill's hairline is part of its box, so it comes off the padding there.
    const hairline = AerosMetricTokens.borderHairline;
    final label = semanticLabel ?? title;

    // The mark is centred on the rail's centre line, expanded and collapsed. A custom child keeps
    // the text edge when expanded and is centred in the rail.
    final markLead = _leadFor(AerosSizeTokens.avatarSm);
    final EdgeInsetsGeometry inner = custom != null
        ? EdgeInsets.symmetric(horizontal: rail ? 0 : _pad)
        : EdgeInsetsDirectional.only(start: markLead, end: rail ? 0 : _pad);
    Widget resting = Padding(padding: inner, child: content);
    // A custom child with no label speaks for itself.
    if (label != null) resting = Semantics(label: label, excludeSemantics: true, child: resting);

    return Container(
      height: AerosDensity.of(context).sizes.header,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: a.borderDefault, width: hairline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: _inset, vertical: AerosSpacing.s1_5),
      child: onTap == null
          ? resting
          : AerosPressable(
              onPressed: onTap,
              expandHitTarget: false,
              semanticLabel: label,
              excludeSemantics: label != null,
              builder: (context, state) => _RailFill(
                state: state,
                padding: custom != null
                    ? EdgeInsets.symmetric(horizontal: rail ? 0 : _pad - hairline)
                    : EdgeInsetsDirectional.only(start: markLead - hairline, end: rail ? 0 : _pad - hairline),
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
    final rail = AerosSidenavScope._collapsedOf(context);
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
      // The avatar is centred on the rail's centre line, expanded and collapsed.
      padding: EdgeInsetsDirectional.only(
        start: _centre - AerosSizeTokens.avatarSm / 2,
        end: rail ? 0 : AerosSpacing.s2,
      ),
      child: rail
          ? Semantics(
              label: who,
              excludeSemantics: true,
              child: Align(alignment: AlignmentDirectional.centerStart, child: avatarBox),
            )
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
