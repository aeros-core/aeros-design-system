import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('AerosMeasurementInput', () {
    const units = [
      AerosMeasurementUnit(code: 'mm', label: 'mm'),
      AerosMeasurementUnit(code: 'cm', label: 'cm'),
    ];

    testWidgets('renders exactly one field border', (t) async {
      await t.pumpWidget(_wrap(AerosMeasurementInput(
        label: 'Width',
        units: units,
        numericValue: 120,
        unitCode: 'mm',
        onChanged: (_, __) {},
      )));
      // One frame draws the hairline …
      expect(find.byType(AerosFieldFrame), findsOneWidget);
      // … and the text input inside it draws none of its own.
      final decoration = t.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
      expect(decoration.filled, isFalse);
      for (final border in [
        decoration.border,
        decoration.enabledBorder,
        decoration.focusedBorder,
        decoration.disabledBorder,
        decoration.errorBorder,
        decoration.focusedErrorBorder,
      ]) {
        expect(border, InputBorder.none);
      }
      // Nothing else inside the input paints a box border.
      final bordered = t
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(AerosMeasurementInput), matching: find.byType(DecoratedBox)),
          )
          .where((box) => (box.decoration as BoxDecoration).border != null);
      expect(bordered, hasLength(1));
      expect(find.byType(DropdownButton<String>), findsNothing);
    });

    testWidgets('a disabled input is visibly disabled and takes no input', (t) async {
      await t.pumpWidget(_wrap(AerosMeasurementInput(
        label: 'Width',
        units: units,
        numericValue: 120,
        unitCode: 'mm',
        enabled: false,
        onChanged: (_, __) {},
      )));
      expect(t.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).enabled, isFalse);
      final dim = t.widget<Opacity>(
        find.ancestor(of: find.byType(EditableText), matching: find.byType(Opacity)).first,
      );
      expect(dim.opacity, AerosMetricTokens.opacityDisabled);
      expect(t.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      await t.tap(find.text('mm'), warnIfMissed: false);
      await t.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsNothing);
    });

    testWidgets('the unit opens a list and reports the choice with the number', (t) async {
      num? value;
      String? unit;
      await t.pumpWidget(_wrap(AerosMeasurementInput(
        label: 'Width',
        units: units,
        numericValue: 120,
        unitCode: 'mm',
        onChanged: (v, u) {
          value = v;
          unit = u;
        },
      )));
      await t.tap(find.text('mm'));
      await t.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsOneWidget);
      await t.tap(find.widgetWithText(AerosMenuRow, 'cm'));
      await t.pumpAndSettle();
      expect(unit, 'cm');
      expect(value, 120);

      await t.enterText(find.byType(EditableText), '42.5');
      expect(value, 42.5);
    });

    testWidgets('an error turns the one frame to the error state', (t) async {
      await t.pumpWidget(_wrap(AerosMeasurementInput(
        units: units,
        numericValue: 5,
        unitCode: 'mm',
        range: const AerosNumericRange(min: 10, max: 300),
        errorText: 'Too small',
        onChanged: (_, __) {},
      )));
      expect(t.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isTrue);
      expect(find.text('Too small'), findsOneWidget);
      expect(find.textContaining('Allowed'), findsNothing);
    });
  });

  group('mono amounts', () {
    Iterable<TextStyle> monoStyles(WidgetTester t) => t
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.style)
        .whereType<TextStyle>()
        .where((style) => (style.fontFamily ?? '').contains('IBM Plex Mono'));

    testWidgets('the price breakdown asks for no mono weight above 500', (t) async {
      await t.pumpWidget(_wrap(const AerosPriceBreakdown(
        initiallyExpanded: true,
        data: AerosPriceBreakdownData(
          currencySymbol: '₹',
          discountableSubtotal: 100,
          nonDiscountableSubtotal: 50,
          total: 140,
          steps: [
            AerosBreakdownStep(name: 'Base', amount: 100, perUnit: true),
            AerosBreakdownStep(name: 'Setup fee', amount: 50, discountable: false, note: 'One time'),
            AerosBreakdownStep(name: 'Bulk discount', amount: -10),
          ],
        ),
      )));
      final styles = monoStyles(t).toList();
      // Three steps, two subtotals, the total twice.
      expect(styles, hasLength(7));
      for (final style in styles) {
        expect(style.fontWeight!.value, lessThanOrEqualTo(500));
      }
      // The header total is the largest amount on the card.
      final sizes = styles.map((s) => s.fontSize!).toList()..sort();
      expect(sizes.last, AerosTypography.monoLg().fontSize);
      expect(sizes.where((s) => s == sizes.last), hasLength(1));
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('the slider and the range band values are the medium mono face', (t) async {
      await t.pumpWidget(_wrap(Column(
        children: [
          AerosRangeSlider(
            label: 'Weight',
            unitLabel: 'gsm',
            range: const AerosNumericRange(min: 100, max: 300, step: 10),
            value: 200,
            onChanged: (_) {},
          ),
          AerosNumericRangeBand(
            label: 'Band',
            range: const AerosNumericRange(min: 100, max: 300, step: 10),
            values: const RangeValues(150, 250),
            onChanged: (_) {},
          ),
        ],
      )));
      final styles = monoStyles(t).toList();
      expect(styles, hasLength(2));
      for (final style in styles) {
        expect(style.fontWeight, FontWeight.w500);
      }
    });
  });

  group('sliders', () {
    testWidgets('share the token-driven theme: 2px track, 14px thumb, no halo size', (t) async {
      await t.pumpWidget(_wrap(AerosRangeSlider(
        label: 'Weight',
        range: const AerosNumericRange(min: 100, max: 300, step: 10),
        value: 200,
        onChanged: (_) {},
      )));
      final theme = SliderTheme.of(t.element(find.byType(Slider)));
      expect(theme.trackHeight, AerosMetricTokens.borderThick);
      expect(theme.thumbShape!.getPreferredSize(true, true), const Size.square(AerosSizeTokens.iconSm));
      expect(theme.overlayShape!.getPreferredSize(true, true), Size.zero);
      expect(theme.showValueIndicator, ShowValueIndicator.never);
      // The halo colour is the focus ring, and only on keyboard focus.
      final overlay = theme.overlayColor! as WidgetStateColor;
      expect(overlay.resolve({WidgetState.hovered}).a, 0);
      expect(overlay.resolve({WidgetState.dragged}).a, 0);
      expect(overlay.resolve({WidgetState.focused}), AerosAliasColors.light.focusRing);

      // Arrow keys still move a focused slider.
      num? changed;
      await t.pumpWidget(_wrap(AerosRangeSlider(
        range: const AerosNumericRange(min: 100, max: 300, step: 10),
        value: 200,
        onChanged: (v) => changed = v,
      )));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pump();
      expect(changed, 210);
    });

    testWidgets('a disabled slider is dimmed as a whole', (t) async {
      await t.pumpWidget(_wrap(AerosRangeSlider(
        range: const AerosNumericRange(min: 100, max: 300, step: 10),
        value: 200,
        enabled: false,
        onChanged: (_) {},
      )));
      expect(t.widget<Slider>(find.byType(Slider)).onChanged, isNull);
      final dim = t.widget<Opacity>(find.ancestor(of: find.byType(Slider), matching: find.byType(Opacity)).first);
      expect(dim.opacity, AerosMetricTokens.opacityDisabled);
    });
  });

  group('AerosFileUploadButton', () {
    testWidgets('the drop zone is a button that answers the keyboard', (t) async {
      var picks = 0;
      await t.pumpWidget(_wrap(AerosFileUploadButton(
        label: 'Artwork',
        value: null,
        onPickFile: () async {
          picks++;
          return null;
        },
      )));
      expect(find.byType(InkWell), findsNothing);
      await t.tap(find.text('Upload artwork'));
      await t.pumpAndSettle();
      expect(picks, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(picks, 2);
    });

    testWidgets('an attached file offers Replace and Remove as Aeros buttons', (t) async {
      var removed = false;
      var picks = 0;
      await t.pumpWidget(_wrap(AerosFileUploadButton(
        value: const AerosFileRef(id: 'f1', name: 'logo.pdf', sizeBytes: 204800),
        onPickFile: () async {
          picks++;
          return null;
        },
        onRemove: () => removed = true,
      )));
      expect(find.text('logo.pdf'), findsOneWidget);
      expect(find.text('200 KB'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      await t.tap(find.text('Replace'));
      await t.pumpAndSettle();
      expect(picks, 1);
      await t.tap(find.bySemanticsLabel('Remove'));
      await t.pumpAndSettle();
      expect(removed, isTrue);
    });
  });

  group('AerosEnumDropdown', () {
    testWidgets('is an AerosSelect: opens a list, reports the id, shows why an option is off', (t) async {
      String? picked;
      await t.pumpWidget(_wrap(AerosEnumDropdown(
        label: 'Material',
        options: const [
          AerosAttributeOption(id: 'kraft', label: 'Kraft'),
          AerosAttributeOption(id: 'pe', label: 'PE coated', disabled: true, disabledReason: 'Not for this size'),
        ],
        selectedId: null,
        onChanged: (id) => picked = id,
      )));
      expect(find.byType(AerosSelect<String>), findsOneWidget);
      expect(find.byType(DropdownButton<String?>), findsNothing);
      await t.tap(find.text('Select…'));
      await t.pumpAndSettle();
      expect(find.text('Not for this size'), findsOneWidget);
      await t.tap(find.text('PE coated'));
      await t.pumpAndSettle();
      expect(picked, isNull);
      await t.tap(find.text('Kraft'));
      await t.pumpAndSettle();
      expect(picked, 'kraft');
    });
  });

  group('right-to-left', () {
    testWidgets('every configurable-MTO widget builds and lays out', (t) async {
      t.view.physicalSize = const Size(900, 3200);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      const range = AerosNumericRange(min: 100, max: 300, step: 10);
      const options = [
        AerosAttributeOption(id: 'a', label: 'Kraft'),
        AerosAttributeOption(id: 'b', label: 'White', disabled: true, disabledReason: 'Out'),
      ];
      const file = AerosFileRef(id: 'f', name: 'logo.pdf', sizeBytes: 2048);
      const variants = [
        AerosVariantOption(id: 'a', label: 'Ink', swatchColor: 0xFF111111, stockQty: 3),
        AerosVariantOption(id: 'b', label: 'Bone', stockQty: 0),
        AerosVariantOption(id: 'c', label: 'Plain'),
      ];
      const data = AerosPriceBreakdownData(
        currencySymbol: '₹',
        discountableSubtotal: 100,
        nonDiscountableSubtotal: 50,
        total: 140,
        steps: [
          AerosBreakdownStep(name: 'Base', amount: 100),
          AerosBreakdownStep(name: 'Setup fee', amount: 50, discountable: false, note: 'One time'),
          AerosBreakdownStep(name: 'Bulk discount', amount: -10),
        ],
      );
      AerosAttributeSpec spec(AerosAttributeDatatype type, AerosAttributeOptionSource source, {bool locked = false}) =>
          AerosAttributeSpec(
            key: 'k',
            label: 'Attribute',
            datatype: type,
            optionSource: source,
            required: true,
            lockedByAdmin: locked,
            helperText: 'Helper',
            options: [for (var i = 0; i < 8; i++) AerosAttributeOption(id: '$i', label: 'Option $i')],
            range: range,
            units: const [AerosMeasurementUnit(code: 'mm', label: 'mm'), AerosMeasurementUnit(code: 'cm', label: 'cm')],
            defaultUnit: 'mm',
          );

      await t.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AerosEnumDropdown(label: 'Material', options: options, selectedId: 'a', onChanged: (_) {}),
                  AerosEnumDropdown(options: options, selectedId: null, onChanged: (_) {}, errorText: 'Required'),
                  AerosRangeSlider(label: 'Weight', unitLabel: 'gsm', range: range, value: 200, onChanged: (_) {}),
                  const AerosRangeSlider(range: range, value: null, onChanged: null, errorText: 'Required'),
                  AerosNumericRangeBand(
                    label: 'Band',
                    range: range,
                    values: const RangeValues(150, 250),
                    onChanged: (_) {},
                  ),
                  AerosMeasurementInput(
                    label: 'Width',
                    units: const [
                      AerosMeasurementUnit(code: 'mm', label: 'mm'),
                      AerosMeasurementUnit(code: 'cm', label: 'cm'),
                    ],
                    numericValue: 12,
                    unitCode: 'mm',
                    range: range,
                    onChanged: (_, __) {},
                  ),
                  AerosMeasurementInput(units: const [], numericValue: null, unitCode: null, onChanged: (_, __) {}),
                  AerosFileUploadButton(label: 'Artwork', value: null, onPickFile: () async => null),
                  AerosFileUploadButton(value: file, onPickFile: () async => null, onRemove: () {}),
                  AerosFileUploadButton(value: null, onPickFile: () async => null, errorText: 'Required', enabled: false),
                  AerosVariantPicker(variants: variants, selectedVariantId: 'a', onChanged: (_) {}),
                  AerosVariantPicker(
                    variants: variants,
                    selectedVariantId: 'c',
                    onChanged: (_) {},
                    style: AerosVariantPickerStyle.swatch,
                    errorText: 'Pick one',
                  ),
                  const AerosPriceBreakdown(data: data),
                  const AerosPriceBreakdown(data: data, initiallyExpanded: true, dense: true),
                  AerosRepeatingRows<int>(
                    items: const [1, 2],
                    itemBuilder: (context, i, item) => Text('Row $item'),
                    onAdd: () {},
                    onRemove: (_) {},
                    addLabel: 'Add row',
                    label: 'Rows',
                    errorText: 'Error',
                  ),
                  for (final variant in AerosAttributeInputVariant.values)
                    AerosAttributeSelector(
                      spec: spec(AerosAttributeDatatype.enumValue, AerosAttributeOptionSource.enumOptions),
                      value: const AerosAttributeValue(),
                      onChanged: (_) {},
                      forceVariant: variant,
                      errorText: 'Error',
                    ),
                  AerosAttributeSelector(
                    spec: spec(AerosAttributeDatatype.boolean, AerosAttributeOptionSource.enumOptions, locked: true),
                    value: const AerosAttributeValue(boolValue: true),
                    onChanged: (_) {},
                  ),
                  AerosHoverable(builder: (context, hovered) => const SizedBox(height: 20)),
                  AerosHoverable(onTap: () {}, builder: (context, hovered) => const SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ),
      ));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);

      // The unit sits at the end of the field — the left, here.
      final frame = t.getRect(find.byType(AerosFieldFrame).at(2));
      expect(t.getRect(find.text('mm').first).center.dx, lessThan(frame.center.dx));

      // The unit list opens, too.
      await t.tap(find.text('mm').first);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(AerosMenuList), findsOneWidget);
    });
  });

  group('Token helpers', () {
    test('AerosSelectionPalette resolves all states', () {
      for (final state in AerosSelectionState.values) {
        final p = AerosSelectionPalette.resolve(state, AerosAliasColors.light, AerosSemanticColors.light);
        expect(p.background, isNotNull);
        expect(p.foreground, isNotNull);
        expect(p.border, isNotNull);
      }
    });

    test('AerosSeverityPalette returns icon for each severity', () {
      for (final s in AerosSeverity.values) {
        expect(AerosSeverityPalette.resolve(s, AerosSemanticColors.light).icon, isNotNull);
      }
    });

    test('AerosPricePalette flags non-discountable lines with label', () {
      final p = AerosPricePalette.resolve(
        AerosPriceTone.nonDiscountable,
        AerosAliasColors.light,
        AerosSemanticColors.light,
      );
      expect(p.label, 'fixed');
    });
  });
}
