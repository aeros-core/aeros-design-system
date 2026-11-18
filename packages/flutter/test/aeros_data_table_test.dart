import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Order {
  const _Order(this.id, this.buyer, this.total);

  final String id;
  final String buyer;
  final double total;
}

final _orders = [for (var i = 1; i <= 4; i++) _Order('SO-$i', 'Buyer $i', i * 1200.5)];

List<AerosDataColumn<_Order>> _columns({bool sortable = false}) => [
      AerosDataColumn(label: 'Order', sortable: sortable, cell: (o) => Text(o.id)),
      AerosDataColumn(label: 'Buyer', cell: (o) => Text(o.buyer)),
      AerosDataColumn(label: 'Total', numeric: true, sortable: sortable, cell: (o) => Text(o.total.toStringAsFixed(2))),
    ];

Widget _app(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  AerosDensity? density,
}) {
  Widget body = Padding(padding: const EdgeInsets.all(16), child: child);
  if (density != null) body = AerosDensityScope(density: density, child: body);
  return MaterialApp(
    theme: AerosTheme.light(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: Align(alignment: Alignment.topCenter, child: body)),
    ),
  );
}

void main() {
  testWidgets('is one flat surface with no Material DataTable underneath', (tester) async {
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: _orders, columns: _columns())));
    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(AerosSurface), findsOneWidget);
    expect(tester.widget<AerosSurface>(find.byType(AerosSurface)).level, AerosSurfaceLevel.flat);
    expect(find.byType(InkWell), findsNothing);
    for (final order in _orders) {
      expect(find.text(order.id), findsOneWidget);
    }
  });

  testWidgets('header and rows are the row token high for the density', (tester) async {
    for (final density in AerosDensity.values) {
      await tester.pumpWidget(
        _app(density: density, AerosDataTable<_Order>(rows: _orders, columns: _columns())),
      );
      final row = density.sizes.row;
      final header = tester.getRect(find.text('Order'));
      final first = tester.getRect(find.text('SO-1'));
      final second = tester.getRect(find.text('SO-2'));
      expect(first.center.dy - header.center.dy, row, reason: '$density');
      expect(second.center.dy - first.center.dy, row, reason: '$density');
      // Header + four rows + the frame's two hairlines.
      expect(
        tester.getSize(find.byType(AerosSurface)).height,
        5 * row + 2 * AerosMetricTokens.borderHairline,
        reason: '$density',
      );
    }
  });

  testWidgets('header labels are muted labelXs; numeric columns are right-aligned mono', (tester) async {
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: _orders, columns: _columns())));
    final label = tester.widget<Text>(find.text('Order')).style!;
    expect(label.fontSize, AerosTypography.labelXs().fontSize);
    expect(label.color, AerosAliasColors.light.fgMuted);

    final amount = tester.renderObject<RenderParagraph>(find.text('1200.50')).text.style!;
    expect(amount.fontFamily, contains('IBM Plex Mono'));
    // The header and its cells share a right edge.
    expect(tester.getRect(find.text('Total')).right, tester.getRect(find.text('1200.50')).right);
    expect(tester.getRect(find.text('Order')).left, tester.getRect(find.text('SO-1')).left);
  });

  testWidgets('a sortable header reports the next sort and announces the current one', (tester) async {
    final handle = tester.ensureSemantics();
    AerosDataSort? sort;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => AerosDataTable<_Order>(
            rows: _orders,
            columns: _columns(sortable: true),
            sort: sort,
            onSortChanged: (s) => setState(() => sort = s),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Order, not sorted'), findsOneWidget);
    expect(find.bySemanticsLabel('Total, not sorted'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Order, not sorted')).flagsCollection.isButton,
      isTrue,
    );

    await tester.tap(find.text('Order'));
    await tester.pumpAndSettle();
    expect(sort!.columnIndex, 0);
    expect(sort!.ascending, isTrue);
    expect(find.bySemanticsLabel('Order, sorted ascending'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    await tester.tap(find.text('Order'));
    await tester.pumpAndSettle();
    expect(sort!.ascending, isFalse);
    expect(find.bySemanticsLabel('Order, sorted descending'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

    // Another column starts ascending again; the column index counts data
    // columns, not the checkbox column.
    await tester.tap(find.text('Total'));
    await tester.pumpAndSettle();
    expect(sort!.columnIndex, 2);
    expect(sort!.ascending, isTrue);
    expect(find.bySemanticsLabel('Order, not sorted'), findsOneWidget);

    // The header answers the keyboard too.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(sort!.columnIndex, 0);
    handle.dispose();
  });

  testWidgets('header cells are marked as headers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: _orders, columns: _columns())));
    for (final label in ['Order', 'Buyer', 'Total']) {
      expect(tester.getSemantics(find.text(label)).flagsCollection.isHeader, isTrue, reason: label);
    }
    expect(tester.getSemantics(find.text('SO-1')).flagsCollection.isHeader, isFalse);
    handle.dispose();
  });

  testWidgets('select one, the mixed header, select all, clear', (tester) async {
    final handle = tester.ensureSemantics();
    var selected = <_Order>{};
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => AerosDataTable<_Order>(
            rows: _orders,
            columns: _columns(),
            selected: selected,
            onSelectionChanged: (s) => setState(() => selected = s),
          ),
        ),
      ),
    );
    AerosCheckbox header() => tester.widget<AerosCheckbox>(find.byType(AerosCheckbox).first);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(AerosCheckbox), findsNWidgets(_orders.length + 1));
    expect(header().value, isFalse);

    await tester.tap(find.bySemanticsLabel('Select Row 2'));
    await tester.pumpAndSettle();
    expect(selected, {_orders[1]});
    // Some but not all: the header is mixed, and says so.
    expect(header().value, isNull);
    final mixed = tester.getSemantics(find.bySemanticsLabel('Select all rows'));
    expect(mixed.flagsCollection.isChecked.name, 'mixed');
    // The row's selection is announced by its checkbox.
    expect(tester.getSemantics(find.bySemanticsLabel('Select Row 2')).flagsCollection.isChecked.name, 'isTrue');
    expect(tester.getSemantics(find.bySemanticsLabel('Select Row 1')).flagsCollection.isChecked.name, 'isFalse');

    await tester.tap(find.bySemanticsLabel('Select all rows'));
    await tester.pumpAndSettle();
    expect(selected, _orders.toSet());
    expect(header().value, isTrue);

    await tester.tap(find.bySemanticsLabel('Select all rows'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(header().value, isFalse);

    // With no onRowTap, a tap anywhere on a row toggles it — and the row
    // itself is announced as selected.
    await tester.tap(find.text('Buyer 3'));
    await tester.pumpAndSettle();
    expect(selected, {_orders[2]});
    expect(tester.getSemantics(find.bySemanticsLabel('Row 3')).flagsCollection.isSelected.name, 'isTrue');
    handle.dispose();
  });

  testWidgets('with a row tap and a selection, the checkbox selects and the row navigates', (tester) async {
    var selected = <_Order>{};
    final tapped = <_Order>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => AerosDataTable<_Order>(
            rows: _orders,
            columns: _columns(),
            selected: selected,
            onSelectionChanged: (s) => setState(() => selected = s),
            onRowTap: tapped.add,
            rowSemanticLabel: (o) => 'Order ${o.id}',
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Select Order SO-1'));
    await tester.pumpAndSettle();
    expect(selected, {_orders[0]});
    expect(tapped, isEmpty);

    await tester.tap(find.text('Buyer 2'));
    await tester.pumpAndSettle();
    expect(tapped, [_orders[1]]);
    expect(selected, {_orders[0]});
  });

  testWidgets('hover tints a row with the state layer; a selected row takes the selected tint', (tester) async {
    await tester.pumpWidget(
      _app(
        AerosDataTable<_Order>(
          rows: _orders,
          columns: _columns(),
          selected: {_orders[1]},
          onSelectionChanged: (_) {},
        ),
      ),
    );
    const a = AerosAliasColors.light;
    Color fillOfRow(String text) {
      final target = tester.getCenter(find.text(text));
      final fills = tester.widgetList<AnimatedContainer>(
        find.descendant(of: find.byType(AerosDataTable<_Order>), matching: find.byType(AnimatedContainer)),
      );
      final boxes = tester.renderObjectList<RenderBox>(
        find.descendant(of: find.byType(AerosDataTable<_Order>), matching: find.byType(AnimatedContainer)),
      );
      final list = fills.toList();
      var i = 0;
      for (final box in boxes) {
        final rect = box.localToGlobal(Offset.zero) & box.size;
        if (rect.contains(target) && rect.width > 300) return (list[i].decoration! as BoxDecoration).color!;
        i++;
      }
      throw StateError('no row fill behind "$text"');
    }

    expect(fillOfRow('SO-1'), a.bgSurface);
    expect(fillOfRow('SO-2'), Color.alphaBlend(a.stateSelected, a.bgSurface));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    // Over a cell's text, not just the gaps between cells.
    await gesture.moveTo(tester.getCenter(find.text('Buyer 1')));
    await tester.pumpAndSettle();
    expect(fillOfRow('SO-1'), Color.alphaBlend(a.stateHover, a.bgSurface));
    expect(fillOfRow('SO-3'), a.bgSurface);
  });

  testWidgets('the header stays put while the rows scroll under it', (tester) async {
    final many = [for (var i = 1; i <= 40; i++) _Order('SO-$i', 'Buyer $i', i * 10)];
    await tester.pumpWidget(
      _app(SizedBox(height: 300, child: AerosDataTable<_Order>(rows: many, columns: _columns()))),
    );
    expect(tester.takeException(), isNull);
    final frame = tester.getRect(find.byType(AerosSurface));
    expect(frame.height, lessThanOrEqualTo(300));

    final headerBefore = tester.getRect(find.text('Order'));
    final rowBefore = tester.getRect(find.text('SO-5'));
    await tester.drag(find.text('SO-5'), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.text('Order')), headerBefore);
    expect(tester.getRect(find.text('SO-5')).top, lessThan(rowBefore.top - 300));
    // The header still takes taps where it is drawn, not where it was laid out.
    final hit = tester.hitTestOnBinding(headerBefore.center);
    expect(hit.path.any((e) => e.target == tester.renderObject(find.text('Order'))), isTrue);
    // And the row now under the header's old position is not hit through it.
    expect(
      hit.path.any((e) => e.target is RenderParagraph && e.target != tester.renderObject(find.text('Order'))),
      isFalse,
    );
  });

  testWidgets('in an unbounded height the table is as tall as its rows', (tester) async {
    final many = [for (var i = 1; i <= 30; i++) _Order('SO-$i', 'Buyer $i', i * 10)];
    await tester.pumpWidget(
      _app(SingleChildScrollView(child: AerosDataTable<_Order>(rows: many, columns: _columns()))),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AerosSurface)).height,
      31 * AerosSizeTokens.touch.row + 2 * AerosMetricTokens.borderHairline,
    );
  });

  testWidgets('empty: plain centred text inside the one frame, under the header', (tester) async {
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: const [], columns: _columns())));
    expect(find.text('No data'), findsOneWidget);
    expect(find.byType(AerosEmptyState), findsNothing);
    expect(find.byType(AerosSurface), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);
    final frame = tester.getRect(find.byType(AerosSurface));
    final text = tester.getRect(find.text('No data'));
    expect(text.center.dx, moreOrLessEquals(frame.center.dx, epsilon: 0.5));
    expect(text.top, greaterThan(tester.getRect(find.text('Order')).bottom));

    await tester.pumpWidget(
      _app(AerosDataTable<_Order>(rows: const [], columns: _columns(), emptyText: 'No orders match')),
    );
    expect(find.text('No orders match'), findsOneWidget);

    await tester.pumpWidget(
      _app(AerosDataTable<_Order>(rows: const [], columns: _columns(), emptyState: const Text('Custom'))),
    );
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('No data'), findsNothing);
  });

  testWidgets('loading: a veil in the surface colour at the muted opacity, with a spinner', (tester) async {
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: _orders, columns: _columns(), loading: true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final veil = tester.widget<ColoredBox>(
      find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(ColoredBox)).first,
    );
    expect(veil.color, AerosAliasColors.light.bgSurface.withValues(alpha: AerosMetricTokens.opacityMuted));
    // The veil takes the taps.
    var tapped = false;
    await tester.pumpWidget(
      _app(
        AerosDataTable<_Order>(rows: _orders, columns: _columns(), loading: true, onRowTap: (_) => tapped = true),
      ),
    );
    await tester.tap(find.text('Buyer 1'), warnIfMissed: false);
    expect(tapped, isFalse);

    // Loading with no rows yet: no empty message, room for the spinner.
    await tester.pumpWidget(_app(AerosDataTable<_Order>(rows: const [], columns: _columns(), loading: true)));
    expect(find.text('No data'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('more columns than fit: it scrolls sideways instead of overflowing', (tester) async {
    final columns = [
      for (var c = 0; c < 20; c++) AerosDataColumn<_Order>(label: 'Column $c', cell: (o) => Text('${o.id} / $c')),
    ];
    await tester.pumpWidget(
      _app(SizedBox(width: 400, child: AerosDataTable<_Order>(rows: _orders, columns: columns))),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AerosSurface)).width, 400);

    final horizontal = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((s) => s.axisDirection == AxisDirection.right);
    expect(horizontal.position.maxScrollExtent, greaterThan(0));
    final before = tester.getRect(find.text('Column 0'));
    await tester.drag(find.text('SO-1 / 0'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Column 0')).left, lessThan(before.left));
    // The header moves sideways with its column.
    expect(tester.getRect(find.text('Column 0')).left, tester.getRect(find.text('SO-1 / 0')).left);
  });

  testWidgets('few columns fill the width; a fixed-width column keeps its width', (tester) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 600,
          child: AerosDataTable<_Order>(
            rows: _orders,
            columns: [
              AerosDataColumn(label: 'Order', width: 120, cell: (o) => Text(o.id)),
              AerosDataColumn(label: 'Buyer', cell: (o) => Text(o.buyer)),
              AerosDataColumn(label: 'Total', numeric: true, cell: (o) => Text('${o.total}')),
            ],
          ),
        ),
      ),
    );
    final horizontal = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((s) => s.axisDirection == AxisDirection.right);
    expect(horizontal.position.maxScrollExtent, 0);
    final frame = tester.getRect(find.byType(AerosSurface));
    // The second column starts where the fixed first one ends.
    expect(
      tester.getRect(find.text('Buyer')).left - tester.getRect(find.text('Order')).left,
      120,
    );
    // The last (numeric) column runs to the frame's right edge, less its padding.
    expect(
      tester.getRect(find.text('Total')).right,
      frame.right - AerosMetricTokens.borderHairline - AerosSpacing.s3,
    );
  });

  testWidgets('right-to-left: builds mirrored, with and without selection', (tester) async {
    await tester.pumpWidget(
      _app(
        direction: TextDirection.rtl,
        AerosDataTable<_Order>(
          rows: _orders,
          columns: _columns(sortable: true),
          selected: {_orders.first},
          onSelectionChanged: (_) {},
          sort: const AerosDataSort(columnIndex: 0, ascending: true),
          onSortChanged: (_) {},
          footer: const Text('Footer'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    // The first column is on the right, the numeric one on the left.
    expect(tester.getRect(find.text('Order')).left, greaterThan(tester.getRect(find.text('Total')).right));
    expect(tester.getRect(find.byType(AerosCheckbox).first).left, greaterThan(tester.getRect(find.text('Order')).right));

    for (final table in [
      AerosDataTable<_Order>(rows: const [], columns: _columns()),
      AerosDataTable<_Order>(rows: _orders, columns: _columns(), loading: true),
    ]) {
      await tester.pumpWidget(_app(direction: TextDirection.rtl, table));
      expect(tester.takeException(), isNull);
    }
  });
}
