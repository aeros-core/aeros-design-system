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
  late String _page = widget.initialPage ?? destinations.first.id;
  bool _rail = false;

  Destination get _current => destinations.firstWhere((d) => d.id == _page);

  void _open(String id) => setState(() => _page = id);

  @override
  Widget build(BuildContext context) {
    // The same test AerosScaffold makes: inline from `md`, a drawer below.
    final inline = AerosBreakpoints.isAtLeast(context, AerosBreakpoint.md);
    final pointer = widget.density.isPointer;

    return GalleryNav(
      open: _open,
      child: AerosScaffold(
        topnav: AerosTopnav(
          title: _current.label,
          leading: inline
              ? AerosTooltip(
                  message: _rail ? 'Expand sidebar' : 'Collapse sidebar',
                  child: AerosButton.icon(
                    icon: Icon(_rail ? Icons.menu : Icons.menu_open),
                    semanticLabel: _rail ? 'Expand sidebar' : 'Collapse sidebar',
                    onPressed: () => setState(() => _rail = !_rail),
                  ),
                )
              // Below the Scaffold, so it can reach it to open the drawer.
              : Builder(
                  builder: (context) => AerosButton.icon(
                    icon: const Icon(Icons.menu),
                    semanticLabel: 'Open navigation',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
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
          collapsed: _rail,
          onExpandRequested: () => setState(() => _rail = false),
          // The rail has room for a mark only; the full sidebar (and the
          // drawer, which is never a rail) shows the wordmark.
          header: _rail && inline
              ? const AerosSidenavHeader(title: 'Aeros', mark: AerosSidenavMark(letter: 'a'))
              : const _WordmarkHeader(),
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
                  // In the drawer, choosing a page closes it.
                  if (!inline) Navigator.of(context).maybePop();
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

/// The sidebar's top block with the wordmark: one app header high over a
/// hairline, like [AerosSidenavHeader], whose title can only be text.
class _WordmarkHeader extends StatelessWidget {
  const _WordmarkHeader();

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      height: AerosDensity.of(context).sizes.header,
      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline)),
      ),
      child: const Row(
        children: [
          AerosWordmark(size: 20),
          Spacer(),
          AerosBadge(label: 'Flutter 3.0', showDot: false),
        ],
      ),
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
