import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/aeros_viewport_scope.dart';
import '../tokens/breakpoints.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';
import 'aeros_sidebar_controller.dart';
import 'aeros_sidenav.dart';

/// Wraps a [Scaffold] with optional [AerosTopnav] and [AerosSidenav], styled
/// from Aeros tokens.
///
/// One sidenav, three presentations, chosen by the viewport width (design:
/// `docs/sidebar/spec.md`, shared with the web `Sidebar`):
///
/// - below [sidenavBreakpoint] (`md`, 768) it is a drawer,
///   [AerosMetricTokens.layoutSidebarMobile] wide, at touch sizes; it closes
///   when a destination is chosen;
/// - from there up to [railBreakpoint] (`lg`, 1024) it is the icon rail
///   ([AerosMetricTokens.layoutSidebarRail], 56), and the top bar's button
///   floats the full sidenav over the page without reflowing it; it closes on
///   a tap outside, Escape, or choosing a destination;
/// - from [railBreakpoint] up it is [sidenavWidth] wide
///   ([AerosMetricTokens.layoutSidebar], 240) and can be collapsed to the rail.
///
/// The width that decides is the real viewport width: an [AerosViewportScope]
/// above the scaffold wins over `MediaQuery`, exactly as for
/// [AerosBreakpoints.of]. The width change is animated; icons do not move.
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
/// Give the scaffold an [AerosSidebarController] ([sidebarController]) and it
/// owns the wide-window choice: the top bar shows the collapse button,
/// Cmd/Ctrl+B toggles it, and the controller remembers it through the storage
/// you plug in.
///
/// Without a controller the app owns it, as before: whether the inline
/// sidenav is collapsed is [AerosSidenav.collapsed], and the scaffold asks for
/// a change through [onRailCollapsedChanged].
class AerosScaffold extends StatefulWidget {
  const AerosScaffold({
    super.key,
    required this.body,
    this.topnav,
    this.sidenav,
    this.floatingActionButton,
    this.sidenavBreakpoint = AerosBreakpoints.md,
    this.railBreakpoint = AerosBreakpoints.lg,
    this.sidenavWidth = AerosMetricTokens.layoutSidebar,
    this.sidebarController,
    this.keyboardShortcut = true,
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

  /// The viewport width from which the inline sidenav is expanded by default.
  /// Between [sidenavBreakpoint] and this it is a rail that floats open.
  /// Defaults to the `lg` breakpoint token; set it equal to
  /// [sidenavBreakpoint] for no rail-only range.
  final double railBreakpoint;

  /// Width of the inline, expanded sidenav.
  final double sidenavWidth;

  /// Owns and remembers whether the wide-window sidenav is collapsed. When
  /// set, [AerosSidenav.collapsed] and [onRailCollapsedChanged] are not used
  /// for the rail.
  final AerosSidebarController? sidebarController;

  /// Toggle the sidenav with Cmd/Ctrl+B (ignored while typing in a text
  /// field). Default true.
  final bool keyboardShortcut;
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
  bool _tablet = false;
  bool _floating = false;
  bool _drawerOpen = false;
  bool _currentRoute = true;

  @override
  void initState() {
    super.initState();
    widget.sidebarController?.addListener(_onController);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void didUpdateWidget(AerosScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sidebarController != widget.sidebarController) {
      oldWidget.sidebarController?.removeListener(_onController);
      widget.sidebarController?.addListener(_onController);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    widget.sidebarController?.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (mounted) setState(() {});
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted || !hasSidenav || !_currentRoute) return false;
    if (event.logicalKey == LogicalKeyboardKey.escape && isSidenavFloating) {
      closeFloatingSidenav();
      return true;
    }
    if (!widget.keyboardShortcut || event.logicalKey != LogicalKeyboardKey.keyB) return false;
    final keys = HardwareKeyboard.instance;
    if (!(keys.isMetaPressed || keys.isControlPressed) || keys.isShiftPressed || keys.isAltPressed) return false;
    // In a text field Cmd/Ctrl+B means Bold: leave it alone.
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused != null && focused.findAncestorWidgetOfExactType<EditableText>() != null) return false;
    if (isSidenavInDrawer) {
      toggleDrawer();
      return true;
    }
    if (!canToggleRail) return false;
    toggleRail();
    return true;
  }

  /// The wide-window choice: the controller's, or the app's own [AerosSidenav.collapsed].
  bool get _collapsedChoice => widget.sidebarController?.collapsed ?? widget.sidenav?.collapsed ?? false;

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

  /// The viewport is between [AerosScaffold.sidenavBreakpoint] and
  /// [AerosScaffold.railBreakpoint]: the sidenav rests as a rail and floats
  /// open over the page.
  bool get isSidenavRailOnly => isSidenavInline && _tablet;

  /// The full sidenav is floating over the page (only while
  /// [isSidenavRailOnly]).
  bool get isSidenavFloating => isSidenavRailOnly && _floating;

  /// The inline sidenav is showing as the icon rail: collapsed on a wide
  /// window, or resting in the rail-only range. Always false in a drawer,
  /// which shows the full sidenav.
  bool get isRailCollapsed => isSidenavInline && (_tablet ? !_floating : _collapsedChoice);

  /// [toggleRail] does something: the sidenav is inline, and either it is in
  /// the rail-only range (where it floats open), or there is an
  /// [AerosScaffold.sidebarController], or the app listens through
  /// [AerosScaffold.onRailCollapsedChanged].
  bool get canToggleRail =>
      isSidenavInline &&
      (_tablet || widget.sidebarController != null || widget.onRailCollapsedChanged != null);

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

  /// Closes the floating sidenav. Does nothing when it is not floating.
  void closeFloatingSidenav() {
    if (_floating) setState(() => _floating = false);
  }

  /// Closes whatever is transient — the drawer or the floating sidenav. The
  /// scaffold calls it when a destination is chosen.
  void dismissSidenav() {
    closeDrawer();
    closeFloatingSidenav();
  }

  /// Collapses or expands the inline sidenav: floats it in the rail-only
  /// range; otherwise through the [AerosScaffold.sidebarController], or by
  /// asking the app through [AerosScaffold.onRailCollapsedChanged]. Does
  /// nothing when [canToggleRail] is false.
  void toggleRail() {
    if (!canToggleRail) return;
    if (_tablet) {
      setState(() => _floating = !_floating);
    } else if (widget.sidebarController != null) {
      widget.sidebarController!.toggle();
    } else {
      widget.onRailCollapsedChanged!(!isRailCollapsed);
    }
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
    _tablet = _inline && width < widget.railBreakpoint;
    _currentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final inline = sidenav != null && _inline;
    final drawer = sidenav != null && !inline;
    // Transient states go away with the layout that had them.
    if (!drawer) _drawerOpen = false;
    if (!_tablet) _floating = false;
    final topnav = widget.topnav;

    return _AerosScaffoldScope(
      state: this,
      inline: inline,
      drawer: drawer,
      drawerOpen: isDrawerOpen,
      railCollapsed: isRailCollapsed,
      canToggleRail: canToggleRail,
      floating: isSidenavFloating,
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
                // Fingers use the drawer: touch sizes whatever the app's density, clear of the
                // notch and the home indicator.
                child: SafeArea(
                  child: AerosDensityScope(
                    density: AerosDensity.touch,
                    child: AerosSidenavExpanded(
                      child: sidenav.copyWith(density: AerosSidenavDensity.touch, onNavigate: _navigated(sidenav)),
                    ),
                  ),
                ),
              )
            : null,
        onDrawerChanged: _onDrawerChanged,
        floatingActionButton: widget.floatingActionButton,
        body: inline ? _inlineBody(context, sidenav) : widget.body,
      ),
    );
  }

  /// The app's own [AerosSidenav.onNavigate], then closing what is transient.
  VoidCallback _navigated(AerosSidenav sidenav) => () {
        sidenav.onNavigate?.call();
        dismissSidenav();
      };

  Widget _inlineBody(BuildContext context, AerosSidenav sidenav) {
    final a = context.aerosColors;
    const railWidth = AerosMetricTokens.layoutSidebarRail;
    final fullWidth = widget.sidenavWidth;
    final rail = isRailCollapsed;
    final floating = isSidenavFloating;
    return TweenAnimationBuilder<double>(
      // 0 is the full sidenav, 1 the rail.
      tween: Tween<double>(end: rail ? 1 : 0),
      duration: AerosMotion.resolve(context, AerosMotion.base),
      curve: AerosMotion.standard,
      builder: (context, t, _) {
        final panelWidth = fullWidth + (railWidth - fullWidth) * t;
        // The rail's own layout only once it has settled. While the width moves, the full
        // sidenav stays laid out at full width and is clipped: icons sit on the same line in
        // both, so nothing jumps, and labels are revealed or covered by the edge.
        final settledRail = t == 1;
        final panel = DecoratedBox(
          decoration: BoxDecoration(
            color: a.bgSurface,
            border: BorderDirectional(
              end: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
            ),
            // Only a floating layer takes a shadow.
            boxShadow: _tablet && !settledRail ? context.aerosElevation.overlay : null,
          ),
          // The hairline is part of the panel's width, as it always was: the sidenav gets the rest.
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: AerosMetricTokens.borderHairline),
            child: ClipRect(
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                minWidth: (settledRail ? railWidth : fullWidth) - AerosMetricTokens.borderHairline,
                maxWidth: (settledRail ? railWidth : fullWidth) - AerosMetricTokens.borderHairline,
                child: sidenav.copyWith(collapsed: settledRail, onNavigate: _navigated(sidenav)),
              ),
            ),
          ),
        );
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // In the rail-only range the page keeps the rail's width: the sidenav floats.
                SizedBox(width: _tablet ? railWidth : panelWidth),
                Expanded(child: widget.body),
              ],
            ),
            if (floating)
              // A tap outside the floating sidenav closes it.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: closeFloatingSidenav,
                  child: const ExcludeSemantics(child: SizedBox.expand()),
                ),
              ),
            PositionedDirectional(start: 0, top: 0, bottom: 0, width: panelWidth, child: panel),
          ],
        );
      },
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
    required this.floating,
    required super.child,
  });

  final AerosScaffoldState state;
  final bool inline;
  final bool drawer;
  final bool drawerOpen;
  final bool railCollapsed;
  final bool canToggleRail;
  final bool floating;

  @override
  bool updateShouldNotify(_AerosScaffoldScope oldWidget) =>
      oldWidget.state != state ||
      oldWidget.inline != inline ||
      oldWidget.drawer != drawer ||
      oldWidget.drawerOpen != drawerOpen ||
      oldWidget.railCollapsed != railCollapsed ||
      oldWidget.canToggleRail != canToggleRail ||
      oldWidget.floating != floating;
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
