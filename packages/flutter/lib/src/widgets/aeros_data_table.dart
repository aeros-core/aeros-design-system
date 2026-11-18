import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_checkbox.dart';
import 'aeros_hoverable.dart';

/// One column in an [AerosDataTable].
class AerosDataColumn<T> {
  const AerosDataColumn({
    required this.label,
    required this.cell,
    this.width,
    this.sortable = false,
    this.numeric = false,
  });

  /// Column header text.
  final String label;

  /// Builds the cell widget for one row.
  final Widget Function(T row) cell;

  /// Optional fixed pixel width. If null, the column is as wide as its widest
  /// cell and takes a share of any room left over.
  final double? width;

  /// Makes the header a button that reports the next sort to
  /// [AerosDataTable.onSortChanged].
  final bool sortable;

  /// Right-aligns the column and sets its text in mono. Use for numbers /
  /// amounts.
  final bool numeric;
}

/// State of a sortable column.
class AerosDataSort {
  const AerosDataSort({required this.columnIndex, required this.ascending});
  final int columnIndex;
  final bool ascending;
}

/// A data table for list screens: a flat surface with a plain header row,
/// hairline-divided rows, optional row selection, sortable columns, a loading
/// veil and an empty state.
///
/// The header and the rows are [AerosSizeTokens.row] high for the density (a
/// row grows with a taller cell). Hovering a row tints it; a selected row
/// takes the selected tint. Columns are as wide as their content; when they
/// do not fit the table scrolls sideways. Given a bounded height (inside an
/// `Expanded`, say) the rows scroll under a header that stays in place.
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
class AerosDataTable<T> extends StatefulWidget {
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
    this.emptyText = 'No data',
    this.footer,
    this.onRowTap,
    this.rowKey,
    this.rowSemanticLabel,
  });

  final List<T> rows;
  final List<AerosDataColumn<T>> columns;

  /// Pass a non-null set to enable a checkbox column.
  /// `null` = no selection UI.
  final Set<T>? selected;
  final ValueChanged<Set<T>>? onSelectionChanged;

  final AerosDataSort? sort;
  final ValueChanged<AerosDataSort>? onSortChanged;

  /// Veils the table and shows a spinner.
  final bool loading;

  /// Shown under the header, centred, when [rows] is empty and [loading] is
  /// false. Defaults to [emptyText] as plain muted text. The table frame is
  /// already a surface — do not pass a card here.
  final Widget? emptyState;

  /// The default empty message.
  final String emptyText;

  /// Optional widget rendered below the table (e.g. [AerosPagination]).
  final Widget? footer;

  /// Optional row tap handler. With no [onRowTap] but a selection, tapping a
  /// row toggles it.
  final ValueChanged<T>? onRowTap;

  /// Required if [selected] is provided and `T` doesn't have stable equality
  /// across rebuilds — extracts a stable key for set membership.
  final dynamic Function(T row)? rowKey;

  /// What a screen reader calls a row (for its checkbox and, when the row can
  /// be tapped, for the row itself). Defaults to "Row 1", "Row 2", …
  final String Function(T row)? rowSemanticLabel;

  @override
  State<AerosDataTable<T>> createState() => _AerosDataTableState<T>();
}

class _AerosDataTableState<T> extends State<AerosDataTable<T>> {
  final ScrollController _vertical = ScrollController(debugLabel: 'AerosDataTable rows');
  final ScrollController _horizontal = ScrollController(debugLabel: 'AerosDataTable columns');

