import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/aeros_viewport_scope.dart';
import '../tokens/breakpoints.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';
import 'aeros_sidenav.dart';

/// Wraps a [Scaffold] with optional [AerosTopnav] and [AerosSidenav], styled
/// from Aeros tokens.
///
/// The sidenav sits inline, behind a 1px hairline, from the `md` breakpoint up
/// ([AerosBreakpoints.md], 768) and moves into a drawer below it. The width
/// that decides is the real viewport width: an [AerosViewportScope] above the
/// scaffold wins over `MediaQuery`, exactly as for [AerosBreakpoints.of].
///
/// Inline it is [sidenavWidth] wide ([AerosMetricTokens.layoutSidebar], 240) —
/// or [AerosMetricTokens.layoutSidebarRail] (56) when the sidenav is
/// [AerosSidenav.collapsed]. The drawer is
/// [AerosMetricTokens.layoutSidebarMobile] wide and always shows the full rail.
///
/// The top bar is one app header high ([AerosSizeTokens.header] for the
/// density: 48 for a mouse, 56 for fingers) — the same height as the sidenav's
/// header block, so the two line up.
///
/// ## Reaching the scaffold
///
/// Anything below the scaffold — the top bar, the page, the sidenav — asks
/// [AerosScaffold.of] for its [AerosScaffoldState]: whether the sidenav
/// [AerosScaffoldState.isSidenavInline], whether the drawer
/// [AerosScaffoldState.isDrawerOpen], and [AerosScaffoldState.openDrawer] /
/// [AerosScaffoldState.closeDrawer] / [AerosScaffoldState.toggleDrawer]. The
/// widget that builds the scaffold is above it, so it uses a
/// `GlobalKey<AerosScaffoldState>` instead:
///
/// ```dart
/// final _shell = GlobalKey<AerosScaffoldState>();
///
/// AerosScaffold(
///   key: _shell,
///   topnav: const AerosTopnav(title: 'Orders'), // shows the menu button itself
///   sidenav: AerosSidenav(items: [
///     AerosNavItem(label: 'Orders', onTap: () {
///       open('/orders');
///       _shell.currentState?.closeDrawer(); // no-op when the sidenav is inline
///     }),
///   ]),
///   body: page,
/// )
/// ```
///
/// ## Who owns the rail
///
/// The app does. Whether the inline sidenav is collapsed to the icon rail is
/// [AerosSidenav.collapsed], a value the app holds like any other (it usually
/// wants to remember it). The scaffold reports it as
/// [AerosScaffoldState.isRailCollapsed] and, when [onRailCollapsedChanged] is
/// set, asks for a change through [AerosScaffoldState.toggleRail] — which is
/// also what makes [AerosTopnav] show its collapse / expand button.
class AerosScaffold extends StatefulWidget {
  const AerosScaffold({
    super.key,
    required this.body,
    this.topnav,
    this.sidenav,
    this.floatingActionButton,
    this.sidenavBreakpoint = AerosBreakpoints.md,
    this.sidenavWidth = AerosMetricTokens.layoutSidebar,
    this.backgroundColor,
    this.onRailCollapsedChanged,
    this.onDrawerChanged,
  });

  final Widget body;
  final AerosTopnav? topnav;
  final AerosSidenav? sidenav;
  final FloatingActionButton? floatingActionButton;

  /// The viewport width from which the sidenav is inline. Defaults to the
  /// `md` breakpoint token.
  final double sidenavBreakpoint;

  /// Width of the inline, expanded sidenav.
  final double sidenavWidth;
  final Color? backgroundColor;

  /// Called by [AerosScaffoldState.toggleRail] with the value
  /// [AerosSidenav.collapsed] should take. The app owns that value: set it
  /// and rebuild. Null (the default) means the rail cannot be toggled through
  /// the scaffold, and [AerosTopnav] shows no collapse button.
  final ValueChanged<bool>? onRailCollapsedChanged;

  /// Called when the drawer has opened (true) or closed (false).
  final ValueChanged<bool>? onDrawerChanged;

  /// The state of the nearest [AerosScaffold] above [context]. The calling
  /// widget rebuilds when what it reports changes. Throws when there is none.
  static AerosScaffoldState of(BuildContext context) {
    final state = maybeOf(context);
    assert(() {
      if (state == null) {
        throw FlutterError(
          'AerosScaffold.of() was called with a context that has no AerosScaffold above it.\n'
          'Use a context below the scaffold (a Builder, or a widget of your own), '
          'or reach it from above with a GlobalKey<AerosScaffoldState>.',
        );
      }
      return true;
    }());
    return state!;
  }

