import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

List<AerosNavItem> _items() => [
      AerosNavItem(label: 'Home', icon: Icons.home_outlined, onTap: () {}),
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: () {}, selected: true, count: 12),
      AerosNavItem(label: 'Messages', icon: Icons.chat_bubble_outline, onTap: () {}, count: 128),
      AerosNavItem(
        label: 'Catalogue',
        icon: Icons.inventory_2_outlined,
        section: 'Selling',
        children: [
          AerosNavItem(label: 'Products', onTap: () {}),
          AerosNavItem(label: 'Price lists', onTap: () {}),
          AerosNavItem(label: 'Categories', onTap: () {}, count: 3),
        ],
      ),
      AerosNavItem(label: 'Customers', icon: Icons.people_outline, onTap: () {}),
      AerosNavItem(label: 'Reports', icon: Icons.bar_chart_outlined, onTap: () {}, section: 'Insights'),
      AerosNavItem(label: 'Settings', icon: Icons.settings_outlined, onTap: () {}),
      const AerosNavItem(label: 'No handler'),
    ];

AerosSidenav _sidenav({AerosSidenavDensity density = AerosSidenavDensity.pointer, bool collapsed = false}) =>
    AerosSidenav(
      density: density,
      collapsed: collapsed,
      header: AerosSidenavHeader(title: 'Boson Machines', subtitle: 'Seller workspace', onTap: () {}),
      footer: AerosSidenavFooter(
        name: 'Parth Panchal',
        subtitle: 'Owner',
        actionIcon: Icons.logout,
        actionLabel: 'Sign out',
        onAction: () {},
      ),
      items: _items(),
    );

Widget _shell(
  BuildContext context, {
  AerosSidenavDensity density = AerosSidenavDensity.pointer,
  bool collapsed = false,
}) =>
    AerosScaffold(
      topnav: AerosTopnav(
        title: 'Orders',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 12),
            child: AerosAvatar(initials: 'PP', size: AerosAvatarSize.sm),
          ),
        ],
      ),
      sidenav: _sidenav(density: density, collapsed: collapsed),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('128 orders in the last 30 days', style: AerosTypography.bodyMd(color: context.aerosColors.fgSecondary)),
            const SizedBox(height: 16),
            const AerosCard(title: 'Today', child: AerosStepper(currentStep: 2, totalSteps: 5, label: 'Packed')),
          ],
        ),
      ),
    );

void main() {
  const desktop = Size(1280, 800);
  const phone = Size(390, 844);

  // Desktop: the rail sits inline.
  goldenMatrix('shell_desktop', _shell, size: desktop, padded: false);
  goldenMatrix(
    'shell_desktop_touch_rail',
    (context) => _shell(context, density: AerosSidenavDensity.touch),
    size: desktop,
    padded: false,
  );
  goldenMatrix(
    'shell_desktop_nav_item_hovered',
    _shell,
    size: desktop,
    padded: false,
    act: (t) => hover(t, find.text('Customers')),
  );
  goldenMatrix(
    'shell_desktop_nav_item_focused',
    _shell,
    size: desktop,
    padded: false,
    act: (t) => focus(t, find.byType(AerosSidenav)),
  );

  // Collapsed to the icon-only rail; a row hovered shows its label as a tooltip.
  goldenMatrix(
    'shell_desktop_rail',
    (context) => _shell(context, collapsed: true),
    size: desktop,
    padded: false,
  );
  goldenMatrix(
    'shell_desktop_rail_item_hovered',
    (context) => _shell(context, collapsed: true),
    size: desktop,
    padded: false,
    settle: GoldenSettle.bounded,
    act: (t) => hover(t, find.byIcon(Icons.people_outline)),
  );
  goldenMatrix(
    'shell_desktop_rail_item_focused',
    (context) => _shell(context, collapsed: true),
    size: desktop,
    padded: false,
    act: (t) => focus(t, find.byType(AerosSidenav)),
  );

  // Phone: the rail moves into a drawer.
  goldenMatrix('shell_phone', _shell, size: phone, padded: false);
  goldenMatrix(
    'shell_phone_drawer_open',
    (context) => _shell(context, density: AerosSidenavDensity.touch),
    size: phone,
    padded: false,
    act: (t) async => t.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer(),
  );

  goldenMatrix(
    'shell_topnav',
    size: const Size(760, 440),
    (context) => GoldenColumn(
      width: 720,
      children: [
        const GoldenSection('AerosTopnav title', child: AerosTopnav(title: 'Orders')),
        GoldenSection(
          'AerosTopnav leading, title, actions',
          child: AerosTopnav(
            title: 'Order #4821',
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
            actions: [
              AerosButton.secondary(label: 'Export', onPressed: () {}, size: AerosControlSize.sm),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
        const GoldenSection(
          'AerosTopnav title widget, custom height',
          child: AerosTopnav(titleWidget: AerosWordmark(size: 22), height: 48),
        ),
        GoldenSection(
          'AerosTopnav custom background',
          child: AerosTopnav(title: 'Orders', backgroundColor: context.aerosColors.bgSubtle),
        ),
      ],
    ),
  );

  goldenMatrix(
    'shell_sidenav_blocks',
    size: const Size(560, 420),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 240,
          children: [
            const GoldenSection('AerosSidenavHeader', child: AerosSidenavHeader(title: 'Boson Machines')),
            GoldenSection(
              'AerosSidenavHeader subtitle, switcher',
              child: AerosSidenavHeader(title: 'Boson Machines', subtitle: 'Seller workspace', onTap: () {}),
            ),
            const GoldenSection(
              'AerosSidenavHeader custom mark',
              child: AerosSidenavHeader(
                title: 'FactoryOS',
                mark: AerosSidenavMark(icon: Icons.precision_manufacturing_outlined),
              ),
            ),
            const GoldenSection(
              'AerosSidenavMark',
              child: GoldenRow(
                children: [
                  AerosSidenavMark(letter: 'a'),
                  AerosSidenavMark(icon: Icons.bolt),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 240,
          children: [
            const GoldenSection('AerosSidenavFooter', child: AerosSidenavFooter(name: 'Parth Panchal')),
            GoldenSection(
              'AerosSidenavFooter subtitle, action',
              child: AerosSidenavFooter(
                name: 'Parth Panchal',
                subtitle: 'Owner',
                actionIcon: Icons.logout,
                actionLabel: 'Sign out',
                onAction: () {},
              ),
            ),
            const GoldenSection(
              'AerosSidenavFooter custom avatar',
              child: AerosSidenavFooter(
                name: 'Parth Panchal',
                subtitle: 'parth@example.com',
                avatar: AerosAvatar(initials: 'PP', size: AerosAvatarSize.xs, tone: AerosAvatarTone.inverse),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // The rail on its own, at both row densities.
  for (final density in AerosSidenavDensity.values) {
    goldenMatrix(
      'shell_sidenav_rail_${density.name}',
      size: const Size(100, 520),
      (context) => SizedBox(
        width: AerosMetricTokens.layoutSidebarRail,
        height: 480,
        child: _sidenav(density: density, collapsed: true),
      ),
    );
  }

  // A rail with no header or footer, and plain items.
  goldenMatrix(
    'shell_sidenav_bare',
    size: const Size(280, 320),
    (context) => SizedBox(
      width: 240,
      height: 280,
      child: AerosSidenav(
        items: [
          AerosNavItem(label: 'Inbox', onTap: () {}, selected: true),
          AerosNavItem(label: 'Sent', onTap: () {}),
          AerosNavItem(label: 'Drafts', onTap: () {}, count: 2),
        ],
      ),
    ),
  );
}