  static const EdgeInsets _cellPadding =
      EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s1_5);

  bool get _hasSelection => widget.selected != null;

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  bool _isSelected(T row) {
    final s = widget.selected;
    if (s == null) return false;
    final rowKey = widget.rowKey;
    if (rowKey != null) {
      final k = rowKey(row);
      return s.any((r) => rowKey(r) == k);
    }
    return s.contains(row);
  }

  void _toggleRow(T row, bool isSelected) {
    final selected = widget.selected;
    final onSelectionChanged = widget.onSelectionChanged;
    if (selected == null || onSelectionChanged == null) return;
    final rowKey = widget.rowKey;
    final next = Set<T>.from(selected);
    if (isSelected) {
      next.add(row);
    } else if (rowKey != null) {
      final k = rowKey(row);
      next.removeWhere((r) => rowKey(r) == k);
    } else {
      next.remove(row);
    }
    onSelectionChanged(next);
  }

  void _toggleAll(bool selectAll) {
    widget.onSelectionChanged?.call(selectAll ? Set<T>.from(widget.rows) : <T>{});
  }

  void _sortBy(int index) {
    final sort = widget.sort;
    final ascending = sort != null && sort.columnIndex == index ? !sort.ascending : true;
    widget.onSortChanged?.call(AerosDataSort(columnIndex: index, ascending: ascending));
  }

  String _rowLabel(int index) => widget.rowSemanticLabel?.call(widget.rows[index]) ?? 'Row ${index + 1}';

  Widget _headerCell(BuildContext context, int index) {
    final a = context.aerosColors;
    final column = widget.columns[index];
    final alignment = column.numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart;
    final sort = widget.sort;
    final sorted = sort != null && sort.columnIndex == index;

    if (!column.sortable || widget.onSortChanged == null) {
      return Semantics(
        header: true,
        child: Padding(
          padding: _cellPadding,
          child: Align(
            alignment: alignment,
            child: Text(column.label, maxLines: 1, style: AerosTypography.labelXs(color: a.fgMuted)),
          ),
        ),
      );
    }

    final state = !sorted
        ? 'not sorted'
        : sort.ascending
            ? 'sorted ascending'
            : 'sorted descending';
    return Semantics(
      header: true,
      child: AerosPressable(
        onPressed: () => _sortBy(index),
        // The header cell is the target; it keeps the size the table gives it.
        expandHitTarget: false,
        semanticLabel: '${column.label}, $state',
        excludeSemantics: true,
        builder: (context, interaction) {
          final color = sorted || interaction.hovered || interaction.pressed ? a.fgPrimary : a.fgMuted;
          return AerosFocusRing(
            focused: interaction.focused,
            placement: AerosFocusRingPlacement.inset,
            radius: const BorderRadius.all(Radius.circular(AerosShapeTokens.item)),
            child: Padding(
              padding: _cellPadding,
              child: Align(
                alignment: alignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(column.label, maxLines: 1, style: AerosTypography.labelXs(color: color)),
                    const SizedBox(width: AerosSpacing.s1),
                    Opacity(
                      opacity: sorted ? 1 : AerosMetricTokens.opacityMuted,
                      child: Icon(
                        !sorted
                            ? Icons.unfold_more
                            : sort.ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                        size: AerosSizeTokens.iconXs,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectionCell({required bool? value, required ValueChanged<bool?> onChanged, required String label}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AerosSpacing.s3),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: AerosCheckbox(
          value: value,
          tristate: value == null,
          onChanged: widget.onSelectionChanged == null ? null : onChanged,
          semanticLabel: label,
        ),
      ),
    );
  }

  Widget _rowBackground(BuildContext context, int index, {required bool selected, required bool last}) {
    final a = context.aerosColors;
    final row = widget.rows[index];
    final onRowTap = widget.onRowTap;
    final VoidCallback? onPressed = onRowTap != null
        ? () => onRowTap(row)
        : _hasSelection && widget.onSelectionChanged != null
            ? () => _toggleRow(row, !selected)
            : null;

    Widget fill({bool hovered = false, bool pressed = false}) => AnimatedContainer(
          duration: AerosStateLayer.duration(context),
          curve: AerosStateLayer.curve,
          decoration: BoxDecoration(
            color: AerosStateLayer.resolve(a, a.bgSurface, hovered: hovered, pressed: pressed, selected: selected),
            border: last
                ? null
                : Border(bottom: BorderSide(color: a.borderSubtle, width: AerosMetricTokens.borderHairline)),
          ),
        );

    if (onPressed == null) return AerosHoverable(builder: (context, hovered) => fill(hovered: hovered));
    return AerosPressable(
      onPressed: onPressed,
      // A row keeps the size the table gives it.
      expandHitTarget: false,
      selected: _hasSelection ? selected : null,
      semanticLabel: _rowLabel(index),
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        placement: AerosFocusRingPlacement.inset,
        radius: BorderRadius.zero,
        child: fill(hovered: state.hovered, pressed: state.pressed),
      ),
    );
  }

  Widget _cell(BuildContext context, AerosDataColumn<T> column, T row) {
    final a = context.aerosColors;
    return Padding(
      padding: _cellPadding,
      child: Align(
        alignment: column.numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: DefaultTextStyle.merge(
          style: column.numeric
              ? AerosTypography.monoMd(color: a.fgPrimary)
              : AerosTypography.bodySm(color: a.fgPrimary),
          child: IconTheme.merge(
            data: IconThemeData(color: a.fgMuted, size: AerosSizeTokens.iconMd),
            child: column.cell(row),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rows = widget.rows;
    final columns = widget.columns;
    final rowHeight = AerosDensity.of(context).sizes.row;
    final empty = rows.isEmpty;

    final selectedFlags = <bool>[for (final row in rows) _isSelected(row)];
    final selectedCount = selectedFlags.where((s) => s).length;
    final bool? allSelected = selectedCount == 0
        ? false
        : selectedCount == rows.length
            ? true
            : null;

    final specs = <_GridColumn>[
      if (_hasSelection) const _GridColumn(flex: false),
      for (final column in columns) _GridColumn(fixedWidth: column.width),
    ];

    final cells = <Widget>[
      // Header row. Its fill hides the rows that scroll under it.
      Container(
        decoration: BoxDecoration(
          color: a.bgSurface,
          border: Border(bottom: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline)),
        ),
      ),
      if (_hasSelection)
        _selectionCell(
          value: allSelected,
          label: 'Select all rows',
          // Mixed or none → all; all → none.
          onChanged: (_) => _toggleAll(allSelected != true),
        ),
      for (var i = 0; i < columns.length; i++) _headerCell(context, i),
      for (var r = 0; r < rows.length; r++) ...[
        _rowBackground(context, r, selected: selectedFlags[r], last: r == rows.length - 1),
        if (_hasSelection)
          _selectionCell(
            value: selectedFlags[r],
            label: 'Select ${_rowLabel(r)}',
            onChanged: (v) => _toggleRow(rows[r], v ?? false),
          ),
        for (final column in columns) _cell(context, column, rows[r]),
      ],
    ];

    final grid = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          // At least as wide as the frame; wider when the columns need it.
          constraints: BoxConstraints(minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0),
          child: SingleChildScrollView(
            controller: _vertical,
            child: _TableGrid(
              columns: specs,
              rowHeight: rowHeight,
              scroll: _vertical,
              textDirection: Directionality.of(context),
              children: cells,
            ),
          ),
        ),
      ),
    );

    Widget? below;
    if (empty && !widget.loading) {
      below = Padding(
        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s10),
        child: Center(
          child: widget.emptyState ??
              Text(
                widget.emptyText,
                textAlign: TextAlign.center,
                style: AerosTypography.bodySm(color: a.fgMuted),
              ),
        ),
      );
    } else if (empty) {
      // Room for the spinner while the first page loads.
      below = const SizedBox(height: AerosSpacing.s24);
    }

    final frame = AerosSurface(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: grid),
              if (below != null) below,
            ],
          ),
          if (widget.loading)
            Positioned.fill(
              child: Semantics(
                label: 'Loading',
                liveRegion: true,
                child: AbsorbPointer(
                  child: ColoredBox(
                    // The veil is the surface's own colour, so it reads the
                    // same in both themes.
                    color: a.bgSurface.withValues(alpha: AerosMetricTokens.opacityMuted),
                    child: Center(
                      child: SizedBox.square(
                        dimension: AerosSizeTokens.iconLg,
                        child: CircularProgressIndicator(
                          strokeWidth: AerosMetricTokens.borderThick,
                          color: a.fgPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: frame),
        if (widget.footer != null) ...[
          const SizedBox(height: AerosSpacing.s3),
          widget.footer!,
        ],
      ],
    );
  }
}

/// How one column of the grid is sized.
@immutable
class _GridColumn {
  const _GridColumn({this.fixedWidth, this.flex = true});

  /// Null sizes the column to its widest cell.
  final double? fixedWidth;

  /// Takes a share of the width left over when the table is wider than its
  /// columns. Fixed columns never do.
  final bool flex;

  @override
  bool operator ==(Object other) => other is _GridColumn && other.fixedWidth == fixedWidth && other.flex == flex;

  @override
  int get hashCode => Object.hash(fixedWidth, flex);
}

/// Lays the table out as a grid and keeps the header row in place while the
/// rows scroll.
///
/// Children come row by row, the header first: one background that spans the
/// row, then one cell per column.
class _TableGrid extends MultiChildRenderObjectWidget {
  const _TableGrid({
    required this.columns,
    required this.rowHeight,
    required this.scroll,
    required this.textDirection,
    required super.children,
  });

  final List<_GridColumn> columns;
  final double rowHeight;

  /// The vertical scroll position the header is pinned against.
  final ScrollController scroll;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTableGrid(
        columns: columns,
        rowHeight: rowHeight,
        scroll: scroll,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderTableGrid)
      ..columns = columns
      ..rowHeight = rowHeight
      ..scroll = scroll
      ..textDirection = textDirection;
  }
}

class _GridParentData extends ContainerBoxParentData<RenderBox> {
  bool header = false;
}

class _RenderTableGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridParentData> {
  _RenderTableGrid({
    required List<_GridColumn> columns,
    required double rowHeight,
    required ScrollController scroll,
    required TextDirection textDirection,
  })  : _columns = columns,
        _rowHeight = rowHeight,
        _scroll = scroll,
        _textDirection = textDirection;

  List<_GridColumn> _columns;
  set columns(List<_GridColumn> value) {
    if (listEquals(value, _columns)) return;
    _columns = value;
    markNeedsLayout();
  }

  double _rowHeight;
  set rowHeight(double value) {
    if (value == _rowHeight) return;
    _rowHeight = value;
    markNeedsLayout();
  }

  ScrollController _scroll;
  set scroll(ScrollController value) {
    if (value == _scroll) return;
    if (attached) _scroll.removeListener(_onScroll);
    _scroll = value;
    if (attached) _scroll.addListener(_onScroll);
    markNeedsPaint();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// Children per row: the background and one cell per column.
  int get _stride => _columns.length + 1;

  /// Top edge of each row, and the bottom of the last.
  List<double> _rowTops = const <double>[0];
  List<RenderBox> _children = const <RenderBox>[];

  double get _headerHeight => _rowTops.length > 1 ? _rowTops[1] : 0;

  /// How far the header is pushed down to stay at the top of the viewport.
  double get _pin {
    if (!_scroll.hasClients) return 0;
    final offset = _scroll.positions.first.pixels;
    return offset.clamp(0.0, math.max(0.0, size.height - _headerHeight));
  }

  void _onScroll() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scroll.addListener(_onScroll);
  }

  @override
  void detach() {
    _scroll.removeListener(_onScroll);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridParentData) child.parentData = _GridParentData();
  }

  /// Column widths from the cells' natural widths, with any room left over
  /// (up to [target]) shared between the flexible columns.
  List<double> _widths(List<RenderBox> children, double target) {
    final stride = _stride;
    final rows = children.length ~/ stride;
    final widths = List<double>.filled(_columns.length, 0);
    for (var c = 0; c < _columns.length; c++) {
      final fixed = _columns[c].fixedWidth;
      if (fixed != null) {
        widths[c] = fixed;
        continue;
      }
      for (var r = 0; r < rows; r++) {
        widths[c] = math.max(widths[c], children[r * stride + 1 + c].getMaxIntrinsicWidth(double.infinity));
      }
      widths[c] = widths[c].ceilToDouble();
    }
    final total = widths.fold<double>(0, (sum, w) => sum + w);
    final flexible = <int>[
      for (var c = 0; c < _columns.length; c++)
        if (_columns[c].flex && _columns[c].fixedWidth == null) c,
    ];
    if (total < target && flexible.isNotEmpty) {
      final share = (target - total) / flexible.length;
      for (final c in flexible) {
        widths[c] += share;
      }
    }
    return widths;
  }

  double _target(BoxConstraints constraints) =>
      constraints.hasBoundedWidth ? constraints.maxWidth : constraints.minWidth;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _widths(getChildrenAsList(), 0).fold<double>(0, (sum, w) => sum + w);

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => (childCount ~/ _stride) * _rowHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    final children = _children = getChildrenAsList();
    final stride = _stride;
    final rows = children.length ~/ stride;
    final widths = _widths(children, _target(constraints));
    final total = math.max(widths.fold<double>(0, (sum, w) => sum + w), constraints.minWidth);
    final rtl = _textDirection == TextDirection.rtl;

    final tops = <double>[0];
    var y = 0.0;
    for (var r = 0; r < rows; r++) {
      final base = r * stride;
      var height = _rowHeight;
      for (var c = 0; c < _columns.length; c++) {
        final cell = children[base + 1 + c];
        cell.layout(
          BoxConstraints(minWidth: widths[c], maxWidth: widths[c], minHeight: _rowHeight),
          parentUsesSize: true,
        );
        height = math.max(height, cell.size.height);
      }
      var x = 0.0;
      for (var c = 0; c < _columns.length; c++) {
        final cell = children[base + 1 + c];
        final data = cell.parentData! as _GridParentData
          ..header = r == 0
          ..offset = Offset(rtl ? total - x - widths[c] : x, y + (height - cell.size.height) / 2);
        assert(data.offset.dy >= y);
        x += widths[c];
      }
      final background = children[base];
      background.layout(BoxConstraints.tightFor(width: total, height: height));
      (background.parentData! as _GridParentData)
        ..header = r == 0
        ..offset = Offset(0, y);
      y += height;
      tops.add(y);
    }
    _rowTops = tops;
    size = constraints.constrain(Size(total, y));
  }

  Offset _offsetOf(RenderBox child) {
    final data = child.parentData! as _GridParentData;
    return data.header ? data.offset + Offset(0, _pin) : data.offset;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = _offsetOf(child);
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final stride = _stride;
    // The header is painted last, over the rows that have scrolled under it.
    for (var i = stride; i < _children.length; i++) {
      context.paintChild(_children[i], _offsetOf(_children[i]) + offset);
    }
    for (var i = 0; i < stride && i < _children.length; i++) {
      context.paintChild(_children[i], _offsetOf(_children[i]) + offset);
    }
  }

  bool _hitRow(BoxHitTestResult result, Offset position, int row) {
    final base = row * _stride;
    bool hitChild(RenderBox child) => result.addWithPaintOffset(
          offset: _offsetOf(child),
          position: position,
          hitTest: (result, transformed) => child.hitTest(result, position: transformed),
        );
    var hit = false;
    for (var c = _columns.length; c >= 1; c--) {
      if (hitChild(_children[base + c])) {
        hit = true;
        break;
      }
    }
    // The background is tested as well, so a row stays hovered (and can be
    // tapped) while the pointer is over one of its cells.
    return hitChild(_children[base]) || hit;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final rows = _children.length ~/ _stride;
    if (rows == 0) return false;
    final pin = _pin;
    if (position.dy >= pin && position.dy < pin + _headerHeight) return _hitRow(result, position, 0);
    for (var r = 1; r < rows; r++) {
      if (position.dy >= _rowTops[r] && position.dy < _rowTops[r + 1]) return _hitRow(result, position, r);
    }
    return false;
  }
}
