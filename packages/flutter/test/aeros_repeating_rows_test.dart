import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AerosTheme.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AerosRepeatingRows', () {
    testWidgets('renders one row per item via itemBuilder', (t) async {
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1, 2, 3],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          addLabel: 'Add row',
        ),
      ));
      expect(find.text('row-1'), findsOneWidget);
      expect(find.text('row-2'), findsOneWidget);
      expect(find.text('row-3'), findsOneWidget);
    });

    testWidgets('Add button visible when below maxItems and hidden at cap',
        (t) async {
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1, 2],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          addLabel: 'Add another',
          maxItems: 3,
        ),
      ));
      expect(find.text('Add another'), findsOneWidget);

      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1, 2, 3],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          addLabel: 'Add another',
          maxItems: 3,
        ),
      ));
      expect(find.text('Add another'), findsNothing);
    });

    testWidgets('remove button hidden at minItems, visible above', (t) async {
      // Single item, minItems=1 → no remove buttons.
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          onRemove: (_) {},
          addLabel: 'Add row',
        ),
      ));
      expect(find.byIcon(Icons.close), findsNothing);

      // Two items → two remove buttons.
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1, 2],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          onRemove: (_) {},
          addLabel: 'Add row',
        ),
      ));
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('onRemove fires with the right index', (t) async {
      int? removedIndex;
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<String>(
          items: const ['a', 'b', 'c'],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () {},
          onRemove: (i) => removedIndex = i,
          addLabel: 'Add row',
        ),
      ));
      // Tap the second remove button.
      await t.tap(find.byIcon(Icons.close).at(1));
      await t.pump();
      expect(removedIndex, 1);
    });

    testWidgets('onAdd fires when Add button tapped', (t) async {
      int adds = 0;
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1],
          itemBuilder: (ctx, i, item) => Text('row-$item'),
          onAdd: () => adds++,
          addLabel: 'Add row',
        ),
      ));
      await t.tap(find.text('Add row'));
      await t.pump();
      expect(adds, 1);
    });

    testWidgets('renders label / required marker / errorText via AerosFormField',
        (t) async {
      await t.pumpWidget(_wrap(
        AerosRepeatingRows<int>(
          items: const [1],
          itemBuilder: (ctx, i, item) => const SizedBox.shrink(),
          onAdd: () {},
          addLabel: 'Add row',
          label: 'Boxes',
          required: true,
          errorText: 'At least one box is required',
        ),
      ));
      // AerosFormField renders the label inside a RichText with the
      // `required *` inlined as a child TextSpan, so the plain text is
      // "Boxes *", not "Boxes". Match by substring.
      expect(find.textContaining('Boxes', findRichText: true), findsOneWidget);
      expect(find.text('At least one box is required'), findsOneWidget);
    });
  });
}