  /// Like [of], but null when there is no [AerosScaffold] above [context].
  static AerosScaffoldState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AerosScaffoldScope>()?.state;

  @override
  State<AerosScaffold> createState() => AerosScaffoldState();
}

/// What an [AerosScaffold] tells the widgets below it, and how they open and
/// close its drawer. Get it with [AerosScaffold.of], or from above with a
/// `GlobalKey<AerosScaffoldState>`.
class AerosScaffoldState extends State<AerosScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'AerosScaffold');
  bool _inline = false;
  bool _drawerOpen = false;

  /// Whether the scaffold was given a sidenav at all.
  bool get hasSidenav => widget.sidenav != null;

  /// The sidenav is on the page, beside the body (viewport at or above
  /// [AerosScaffold.sidenavBreakpoint]). False without a sidenav.
  bool get isSidenavInline => hasSidenav && _inline;

  /// The sidenav lives in a drawer that has to be opened. False without a
  /// sidenav.
  bool get isSidenavInDrawer => hasSidenav && !_inline;

  /// The drawer is open (or opening).
  bool get isDrawerOpen => isSidenavInDrawer && _drawerOpen;

  /// The inline sidenav is collapsed to the icon rail — the app's
  /// [AerosSidenav.collapsed], while the sidenav is inline. Always false in a
  /// drawer, which shows the full sidenav.
  bool get isRailCollapsed => isSidenavInline && widget.sidenav!.collapsed;

  /// [toggleRail] does something: the sidenav is inline and the app listens
  /// through [AerosScaffold.onRailCollapsedChanged].
  bool get canToggleRail => isSidenavInline && widget.onRailCollapsedChanged != null;

  /// Opens the drawer. Does nothing while the sidenav is inline.
  void openDrawer() {
    if (isSidenavInDrawer) _scaffoldKey.currentState?.openDrawer();
  }

  /// Closes the drawer. Does nothing when it is not open — safe to call from
  /// every navigation row.
  void closeDrawer() {
    if (isDrawerOpen) _scaffoldKey.currentState?.closeDrawer();
  }

  /// Opens the drawer when it is closed and closes it when it is open.
  void toggleDrawer() => isDrawerOpen ? closeDrawer() : openDrawer();

  /// Asks the app to collapse or expand the inline rail, through
  /// [AerosScaffold.onRailCollapsedChanged]. Does nothing when
  /// [canToggleRail] is false.
  void toggleRail() {
    if (canToggleRail) widget.onRailCollapsedChanged!(!isRailCollapsed);
  }

  void _onDrawerChanged(bool open) {
    if (open != _drawerOpen) setState(() => _drawerOpen = open);
    widget.onDrawerChanged?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    // The same lookup as AerosBreakpoints.of: a web shell that clamps
    // MediaQuery to a phone width publishes the real width in a scope.
    final width = AerosViewportScope.of(context)?.width ?? MediaQuery.sizeOf(context).width;
    final sidenav = widget.sidenav;
    _inline = width >= widget.sidenavBreakpoint;
    final inline = sidenav != null && _inline;
    final drawer = sidenav != null && !inline;
    // The drawer goes away with the layout that had it.
    if (!drawer) _drawerOpen = false;
    final topnav = widget.topnav;

    return _AerosScaffoldScope(
      state: this,
      inline: inline,
      drawer: drawer,
      drawerOpen: isDrawerOpen,
      railCollapsed: isRailCollapsed,
      canToggleRail: canToggleRail,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: widget.backgroundColor ?? a.bgCanvas,
        appBar: topnav == null
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(topnav.height ?? AerosDensity.of(context).sizes.header),
                child: topnav,
              ),
        drawer: drawer
            ? Drawer(
                width: AerosMetricTokens.layoutSidebarMobile,
                backgroundColor: a.bgSurface,
                // A sheet over a scrim: square, and flat like every surface.
                elevation: 0,
                shape: const RoundedRectangleBorder(),
                child: AerosSidenavExpanded(child: sidenav),
              )
            : null,
        onDrawerChanged: _onDrawerChanged,
        floatingActionButton: widget.floatingActionButton,
        body: inline
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: sidenav.collapsed ? AerosMetricTokens.layoutSidebarRail : widget.sidenavWidth,
                    decoration: BoxDecoration(
                      color: a.bgSurface,
                      border: BorderDirectional(
                        end: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
                      ),
                    ),
                    child: sidenav,
                  ),
                  Expanded(child: widget.body),
                ],
              )
            : widget.body,
      ),
    );
  }
}

