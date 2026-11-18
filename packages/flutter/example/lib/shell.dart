import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import 'destinations.dart';

/// Lets a page open another page: `GalleryNav.of(context).open('buttons')`.
class GalleryNav extends InheritedWidget {
  const GalleryNav({super.key, required this.open, required super.child});

  final ValueChanged<String> open;

  static GalleryNav of(BuildContext context) => context.getInheritedWidgetOfExactType<GalleryNav>()!;

  @override
  bool updateShouldNotify(GalleryNav oldWidget) => false;
}

/// The app shell: [AerosScaffold] with the [AerosSidenav] (inline from the
/// `md` breakpoint, a drawer below it) and the [AerosTopnav].
class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.density,
    required this.onDensityChanged,
    this.initialPage,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AerosDensity density;
  final ValueChanged<AerosDensity> onDensityChanged;
  final String? initialPage;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  /// Reaches the scaffold from above it, to close the drawer.
  final _shell = GlobalKey<AerosScaffoldState>();
  late String _page = widget.initialPage ?? destinations.first.id;

  /// Owns whether the wide-window sidenav is collapsed to the rail. An app would give it `load`
  /// and `save` to remember the choice.
  final _sidebar = AerosSidebarController();

  @override
  void dispose() {
    _sidebar.dispose();
    super.dispose();
  }

  Destination get _current => destinations.firstWhere((d) => d.id == _page);

  void _open(String id) => setState(() => _page = id);

  @override
  Widget build(BuildContext context) {
    final pointer = widget.density.isPointer;

    return GalleryNav(
      open: _open,
      child: AerosScaffold(
        key: _shell,
        sidebarController: _sidebar,
        topnav: AerosTopnav(
          title: _current.label,
          // No leading: inside AerosScaffold the bar shows the menu button
          // (sidenav in a drawer) or the rail toggle (sidenav inline) itself.
          actions: [
            AerosTooltip(
              message: pointer ? 'Density: pointer' : 'Density: touch',
              child: AerosButton.icon(
                icon: Icon(pointer ? Icons.mouse_outlined : Icons.touch_app_outlined),
                semanticLabel: pointer ? 'Switch to touch density' : 'Switch to pointer density',
                onPressed: () => widget.onDensityChanged(pointer ? AerosDensity.touch : AerosDensity.pointer),
              ),
            ),
            _ThemeMenu(mode: widget.themeMode, onChanged: widget.onThemeModeChanged),
          ],
        ),
        sidenav: AerosSidenav(
          density: pointer ? AerosSidenavDensity.pointer : AerosSidenavDensity.touch,
          header: const AerosSidenavHeader.custom(semanticLabel: 'Aeros Design System', child: _Brand()),
          footer: const AerosSidenavFooter(
            name: 'aeros_design_system',
            subtitle: '3.0 · Crisp precision',
            avatar: AerosAvatar(initials: '3', size: AerosAvatarSize.sm, tone: AerosAvatarTone.inverse),
          ),
          items: [
            for (final destination in destinations)
              AerosNavItem(
                key: ValueKey('nav:${destination.id}'),
                label: destination.label,
                icon: destination.icon,
                section: destination.section,
                selected: destination.id == _page,
                onTap: () {
                  _open(destination.id);
                  // In the drawer, choosing a page closes it (a no-op inline).
                  _shell.currentState?.closeDrawer();
                },
              ),
          ],
        ),
        // A page keeps its own state only while it is open.
        body: KeyedSubtree(key: ValueKey(_page), child: Builder(builder: _current.builder)),
      ),
    );
  }
}

/// What the sidenav's header holds: the wordmark and a version badge — or,
/// where the rail has room for a mark only, the mark. [AerosSidenavScope]
/// says which (the drawer is never a rail).
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    if (AerosSidenavScope.of(context).collapsed) return const AerosSidenavMark(letter: 'a');
    return const Row(
      children: [
        AerosWordmark(size: 20),
        Spacer(),
        AerosBadge(label: 'Flutter 3.0', showDot: false),
      ],
    );
  }
}

/// Light / dark / system, as a menu of radio rows.
class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  static const _modes = <ThemeMode, (String, IconData)>{
    ThemeMode.light: ('Light', Icons.light_mode_outlined),
    ThemeMode.dark: ('Dark', Icons.dark_mode_outlined),
    ThemeMode.system: ('System', Icons.brightness_auto_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return AerosMenu(
      align: AerosPopoverAlign.end,
      semanticLabel: 'Theme',
      items: [
        const AerosMenuLabel('Theme'),
        for (final entry in _modes.entries)
          AerosMenuRadioItem<ThemeMode>(
            label: entry.value.$1,
            leading: Icon(entry.value.$2),
            value: entry.key,
            groupValue: mode,
            onChanged: onChanged,
          ),
      ],
      trigger: (context, menu) => AerosTooltip(
        message: 'Theme: ${_modes[mode]!.$1.toLowerCase()}',
        child: AerosButton.icon(
          icon: Icon(_modes[mode]!.$2),
          semanticLabel: 'Theme, ${_modes[mode]!.$1}',
          onPressed: menu.toggle,
        ),
      ),
    );
  }
}
