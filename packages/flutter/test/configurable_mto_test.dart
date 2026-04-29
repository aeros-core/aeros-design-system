import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AerosTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );

void main() {
  group('AerosAttributeSelector routing', () {
    testWidgets('ENUM ≤ chipThreshold renders chips', (t) async {
      AerosAttributeValue value = const AerosAttributeValue();
      await t.pumpWidget(_wrap(StatefulBuilder(
        builder: (ctx, set) => AerosAttributeSelector(
          spec: const AerosAttributeSpec(
            key: 'cup_size',
            label: 'Cup size',
            datatype: AerosAttributeDatatype.enumValue,
            optionSource: AerosAttributeOptionSource.enumOptions,
            options: [
              AerosAttributeOption(id: 'a', label: 'A'),
              AerosAttributeOption(id: 'b', label: 'B'),
              AerosAttributeOption(id: 'c', label: 'C'),
            ],
          ),
          value: value,
          onChanged: (v) => set(() => value = v),
        ),
      )));
      await t.pump();
      expect(find.byType(AerosEnumChips), findsOneWidget);
      expect(find.byType(AerosEnumDropdown), findsNothing);

      await t.tap(find.text('B'));
      await t.pumpAndSettle();
      expect(value.enumValueId, 'b');
    });

    testWidgets('ENUM > chipThreshold renders dropdown', (t) async {
      await t.pumpWidget(_wrap(AerosAttributeSelector(
        spec: AerosAttributeSpec(
          key: 'colour',
          label: 'Colour',
          datatype: AerosAttributeDatatype.enumValue,
          optionSource: AerosAttributeOptionSource.enumOptions,
          options: List.generate(
            10,
            (i) => AerosAttributeOption(id: 'c$i', label: 'Colour $i'),
          ),
        ),
        value: const AerosAttributeValue(),
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.byType(AerosEnumDropdown), findsOneWidget);
    });

    testWidgets('MEASUREMENT + range renders slider', (t) async {
      await t.pumpWidget(_wrap(AerosAttributeSelector(
        spec: const AerosAttributeSpec(
          key: 'gsm',
          label: 'Paper weight',
          datatype: AerosAttributeDatatype.measurement,
          optionSource: AerosAttributeOptionSource.range,
          range: AerosNumericRange(min: 100, max: 300, step: 10),
          defaultUnit: 'gsm',
        ),
        value: const AerosAttributeValue(numericValue: 200),
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.byType(AerosRangeSlider), findsOneWidget);
      expect(find.text('200 gsm'), findsOneWidget);
    });

    testWidgets('BOOLEAN renders switch row', (t) async {
      bool? captured;
      await t.pumpWidget(_wrap(AerosAttributeSelector(
        spec: const AerosAttributeSpec(
          key: 'printed',
          label: 'Print logo',
          datatype: AerosAttributeDatatype.boolean,
          optionSource: AerosAttributeOptionSource.enumOptions,
        ),
        value: const AerosAttributeValue(boolValue: false),
        onChanged: (v) => captured = v.boolValue,
      )));
      await t.pump();
      expect(find.byType(AerosSwitch), findsOneWidget);
      await t.tap(find.byType(AerosSwitch));
      await t.pumpAndSettle();
      expect(captured, isTrue);
    });

    testWidgets('FILE option-source renders upload button', (t) async {
      await t.pumpWidget(_wrap(AerosAttributeSelector(
        spec: const AerosAttributeSpec(
          key: 'artwork',
          label: 'Upload artwork',
          datatype: AerosAttributeDatatype.enumValue,
          optionSource: AerosAttributeOptionSource.file,
        ),
        value: const AerosAttributeValue(),
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.byType(AerosFileUploadButton), findsOneWidget);
    });

    testWidgets('lockedByAdmin disables the input', (t) async {
      bool changed = false;
      await t.pumpWidget(_wrap(AerosAttributeSelector(
        spec: const AerosAttributeSpec(
          key: 'cup_size',
          label: 'Cup size',
          datatype: AerosAttributeDatatype.enumValue,
          optionSource: AerosAttributeOptionSource.enumOptions,
          lockedByAdmin: true,
          options: [
            AerosAttributeOption(id: 'a', label: 'A'),
            AerosAttributeOption(id: 'b', label: 'B'),
          ],
        ),
        value: const AerosAttributeValue(enumValueId: 'a'),
        onChanged: (_) => changed = true,
      )));
      await t.pump();
      await t.tap(find.text('B'));
      await t.pumpAndSettle();
      expect(changed, isFalse);
      expect(find.text('Locked by seller'), findsOneWidget);
    });
  });

  group('AerosVariantPicker', () {
    testWidgets('out-of-stock variant cannot be selected', (t) async {
      String? selected = 'a';
      await t.pumpWidget(_wrap(StatefulBuilder(
        builder: (ctx, set) => AerosVariantPicker(
          variants: const [
            AerosVariantOption(id: 'a', label: 'A', stockQty: 100),
            AerosVariantOption(id: 'b', label: 'B', stockQty: 0),
          ],
          selectedVariantId: selected,
          onChanged: (id) => set(() => selected = id),
        ),
      )));
      await t.pump();
      expect(find.text('Out of stock'), findsOneWidget);
      await t.tap(find.text('B'));
      await t.pumpAndSettle();
      expect(selected, 'a');
    });

    testWidgets('low-stock variant shows X-left badge', (t) async {
      await t.pumpWidget(_wrap(AerosVariantPicker(
        variants: const [
          AerosVariantOption(id: 'a', label: 'A', stockQty: 3),
        ],
        selectedVariantId: null,
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.text('3 left'), findsOneWidget);
    });
  });

  group('AerosPriceBreakdown', () {
    testWidgets('renders steps and subtotal split', (t) async {
      await t.pumpWidget(_wrap(const AerosPriceBreakdown(
        initiallyExpanded: true,
        data: AerosPriceBreakdownData(
          currencySymbol: '₹',
          discountableSubtotal: 100,
          nonDiscountableSubtotal: 50,
          total: 150,
          steps: [
            AerosBreakdownStep(name: 'Base', amount: 100),
            AerosBreakdownStep(
              name: 'Setup fee',
              amount: 50,
              discountable: false,
            ),
          ],
        ),
      )));
      await t.pump();
      expect(find.text('Discountable subtotal'), findsOneWidget);
      expect(find.text('Fixed (setup / shipping)'), findsOneWidget);
      // Total appears twice: header + footer total row.
      expect(find.text('₹150.00'), findsNWidgets(2));
    });

    testWidgets('expand / collapse toggles details', (t) async {
      await t.pumpWidget(_wrap(const AerosPriceBreakdown(
        data: AerosPriceBreakdownData(
          currencySymbol: '₹',
          discountableSubtotal: 100,
          nonDiscountableSubtotal: 0,
          total: 100,
          steps: [AerosBreakdownStep(name: 'Base', amount: 100)],
        ),
      )));
      await t.pump();
      expect(find.text('Discountable subtotal'), findsNothing);
      await t.tap(find.text('Price breakdown'));
      await t.pumpAndSettle();
      expect(find.text('Discountable subtotal'), findsOneWidget);
    });
  });

  group('AerosRoutingSignalBadge', () {
    testWidgets('renders label with severity colour', (t) async {
      await t.pumpWidget(_wrap(const AerosRoutingSignalBadge(
        signal: AerosRoutingSignal(
          kind: 'requires_rfq',
          label: 'Send as RFQ',
          severity: AerosRoutingSeverity.warn,
        ),
      )));
      await t.pump();
      expect(find.text('Send as RFQ'), findsOneWidget);
    });
  });

  group('AerosConstraintErrorAlert', () {
    testWidgets('picks message for the active locale', (t) async {
      await t.pumpWidget(_wrap(const AerosConstraintErrorAlert(
        messageByLocale: {
          'en': 'English message',
          'hi': 'Hindi message',
        },
        locale: 'hi',
      )));
      await t.pump();
      expect(find.text('Hindi message'), findsOneWidget);
      expect(find.text('English message'), findsNothing);
    });

    testWidgets('falls back to English when locale missing', (t) async {
      await t.pumpWidget(_wrap(const AerosConstraintErrorAlert(
        messageByLocale: {'en': 'English message'},
        locale: 'fr',
      )));
      await t.pump();
      expect(find.text('English message'), findsOneWidget);
    });
  });

  group('Token helpers', () {
    test('AerosSelectionPalette resolves all states', () {
      for (final state in AerosSelectionState.values) {
        final p = AerosSelectionPalette.resolve(state, AerosAliasColors.light);
        expect(p.background, isNotNull);
        expect(p.foreground, isNotNull);
        expect(p.border, isNotNull);
      }
    });

    test('AerosSeverityPalette returns icon for each severity', () {
      for (final s in AerosSeverity.values) {
        expect(AerosSeverityPalette.of(s).icon, isNotNull);
      }
    });

    test('AerosPricePalette flags non-discountable lines with label', () {
      final p = AerosPricePalette.resolve(
        AerosPriceTone.nonDiscountable,
        AerosAliasColors.light,
      );
      expect(p.label, 'fixed');
    });
  });
}
