// Scenes for the 3.0 "API gaps closed before release" work: the page header,
// pagination and tabs at phone width, the scaffold's automatic top bar
// button, the custom sidenav header, and the new field / grid / button API.
import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _manyTabs = ['Overview', 'Details', 'Line items', 'Invoices', 'Shipments', 'Returns', 'Activity', 'Settings'];

// A 390 phone less the page gutter on each side.
const double _phone = 358;

List<AerosNavItem> _items() => [
      AerosNavItem(label: 'Home', icon: Icons.home_outlined, onTap: () {}),
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: () {}, selected: true, count: 12),
      AerosNavItem(label: 'Customers', icon: Icons.people_outline, onTap: () {}),
    ];

/// The wordmark where there is room, the mark in the rail.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    if (AerosSidenavScope.of(context).collapsed) return const AerosSidenavMark(letter: 'a');
    return const Row(
      children: [AerosWordmark(size: 20), Spacer(), AerosBadge(label: 'Seller', showDot: false)],
    );
  }
}

Widget _shell(BuildContext context, {bool collapsed = false, bool railToggle = false}) => AerosScaffold(
      onRailCollapsedChanged: railToggle ? (_) {} : null,
      topnav: const AerosTopnav(title: 'Orders'),
      sidenav: AerosSidenav(
        collapsed: collapsed,
        header: const AerosSidenavHeader.custom(semanticLabel: 'Aeros', child: _Brand()),
        footer: const AerosSidenavFooter(name: 'Parth Panchal', subtitle: 'Owner'),
        items: _items(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AerosPageHeader(
          padding: EdgeInsets.zero,
          title: 'Orders',
          subtitle: '128 orders in the last 30 days',
          actions: [
            AerosButton.secondary(label: 'Export', leading: const Icon(Icons.download_outlined), onPressed: () {}),
            AerosButton.primary(label: 'New order', leading: const Icon(Icons.add), onPressed: () {}),
          ],
        ),
      ),
    );

void main() {
  goldenMatrix(
    'gaps_page_header_narrow',
    size: const Size(390, 640),
    (context) => GoldenColumn(
      width: _phone,
      children: [
        GoldenSection(
          'AerosPageHeader at 358: actions under the title',
          child: AerosPageHeader(
            padding: EdgeInsets.zero,
            title: 'Orders',
            subtitle: '128 orders in the last 30 days',
            breadcrumbs: [AerosBreadcrumbItem('Patterns', onTap: () {}), const AerosBreadcrumbItem('Orders list')],
            actions: [
              AerosButton.secondary(label: 'Export', leading: const Icon(Icons.download_outlined), onPressed: () {}),
              AerosButton.primary(label: 'New order', leading: const Icon(Icons.add), onPressed: () {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosPageHeader at 358: long title, leading, three actions wrapping',
          child: AerosPageHeader(
            padding: EdgeInsets.zero,
            title: 'Quarterly reconciliation of outstanding purchase orders and credit notes',
            subtitle: 'Everything raised between April and June that has not been matched to an invoice yet.',
            leading: const AerosAvatar(initials: 'BM', tone: AerosAvatarTone.inverse),
            actions: [
              AerosButton.secondary(label: 'Export', onPressed: () {}),
              AerosButton.secondary(label: 'Share with finance', onPressed: () {}),
              AerosButton.primary(label: 'Mark reconciled', onPressed: () {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosPageHeader at 358: one small action stays beside a short title',
          child: AerosPageHeader(
            padding: EdgeInsets.zero,
            title: 'Team',
            actions: [AerosButton.icon(icon: const Icon(Icons.more_horiz), semanticLabel: 'More', onPressed: () {})],
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'gaps_pagination_narrow',
    size: const Size(390, 420),
    (context) => GoldenColumn(
      width: _phone,
      children: [
        for (final page in [1, 6, 12])
          GoldenSection(
            'AerosPagination numbered at 358, page $page of 12',
            child: AerosPagination(
              page: page,
              totalPages: 12,
              onChanged: (_) {},
              variant: AerosPaginationVariant.numbered,
            ),
          ),
        GoldenSection(
          'AerosPagination numbered at 200: the compact form',
          child: SizedBox(
            width: 200,
            child: AerosPagination(
              page: 6,
              totalPages: 12,
              onChanged: (_) {},
              variant: AerosPaginationVariant.numbered,
            ),
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'gaps_tabs_scrolled',
    size: const Size(390, 520),
    (context) => GoldenColumn(
      width: _phone,
      children: [
        GoldenSection(
          'AerosTabs underline at 358, first tab: fades at the end',
          child: AerosTabs(tabs: _manyTabs, selectedIndex: 0, onChanged: (_) {}),
        ),
        GoldenSection(
          'AerosTabs underline at 358, fifth tab scrolled into view: fades at both ends',
          child: AerosTabs(tabs: _manyTabs, selectedIndex: 4, onChanged: (_) {}),
        ),
        GoldenSection(
          'AerosTabs underline at 358, last tab: fades at the start',
          child: AerosTabs(tabs: _manyTabs, selectedIndex: 7, onChanged: (_) {}),
        ),
        GoldenSection(
          'AerosTabs pill at 358: segments share the width, labels truncate',
          child: AerosTabs(
            tabs: _manyTabs.sublist(0, 6),
            selectedIndex: 2,
            onChanged: (_) {},
            variant: AerosTabVariant.pill,
          ),
        ),
        GoldenSection(
          'AerosTabs pill that fits hugs its segments',
          child: AerosTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: 1,
            onChanged: (_) {},
            variant: AerosTabVariant.pill,
          ),
        ),
      ],
    ),
  );
  // Keyboard: focus enters the strip, End selects the last tab — the ring
  // moves with the selection and the strip scrolls to it.
  goldenMatrix(
    'gaps_tabs_scrolled_focused',
    size: const Size(390, 90),
    (context) {
      var selected = 3;
      return SizedBox(
        width: _phone,
        child: StatefulBuilder(
          builder: (context, setState) => AerosTabs(
            tabs: _manyTabs,
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
      );
    },
    act: (t) async {
      await focus(t, find.byType(AerosTabs));
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
    },
  );

  // The scaffold on a phone: the bar shows the menu button itself, and the
  // page header moves its actions under the title.
  goldenMatrix('gaps_shell_phone_menu_button', _shell, size: const Size(390, 844), padded: false);
  goldenMatrix(
    'gaps_shell_phone_drawer_custom_header',
    // Collapsed is ignored in a drawer: the custom header shows the wordmark.
    (context) => _shell(context, collapsed: true),
    size: const Size(390, 844),
    padded: false,
    act: (t) async => t.state<AerosScaffoldState>(find.byType(AerosScaffold)).openDrawer(),
  );
  // Inline, with the rail owned by the app: the bar shows the collapse /
  // expand toggle, and the custom header follows the rail.
  goldenMatrix(
    'gaps_shell_desktop_rail_toggle',
    (context) => _shell(context, railToggle: true),
    size: const Size(1024, 480),
    padded: false,
  );
  goldenMatrix(
    'gaps_shell_desktop_rail_collapsed',
    (context) => _shell(context, collapsed: true, railToggle: true),
    size: const Size(1024, 480),
    padded: false,
  );

  goldenMatrix(
    'gaps_fields',
    size: const Size(390, 520),
    (context) => GoldenColumn(
      width: _phone,
      children: [
        GoldenSection(
          'AerosSelect helperText',
          child: AerosSelect<String>(
            label: 'Payment terms',
            helperText: 'Applies to every order from this buyer',
            items: const [AerosSelectItem(value: 'net30', label: 'Net 30')],
            value: 'net30',
            onChanged: (_) {},
          ),
        ),
        GoldenSection(
          'AerosDropdownSearch helperText',
          child: AerosDropdownSearch<String>(
            label: 'City',
            helperText: 'Where the order ships from',
            hint: 'Select a city',
            items: const ['Ahmedabad', 'Pune'],
            itemAsString: (s) => s,
            onChanged: (_) {},
          ),
        ),
        GoldenSection(
          'AerosDropdownSearch required, errorText',
          child: AerosDropdownSearch<String>(
            label: 'Warehouse',
            required: true,
            errorText: 'Choose a warehouse',
            hint: 'Search warehouses',
            items: const ['Ahmedabad', 'Pune'],
            itemAsString: (s) => s,
            onChanged: (_) {},
          ),
        ),
        GoldenSection(
          'AerosDropdownSearch errorText, no label',
          child: AerosDropdownSearch<String>(
            errorText: 'Choose a city',
            selectedItem: 'Pune',
            showClearButton: true,
            items: const ['Ahmedabad', 'Pune'],
            itemAsString: (s) => s,
            onChanged: (_) {},
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'gaps_buttons_grid_stats',
    size: const Size(760, 800),
    (context) => GoldenColumn(
      width: 720,
      children: [
        GoldenSection(
          'AerosButton named constructors with leading and trailing',
          child: GoldenRow(
            children: [
              AerosButton.primary(label: 'Continue', trailing: const Icon(Icons.arrow_forward), onPressed: () {}),
              AerosButton.secondary(label: 'Export', trailing: const Icon(Icons.expand_more), onPressed: () {}),
              AerosButton.ghost(label: 'Filters', leading: const Icon(Icons.tune), onPressed: () {}),
              AerosButton.danger(label: 'Delete', leading: const Icon(Icons.delete_outline), onPressed: () {}),
              AerosButton.dangerSubtle(label: 'Remove', leading: const Icon(Icons.close), onPressed: () {}),
              AerosButton.link(label: 'Learn more', trailing: const Icon(Icons.open_in_new), onPressed: () {}),
            ],
          ),
        ),
        const GoldenSection(
          'AerosStatCard row, plain and mono: the delta lines are level',
          child: AerosResponsiveGrid.auto(
            crossAxisCount: AerosResponsiveValue.all(3),
            equalHeights: true,
            children: [
              AerosStatCard(label: 'Orders', value: '128', delta: '12% vs last month', deltaDirection: AerosDelta.up),
              AerosStatCard(
                label: 'Revenue',
                value: '₹ 4,82,000',
                mono: true,
                delta: '8% vs last month',
                deltaDirection: AerosDelta.up,
              ),
              AerosStatCard(label: 'Overdue', value: '3', delta: 'No change'),
            ],
          ),
        ),
        const GoldenSection(
          'AerosResponsiveGrid.auto tileMinWidth 200: tiles keep their own height',
          child: AerosResponsiveGrid.auto(
            tileMinWidth: 200,
            children: [
              AerosCard(title: 'Short', child: Text('One line.')),
              AerosCard(
                title: 'Taller',
                child: Text('Each row is as tall as its tallest tile; the others keep their own height.'),
              ),
              AerosCard(title: 'Short again', child: Text('One line.')),
              AerosCard(title: 'Second row', child: Text('Starts under the tallest tile above.')),
            ],
          ),
        ),
        const GoldenSection(
          'AerosResponsiveGrid.auto equalHeights',
          child: AerosResponsiveGrid.auto(
            tileMinWidth: 200,
            equalHeights: true,
            children: [
              AerosCard(title: 'Short', child: Text('One line.')),
              AerosCard(
                title: 'Taller',
                child: Text('Each row is as tall as its tallest tile, and with equalHeights so is every tile in it.'),
              ),
              AerosCard(title: 'Short again', child: Text('One line.')),
            ],
          ),
        ),
      ],
    ),
  );
}
