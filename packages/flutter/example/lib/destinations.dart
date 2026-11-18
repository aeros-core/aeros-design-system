import 'package:flutter/material.dart';

import 'pages/badges_page.dart';
import 'pages/buttons_page.dart';
import 'pages/cards_page.dart';
import 'pages/create_order_page.dart';
import 'pages/data_page.dart';
import 'pages/feedback_page.dart';
import 'pages/fields_page.dart';
import 'pages/foundations_page.dart';
import 'pages/navigation_page.dart';
import 'pages/orders_page.dart';
import 'pages/overlays_page.dart';
import 'pages/overview_page.dart';
import 'pages/responsive_page.dart';
import 'pages/selection_page.dart';

/// One page of the gallery, and its row in the sidenav.
class Destination {
  const Destination({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    this.section,
    this.summary = '',
  });

  final String id;
  final String label;
  final IconData icon;

  /// The sidenav group; null for the unlabelled group at the top.
  final String? section;

  /// One line for the overview page.
  final String summary;
  final WidgetBuilder builder;
}

const _foundations = 'Foundations';
const _components = 'Components';
const _patterns = 'Patterns';

/// Every page, in sidenav order. A section's pages are contiguous.
final List<Destination> destinations = [
  Destination(id: 'overview', label: 'Overview', icon: Icons.home_outlined, builder: (_) => const OverviewPage()),
  Destination(
    id: 'foundations',
    label: 'Tokens & primitives',
    icon: Icons.palette_outlined,
    section: _foundations,
    summary: 'Colour, type, elevation, radii, spacing, control sizes.',
    builder: (_) => const FoundationsPage(),
  ),
  Destination(
    id: 'buttons',
    label: 'Buttons',
    icon: Icons.smart_button_outlined,
    section: _components,
    summary: 'Six variants, five sizes, icon-only, loading.',
    builder: (_) => const ButtonsPage(),
  ),
  Destination(
    id: 'fields',
    label: 'Fields',
    icon: Icons.text_fields,
    section: _components,
    summary: 'Text, search, tags, select, measurement, search dropdown.',
    builder: (_) => const FieldsPage(),
  ),
  Destination(
    id: 'selection',
    label: 'Selection',
    icon: Icons.check_box_outlined,
    section: _components,
    summary: 'Checkbox, radio, switch, chips, sliders.',
    builder: (_) => const SelectionPage(),
  ),
  Destination(
    id: 'badges',
    label: 'Badges & avatars',
    icon: Icons.label_outline,
    section: _components,
    summary: 'Status badges, counts, tags, avatars.',
    builder: (_) => const BadgesPage(),
  ),
  Destination(
    id: 'cards',
    label: 'Cards',
    icon: Icons.dashboard_outlined,
    section: _components,
    summary: 'Card, stat card, intent card, empty state.',
    builder: (_) => const CardsPage(),
  ),
  Destination(
    id: 'feedback',
    label: 'Feedback',
    icon: Icons.notifications_none,
    section: _components,
    summary: 'Alerts, progress, snackbars, tooltips.',
    builder: (_) => const FeedbackPage(),
  ),
  Destination(
    id: 'navigation',
    label: 'Navigation',
    icon: Icons.explore_outlined,
    section: _components,
    summary: 'Tabs, breadcrumb, pagination, stepper, page header, the shell.',
    builder: (_) => const NavigationPage(),
  ),
  Destination(
    id: 'overlays',
    label: 'Overlays',
    icon: Icons.layers_outlined,
    section: _components,
    summary: 'Dialog, sheet, menu, popover, confirm.',
    builder: (_) => const OverlaysPage(),
  ),
  Destination(
    id: 'data',
    label: 'Data',
    icon: Icons.table_rows_outlined,
    section: _components,
    summary: 'Data table, price breakdown, variant and attribute pickers.',
    builder: (_) => const DataPage(),
  ),
  Destination(
    id: 'responsive',
    label: 'Responsive',
    icon: Icons.devices_outlined,
    section: _components,
    summary: 'Breakpoints, responsive values, grid, two columns.',
    builder: (_) => const ResponsivePage(),
  ),
  Destination(
    id: 'orders',
    label: 'Orders list',
    icon: Icons.receipt_long_outlined,
    section: _patterns,
    summary: 'A list screen: filters, table, pagination, row actions.',
    builder: (_) => const OrdersPage(),
  ),
  Destination(
    id: 'create-order',
    label: 'Create order',
    icon: Icons.add_box_outlined,
    section: _patterns,
    summary: 'A form screen: steps, fields, a live price, validation.',
    builder: (_) => const CreateOrderPage(),
  ),
];
