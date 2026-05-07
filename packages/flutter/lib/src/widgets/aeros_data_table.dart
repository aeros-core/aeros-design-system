import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_empty_state.dart';

/// One column in an [AerosDataTable].
class AerosDataColumn<T> {
  const AerosDataColumn({
    required this.label,
    required this.cell,
    this.width,
    this.sortable = false,
    this.numeric = false,
  });

  /// Column header text. For richer headers use [AerosDataColumn.custom].
  final String label;

  /// Builds the cell widget for one row.
  final Widget Function(T row) cell;

  /// Optional fixed pixel width. If null, the column flexes.
  final double? width;

  final bool sortable;

  /// Right-aligns the cell content. Use for numbers / amounts.
  final bool numeric;
}

/// State of a sortable column.
class AerosDataSort {
  const AerosDataSort({required this.columnIndex, required this.ascending});
  final int columnIndex;
  final bool ascending;
}

/// Light, themed data table for admin list screens.
///
/// Wraps Flutter's [DataTable] with Aeros tokens, optional row selection,
/// sortable columns, an empty-state slot, and a loading overlay.
///
/// ```dart
/// AerosDataTable<User>(
///   rows: state.users,
///   columns: [
///     AerosDataColumn(label: 'Name',  cell: (u) => Text(u.name)),
///     AerosDataColumn(label: 'Email', cell: (u) => Text(u.email)),
///     AerosDataColumn(label: 'Status', cell: (u) => AerosBadge(label: u.status)),
///   ],
///   selected: selectedUsers,
///   onSelectionChanged: (s) => setState(() => selectedUsers = s),
///   loading: state is UserLoadingState,
///   footer: AerosPagination(
///     page: page,
///     totalPages: totalPages,
///     onChanged: (p) => bloc.add(LoadPage(p)),
///   ),
/// )
/// ```
class AerosDataTable<T> extends StatelessWidget {
  const AerosDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.selected,
    this.onSelectionChanged,
    this.sort,
    this.onSortChanged,
    this.loading = false,
    this.emptyState,
    this.footer,
    this.onRowTap,
    this.rowKey,
  });

  final List<T> rows;
  final List<AerosDataColumn<T>> columns;

  /// Pass a non-null set to enable a checkbox column.
  /// `null` = no selection UI.
  final Set<T>? selected;
  final ValueChanged<Set<T>>? onSelectionChanged;

  final AerosDataSort? sort;
  final ValueChanged<AerosDataSort>? onSortChanged;

  final bool loading;

  /// Shown when [rows] is empty and [loading] is false.
  /// Defaults to a basic [AerosEmptyState] saying "No data".
  final Widget? emptyState;

  /// Optional widget rendered below the table (e.g. [AerosPagination]).
  final Widget? footer;

  /// Optional row tap handler.
  final ValueChanged<T>? onRowTap;

  /// Required if [selected] is provided and `T` doesn't have stable equality
  /// across rebuilds — extracts a stable key for set membership.
  final dynamic Function(T row)? rowKey;

  bool get _hasSelection => selected != null;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    if (rows.isEmpty && !loading) {
      return Container(
        decoration: BoxDecoration(
          color: a.bgSurface,
          borderRadius: AerosRadii.brMd,
          border: Border.all(color: a.borderDefault),
        ),
        padding: const EdgeInsets.symmetric(vertical: AerosSpacing.s8),
        child: Center(
          child: emptyState ??
              const AerosEmptyState(
                title: 'No data',
                description: 'There are no records to show yet.',
              ),
        ),
      );
    }

    final tableColumns = <DataColumn>[
      for (var i = 0; i < columns.length; i++)
        DataColumn(
          label: Text(
            columns[i].label,
            style: AerosTypography.bodySm(color: a.fgSecondary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          numeric: columns[i].numeric,
          onSort: columns[i].sortable && onSortChanged != null
              ? (idx, asc) => onSortChanged!(
                  AerosDataSort(columnIndex: idx, ascending: asc))
              : null,
        ),
    ];

    final dataRows = rows.map((row) {
      final isSelected = _isSelected(row);
      // When BOTH selection and onRowTap are wired, the checkbox column toggles
      // selection (via DataRow.onSelectChanged) and cell taps navigate (via
      // DataCell.onTap). DataCell.onTap takes precedence on the cell click,
      // so the two interactions don't fight each other.
      final cellTap = (_hasSelection && onRowTap != null)
          ? () => onRowTap!(row)
          : null;
      return DataRow(
        selected: isSelected,
        onSelectChanged: _hasSelection
            ? (v) => _toggleRow(row, v ?? false)
            : (onRowTap == null ? null : (_) => onRowTap!(row)),
        cells: [
          for (final col in columns)
            DataCell(
              Align(
                alignment: col.numeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: col.cell(row),
              ),
              onTap: cellTap,
            ),
        ],
      );
    }).toList();

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: a.bgSurface,
                borderRadius: AerosRadii.brMd,
                border: Border.all(color: a.borderDefault),
              ),
              clipBehavior: Clip.antiAlias,
              // LayoutBuilder so the inner DataTable can be forced to at
              // least the parent's width — Material's DataTable is
              // intrinsic-sized by default, which leaves a sea of empty
              // whitespace on the right when the table renders inside a
              // wide column (e.g. AerosDesktopWrap.full at 1400px). The
              // horizontal SingleChildScrollView still engages when
              // content needs more than parent width.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : 0,
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dataTableTheme: DataTableThemeData(
                            headingRowColor:
                                WidgetStateProperty.all(a.bgSubtle),
                            headingTextStyle: AerosTypography.bodySm(
                                    color: a.fgSecondary)
                                .copyWith(fontWeight: FontWeight.w600),
                            dataTextStyle: AerosTypography.bodyMd(
                                color: a.fgPrimary),
                            dividerThickness: 1,
                            headingRowHeight: 44,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            horizontalMargin: AerosSpacing.s4,
                            columnSpacing: AerosSpacing.s5,
                          ),
                        ),
                        child: DataTable(
                          columns: tableColumns,
                          rows: dataRows,
                          showCheckboxColumn: _hasSelection,
                          sortColumnIndex: sort?.columnIndex,
                          sortAscending: sort?.ascending ?? true,
                          onSelectAll: _hasSelection
                              ? (v) => _toggleAll(v ?? false)
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AerosSpacing.s3),
              footer!,
            ],
          ],
        ),
        if (loading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  bool _isSelected(T row) {
    final s = selected;
    if (s == null) return false;
    if (rowKey != null) {
      final k = rowKey!(row);
      return s.any((r) => rowKey!(r) == k);
    }
    return s.contains(row);
  }

  void _toggleRow(T row, bool isSelected) {
    if (selected == null || onSelectionChanged == null) return;
    final next = Set<T>.from(selected!);
    if (isSelected) {
      next.add(row);
    } else if (rowKey != null) {
      final k = rowKey!(row);
      next.removeWhere((r) => rowKey!(r) == k);
    } else {
      next.remove(row);
    }
    onSelectionChanged!(next);
  }

  void _toggleAll(bool selectAll) {
    if (onSelectionChanged == null) return;
    onSelectionChanged!(selectAll ? Set<T>.from(rows) : <T>{});
  }
}
