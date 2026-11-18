import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../shell.dart';
import '../widgets/gallery_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _tab = 0;
  int _segment = 1;
  int _page = 3;
  int _step = 2;

  static const _tabs = ['Details', 'Line items', 'Invoices', 'Activity'];
  static const _steps = ['Cart', 'Address', 'Payment', 'Review', 'Done'];

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return GalleryPage(
      title: 'Navigation',
      summary: 'Where am I, what else is here, and how far along.',
      breadcrumbs: [
        AerosBreadcrumbItem('Gallery', onTap: () => GalleryNav.of(context).open('overview')),
        const AerosBreadcrumbItem('Components'),
        const AerosBreadcrumbItem('Navigation'),
      ],
      children: [
        Section(
          'Tabs',
          note: 'Underline for the sections of a page; pill for a view switch inside a toolbar.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fills the width; scrolls sideways by itself when the tabs do not fit.
              AerosTabs(tabs: _tabs, selectedIndex: _tab, onChanged: (i) => setState(() => _tab = i)),
              const SizedBox(height: AerosSpacing.s3),
              Text('Showing: ${_tabs[_tab]}', style: AerosTypography.bodySm(color: a.fgSecondary)),
              const SizedBox(height: AerosSpacing.s6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AerosTabs(
                  tabs: const ['Day', 'Week', 'Month'],
                  variant: AerosTabVariant.pill,
                  selectedIndex: _segment,
                  onChanged: (i) => setState(() => _segment = i),
                ),
              ),
            ],
          ),
        ),
        Section(
          'Breadcrumb',
          note: 'The path to this record. The last crumb is where you are.',
          child: AerosBreadcrumb(
            items: [
              AerosBreadcrumbItem('Orders', onTap: () => GalleryNav.of(context).open('orders')),
              AerosBreadcrumbItem('Boson Machines', onTap: () {}),
              const AerosBreadcrumbItem('#4821'),
            ],
          ),
        ),
        Section(
          'Page header',
          note: 'Title, a line of context and the page\'s actions. The header of this page is one.',
          child: AerosCard(
            padding: const EdgeInsets.symmetric(vertical: AerosSpacing.s2),
            child: AerosPageHeader(
              title: 'Order #4821',
              subtitle: 'Boson Machines · placed 12 Nov 2026',
              breadcrumbs: const [AerosBreadcrumbItem('Orders'), AerosBreadcrumbItem('#4821')],
              leading: const AerosAvatar(initials: 'BM', tone: AerosAvatarTone.inverse),
              actions: [
                AerosButton.secondary(label: 'Print', onPressed: () {}),
                AerosButton(label: 'Mark shipped', onPressed: () {}),
              ],
            ),
          ),
        ),
        Section(
          'Pagination',
          note: 'Compact under a table; numbered when people jump between pages.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AerosPagination(page: _page, totalPages: 12, onChanged: (p) => setState(() => _page = p)),
              const SizedBox(height: AerosSpacing.s4),
              // Shows as many page numbers as fit, and the compact form when none do.
              AerosPagination(
                page: _page,
                totalPages: 12,
                variant: AerosPaginationVariant.numbered,
                onChanged: (p) => setState(() => _page = p),
              ),
            ],
          ),
        ),
        Section(
          'Stepper',
          note: 'How far through a fixed sequence.',
          child: Stacked(
            children: [
              AerosStepper(currentStep: _step, totalSteps: _steps.length, label: _steps[_step - 1]),
              Examples(
                spacing: AerosSpacing.s2,
                children: [
                  AerosButton.secondary(
                    label: 'Back',
                    size: AerosControlSize.sm,
                    onPressed: _step > 1 ? () => setState(() => _step--) : null,
                  ),
                  AerosButton(
                    label: 'Next',
                    size: AerosControlSize.sm,
                    onPressed: _step < _steps.length ? () => setState(() => _step++) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Section(
          'App shell',
          note: 'AerosScaffold, AerosTopnav and AerosSidenav are the frame of this gallery. '
              'Below: the shell in miniature, as a rail and at full width.',
          child: _MiniShells(),
        ),
      ],
    );
  }
}

/// Two small shells side by side. Each sits in an [AerosViewportScope], so
/// its scaffold decides inline-or-drawer from the width it was told, not from
/// the window's.
class _MiniShells extends StatelessWidget {
  const _MiniShells();

  @override
  Widget build(BuildContext context) => const AerosResponsiveGrid.auto(
        tileMinWidth: 420,
        children: [
          _MiniShell(collapsed: false),
          _MiniShell(collapsed: true),
        ],
      );
}

class _MiniShell extends StatefulWidget {
  const _MiniShell({required this.collapsed});

  final bool collapsed;

  @override
  State<_MiniShell> createState() => _MiniShellState();
}

class _MiniShellState extends State<_MiniShell> {
  String _selected = 'Orders';
  late bool _collapsed = widget.collapsed;

  AerosNavItem _item(String label, IconData icon, {String? section, int count = 0}) => AerosNavItem(
        label: label,
        icon: icon,
        section: section,
        count: count,
        selected: _selected == label,
        onTap: () => setState(() => _selected = label),
      );

  @override
  Widget build(BuildContext context) {
    return AerosSurface(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 380,
        // Tell the scaffold it is on a desktop-wide viewport: the sidenav stays inline.
        child: AerosViewportScope(
          width: AerosBreakpoints.lg,
          child: AerosScaffold(
            // The rail is this widget's state; the bar shows the toggle itself.
            onRailCollapsedChanged: (collapsed) => setState(() => _collapsed = collapsed),
            topnav: AerosTopnav(title: _selected),
            sidenav: AerosSidenav(
              collapsed: _collapsed,
              onExpandRequested: () => setState(() => _collapsed = false),
              header: AerosSidenavHeader(
                title: 'Boson Machines',
                subtitle: 'Seller workspace',
                mark: const AerosSidenavMark(icon: Icons.precision_manufacturing_outlined),
                onTap: () {},
              ),
              footer: AerosSidenavFooter(
                name: 'Parth Panchal',
                subtitle: 'Owner',
                actionIcon: Icons.logout,
                actionLabel: 'Sign out',
                onAction: () {},
              ),
              items: [
                _item('Home', Icons.home_outlined),
                _item('Orders', Icons.receipt_long_outlined, count: 12),
                AerosNavItem(
                  label: 'Catalogue',
                  icon: Icons.inventory_2_outlined,
                  section: 'Selling',
                  children: [
                    AerosNavItem(
                      label: 'Products',
                      selected: _selected == 'Products',
                      onTap: () => setState(() => _selected = 'Products'),
                    ),
                    AerosNavItem(
                      label: 'Price lists',
                      selected: _selected == 'Price lists',
                      onTap: () => setState(() => _selected = 'Price lists'),
                    ),
                  ],
                ),
                _item('Customers', Icons.people_outline, section: 'Selling'),
                _item('Reports', Icons.bar_chart_outlined, section: 'Insights'),
              ],
            ),
            body: Center(
              child: Text(_selected, style: AerosTypography.h2(color: context.aerosColors.fgMuted)),
            ),
          ),
        ),
      ),
    );
  }
}