/// Carries the [AerosScaffoldState] down, and rebuilds its dependents when
/// what the state reports changes.
class _AerosScaffoldScope extends InheritedWidget {
  const _AerosScaffoldScope({
    required this.state,
    required this.inline,
    required this.drawer,
    required this.drawerOpen,
    required this.railCollapsed,
    required this.canToggleRail,
    required super.child,
  });

  final AerosScaffoldState state;
  final bool inline;
  final bool drawer;
  final bool drawerOpen;
  final bool railCollapsed;
  final bool canToggleRail;

  @override
  bool updateShouldNotify(_AerosScaffoldScope oldWidget) =>
      oldWidget.state != state ||
      oldWidget.inline != inline ||
      oldWidget.drawer != drawer ||
      oldWidget.drawerOpen != drawerOpen ||
      oldWidget.railCollapsed != railCollapsed ||
      oldWidget.canToggleRail != canToggleRail;
}

/// Application top bar — title on the left, optional trailing actions.
///
/// A `bgSurface` bar over a 1px hairline, one app header high
/// ([AerosSizeTokens.header] for the density) with an `h4` title.
///
/// Inside an [AerosScaffold], with no [leading] of its own, the bar shows the
/// button the sidenav needs: a menu button that opens the drawer while the
/// sidenav is in one ([openNavigationLabel]), and — when the scaffold has an
/// [AerosScaffold.onRailCollapsedChanged] — a button that collapses or
/// expands the inline rail ([collapseSidebarLabel] / [expandSidebarLabel]).
/// Each is an icon button at least one minimum target in size, named for
/// screen readers. Turn this off with [automaticallyImplyLeading].
class AerosTopnav extends StatelessWidget implements PreferredSizeWidget {
  const AerosTopnav({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.height,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.openNavigationLabel = 'Open navigation',
    this.collapseSidebarLabel = 'Collapse sidebar',
    this.expandSidebarLabel = 'Expand sidebar',
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;

  /// Null (the default) is the header height for the nearest
  /// [AerosDensityScope].
  final double? height;
  final Color? backgroundColor;

  /// With no [leading], show the enclosing [AerosScaffold]'s menu button (or
  /// rail toggle). False leaves the leading slot empty.
  final bool automaticallyImplyLeading;

  /// Names of the automatic leading buttons: announced, and shown as their
  /// tooltips.
  final String openNavigationLabel;
  final String collapseSidebarLabel;
  final String expandSidebarLabel;

  /// The automatic leading button for [shell], or null when it needs none.
  Widget? _impliedLeading(BuildContext context, AerosScaffoldState? shell) {
    if (shell == null) return null;
    final String label;
    final IconData icon;
    final VoidCallback onPressed;
    if (shell.isSidenavInDrawer) {
      (label, icon, onPressed) = (openNavigationLabel, Icons.menu, shell.openDrawer);
    } else if (shell.canToggleRail) {
      (label, icon, onPressed) = shell.isRailCollapsed
          ? (expandSidebarLabel, Icons.menu, shell.toggleRail)
          : (collapseSidebarLabel, Icons.menu_open, shell.toggleRail);
    } else {
      return null;
    }
    final button = AerosButton.icon(icon: Icon(icon), semanticLabel: label, onPressed: onPressed);
    // A bar drawn above the app's Navigator has no Overlay for a tooltip.
    if (Overlay.maybeOf(context) == null) return button;
    return Tooltip(message: label, waitDuration: AerosMotion.slow, excludeFromSemantics: true, child: button);
  }

  /// Without a build context the density is unknown: this is the explicit
  /// [height], or the touch header height. [AerosScaffold] sizes the bar for
  /// the actual density.
  @override
  Size get preferredSize => Size.fromHeight(height ?? AerosSizeTokens.touch.header);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final height = this.height ?? AerosDensity.of(context).sizes.header;
    final leading = this.leading ??
        (automaticallyImplyLeading ? _impliedLeading(context, AerosScaffold.maybeOf(context)) : null);
    return Material(
      color: backgroundColor ?? a.bgSurface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AerosSpacing.s3),
              ],
              Expanded(
                child: titleWidget ??
                    Semantics(
                      header: true,
                      child: Text(
                        title ?? '',
                        style: AerosTypography.h4(color: a.fgPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
