import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../sample_data.dart';
import '../shell.dart';
import '../widgets/gallery_page.dart';

/// Pattern: a list screen. Page header with the primary action, a summary
/// row, filters, the table with selection and sorting, pagination, and a
/// side sheet for the row that was opened.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const _pageSize = 5;

  final _search = TextEditingController();
  OrderStatus? _status;
  AerosDataSort _sort = const AerosDataSort(columnIndex: 0, ascending: false);
  Set<Order> _selected = {};
  int _page = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Order> get _filtered {
    final query = _search.text.trim().toLowerCase();
    final rows = orders
        .where((o) => _status == null || o.status == _status)
        .where((o) => query.isEmpty || o.buyer.toLowerCase().contains(query) || o.id.contains(query))
        .toList();
    int compare(Order a, Order b) => switch (_sort.columnIndex) {
          0 => a.id.compareTo(b.id),
          1 => a.buyer.compareTo(b.buyer),
          3 => a.units.compareTo(b.units),
          _ => a.total.compareTo(b.total),
        };
    rows.sort((a, b) => _sort.ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  void _refilter(VoidCallback change) => setState(() {
        change();
        _page = 1;
        _selected = {};
      });

  Future<void> _open(Order order) => AerosSheet.show<void>(
        context,
        side: AerosBreakpoints.isAtLeast(context, AerosBreakpoint.md) ? AerosSheetSide.right : AerosSheetSide.bottom,
        size: AerosSheetSize.sm,
        builder: (context) => AerosSheet(
          title: 'Order ${order.id}',
          description: '${order.buyer} · ${order.city}',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AerosBadge(label: order.status.label, tone: order.status.tone),
              ),
              const SizedBox(height: AerosSpacing.s4),
              AerosPriceBreakdown(
                data: priceFor(quantity: order.units, gsm: 250, printed: true),
                initiallyExpanded: true,
                dense: true,
              ),
            ],
          ),
          actions: [
            AerosButton.secondary(label: 'Close', onPressed: () => Navigator.of(context).pop()),
            AerosButton(label: 'Open order', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      );

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final ok = await AerosConfirmDialog.show(
      context,
      title: 'Delete $count ${count == 1 ? 'order' : 'orders'}?',
      body: 'This is a demo: nothing is deleted, the selection is just cleared.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _selected = {});
    AerosSnackbar.show(context, '$count deleted', tone: AerosSnackbarTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    final pages = (rows.length / _pageSize).ceil().clamp(1, 99);
    final page = _page.clamp(1, pages);
    final visible = rows.skip((page - 1) * _pageSize).take(_pageSize).toList();
    final overdue = orders.where((o) => o.status == OrderStatus.overdue).length;

    return GalleryPage(
      title: 'Orders',
      summary: '${orders.length} orders in the last 30 days',
      breadcrumbs: const [AerosBreadcrumbItem('Patterns'), AerosBreadcrumbItem('Orders list')],
      actions: [
        AerosButton.secondary(label: 'Export', leading: const Icon(Icons.download_outlined), onPressed: () {}),
        AerosButton(
          label: 'New order',
          leading: const Icon(Icons.add),
          onPressed: () => GalleryNav.of(context).open('create-order'),
        ),
      ],
      children: [
        AerosResponsiveGrid.auto(
          tileMinWidth: 200,
          equalHeights: true,
          children: [
            AerosStatCard(
              label: 'Orders',
              value: '${orders.length}',
              delta: '12% vs last month',
              deltaDirection: AerosDelta.up,
            ),
            AerosStatCard(
              label: 'Revenue',
              value: rupees(orders.fold<int>(0, (sum, o) => sum + o.total)),
              mono: true,
              delta: '8% vs last month',
              deltaDirection: AerosDelta.up,
            ),
            AerosStatCard(label: 'Overdue', value: '$overdue', delta: 'No change'),
          ],
        ),
        const SizedBox(height: AerosSpacing.s6),
        // Filters: search, then one chip per status.
        Wrap(
          spacing: AerosSpacing.s2,
          runSpacing: AerosSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: AerosMetricTokens.layoutSidebarMobile,
              child: AerosSearchField(
                controller: _search,
                hint: 'Search buyer or order',
                onChanged: (_) => _refilter(() {}),
                onClear: () => _refilter(() {}),
              ),
            ),
            AerosFilterChip(
              label: 'All',
              count: orders.length,
              selected: _status == null,
              onTap: () => _refilter(() => _status = null),
            ),
            for (final status in OrderStatus.values)
              AerosFilterChip(
                label: status.label,
                count: orders.where((o) => o.status == status).length,
                selected: _status == status,
                tone: status == OrderStatus.overdue ? AerosFilterChipTone.warning : AerosFilterChipTone.neutral,
                onTap: () => _refilter(() => _status = status),
              ),
          ],
        ),
        const SizedBox(height: AerosSpacing.s3),
        if (_selected.isNotEmpty) ...[
          // Bulk actions appear only while rows are selected.
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_selected.length} selected',
                  style: AerosTypography.labelSm(color: context.aerosColors.fgPrimary),
                ),
              ),
              AerosButton.ghost(
                label: 'Clear',
                size: AerosControlSize.sm,
                onPressed: () => setState(() => _selected = {}),
              ),
              const SizedBox(width: AerosSpacing.s2),
              AerosButton(
                label: 'Delete',
                size: AerosControlSize.sm,
                variant: AerosButtonVariant.dangerSubtle,
                onPressed: _deleteSelected,
              ),
            ],
          ),
          const SizedBox(height: AerosSpacing.s3),
        ],
        AerosDataTable<Order>(
          rows: visible,
          selected: _selected,
          onSelectionChanged: (selected) => setState(() => _selected = selected),
          sort: _sort,
          onSortChanged: (sort) => setState(() => _sort = sort),
          onRowTap: _open,
          rowSemanticLabel: (order) => 'Order ${order.id}, ${order.buyer}',
          emptyState: AerosEmptyState(
            icon: Icons.search_off,
            title: 'No orders match',
            description: 'Try a shorter search or another status.',
            action: AerosButton.secondary(
              label: 'Clear filters',
              size: AerosControlSize.sm,
              onPressed: () => _refilter(() {
                _search.clear();
                _status = null;
              }),
            ),
          ),
          columns: [
            AerosDataColumn(label: 'Order', sortable: true, emphasis: true, cell: (o) => Text(o.id)),
            AerosDataColumn(
              label: 'Buyer',
              sortable: true,
              cell: (o) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AerosAvatar(initials: o.buyer.substring(0, 1), size: AerosAvatarSize.xs),
                  const SizedBox(width: AerosSpacing.s2),
                  Text(o.buyer),
                ],
              ),
            ),
            AerosDataColumn(label: 'Status', cell: (o) => AerosBadge(label: o.status.label, tone: o.status.tone)),
            AerosDataColumn(label: 'Units', numeric: true, sortable: true, cell: (o) => Text(o.unitsLabel)),
            AerosDataColumn(label: 'Total', numeric: true, sortable: true, cell: (o) => Text(o.totalLabel)),
            AerosDataColumn(
              label: '',
              // Fixed, so the row actions do not take a share of the spare width.
              width: AerosSpacing.s14,
              cell: (o) => AerosMenu(
                align: AerosPopoverAlign.end,
                semanticLabel: 'Actions for ${o.id}',
                items: [
                  AerosMenuItem<void>(label: 'Open', onSelected: () => _open(o)),
                  AerosMenuItem<void>(
                    label: 'Duplicate',
                    onSelected: () => AerosSnackbar.show(context, 'Duplicated ${o.id}'),
                  ),
                  const AerosMenuSeparator(),
                  AerosMenuItem<void>(
                    label: 'Delete',
                    destructive: true,
                    onSelected: () {
                      setState(() => _selected = {o});
                      _deleteSelected();
                    },
                  ),
                ],
                trigger: (context, menu) => AerosButton.icon(
                  icon: const Icon(Icons.more_horiz),
                  semanticLabel: 'Actions for ${o.id}',
                  size: AerosControlSize.sm,
                  onPressed: menu.toggle,
                ),
              ),
            ),
          ],
          footer: Row(
            children: [
              Text(
                rows.isEmpty
                    ? 'No orders'
                    : '${(page - 1) * _pageSize + 1}–${(page - 1) * _pageSize + visible.length} of ${rows.length}',
                style: AerosTypography.caption(color: context.aerosColors.fgMuted),
              ),
              const SizedBox(width: AerosSpacing.s3),
              // The pagination takes the rest of the row and shows the page
              // numbers that fit in it (previous / next alone on a phone).
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AerosPagination(
                    page: page,
                    totalPages: pages,
                    variant: AerosPaginationVariant.numbered,
                    onChanged: (p) => setState(() => _page = p),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
