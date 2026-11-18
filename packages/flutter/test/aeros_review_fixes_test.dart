// Regression tests for the rough edges found in the 3.0 review: the modal
// header at touch density, a scrolled menu's padding, the disabled slider
// readout, disabled enum chips, data table cell emphasis and swatch hairlines.
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget child, {
  bool dark = false,
  AerosDensity? density,
  TextDirection direction = TextDirection.ltr,
}) =>
    MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      // Above the Navigator, so dialogs, sheets and menus get them too.
      builder: (context, navigator) {
        final child = Directionality(textDirection: direction, child: navigator!);
        return density == null ? child : AerosDensityScope(density: density, child: child);
      },
      home: Scaffold(body: Center(child: child)),
    );

void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// WCAG relative-luminance contrast between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The opacity [finder]'s subtree is painted at: the product of every
/// [Opacity] between it and the widget of type [T] that holds it.
double _opacityWithin<T extends Widget>(WidgetTester tester, Finder finder) {
  var opacity = 1.0;
  var inside = true;
  tester.element(finder).visitAncestorElements((element) {
    if (element.widget is T) inside = false;
    if (inside && element.widget is Opacity) opacity *= (element.widget as Opacity).opacity;
    return inside;
  });
  return opacity;
}

void main() {
  group('modal header at touch density', () {
    Widget dialogOpener({String? title = 'Edit address', String? description}) => Builder(
          builder: (context) => AerosButton(
            label: 'Open',
            onPressed: () => AerosDialog.show<void>(
              context,
              builder: (context) => AerosDialog(
                title: title,
                description: description,
                content: const Text('Body', key: Key('body')),
              ),
            ),
          ),
        );

    Widget sheetOpener(AerosSheetSide side) => Builder(
          builder: (context) => AerosButton(
            label: 'Open',
            onPressed: () => AerosSheet.show<void>(
              context,
              side: side,
              builder: (context) => const AerosSheet(
                title: 'Order #1042',
                content: Text('Body', key: Key('body')),
                showDragHandle: false,
              ),
            ),
          ),
        );

    /// Distance from the top of the modal surface to the top of its body.
    Future<double> headerHeight(WidgetTester tester, Widget opener, AerosDensity density) async {
      await tester.pumpWidget(_app(opener, density: density));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final surface = tester.getRect(
        find.ancestor(of: find.byKey(const Key('body')), matching: find.byType(AerosSurface)).first,
      );
      final height = tester.getRect(find.byKey(const Key('body'))).top - surface.top;
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      return height;
    }

    final closeButton = find.widgetWithIcon(AerosButton, Icons.close);
    final closeVisual = find.descendant(of: closeButton, matching: find.byType(AerosStateFill));

    testWidgets('the close button keeps a 48dp target; its painted box is the small control', (tester) async {
      await tester.pumpWidget(_app(dialogOpener(), density: AerosDensity.touch));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.getSize(closeButton), const Size(48, 48));
      expect(tester.getSize(closeVisual), const Size(36, 36));
      // The painted box sits 12 in from the corner, as it does for a mouse.
      final surface = tester.getRect(find.ancestor(of: closeButton, matching: find.byType(AerosSurface)).first);
      final visual = tester.getRect(closeVisual);
      expect(visual.top - surface.top, AerosSpacing.s3);
      expect(surface.right - visual.right, AerosSpacing.s3);
      // The whole target is inside the surface, so all of it can be hit.
      final target = tester.getRect(closeButton);
      expect(target.top, greaterThanOrEqualTo(surface.top));
      expect(target.right, lessThanOrEqualTo(surface.right));

      // A tap in the target but outside the painted box still closes.
      await tester.tapAt(target.topRight + const Offset(-2, 2));
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);
    });

    testWidgets('the 48dp target adds no height: only the painted box counts', (tester) async {
      // Title only: the text block (8 + one h3 line) is shorter than the
      // 36px button at touch, so the header is 12 + 36 + 12. The 48dp target
      // used to make it 12 + 48 + 12.
      final touch = await headerHeight(tester, dialogOpener(), AerosDensity.touch);
      expect(touch, AerosSpacing.s3 + 36 + AerosSpacing.s3);
      final pointer = await headerHeight(tester, dialogOpener(), AerosDensity.pointer);
      // What is left between the densities is the painted button (36 against
      // 28), not the hit target (48 against 28).
      expect(touch - pointer, lessThan(8));
    });

    testWidgets('with a description the header is the same height at both densities', (tester) async {
      final touch = await headerHeight(
        tester,
        dialogOpener(description: 'Shown on invoices.'),
        AerosDensity.touch,
      );
      final pointer = await headerHeight(
        tester,
        dialogOpener(description: 'Shown on invoices.'),
        AerosDensity.pointer,
      );
      expect(touch, pointer);
    });

    testWidgets('a header with only the close button is as tall as its painted box', (tester) async {
      expect(await headerHeight(tester, dialogOpener(title: null), AerosDensity.touch), 12 + 36 + 12);
      expect(await headerHeight(tester, dialogOpener(title: null), AerosDensity.pointer), 12 + 28 + 12);
    });

    testWidgets('sheets share the header: same height as the dialog at touch', (tester) async {
      _surface(tester, const Size(900, 700));
      final dialog = await headerHeight(tester, dialogOpener(title: 'Order #1042'), AerosDensity.touch);
      for (final side in AerosSheetSide.values) {
        expect(await headerHeight(tester, sheetOpener(side), AerosDensity.touch), dialog, reason: '$side');
      }
    });

    testWidgets('right-to-left: the close button mirrors to the left corner', (tester) async {
      await tester.pumpWidget(_app(dialogOpener(), density: AerosDensity.touch, direction: TextDirection.rtl));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final surface = tester.getRect(find.ancestor(of: closeButton, matching: find.byType(AerosSurface)).first);
      expect(tester.getRect(closeVisual).left - surface.left, AerosSpacing.s3);
      expect(tester.getRect(find.text('Edit address')).left, greaterThan(tester.getRect(closeVisual).right));
    });
  });

  group('a scrolled menu keeps its padding', () {
    Widget menu() => Align(
          alignment: Alignment.topLeft,
          child: AerosMenu(
            items: [for (var i = 0; i < 40; i++) AerosMenuItem<void>(label: 'Action $i')],
            trigger: (context, menu) => AerosButton.secondary(label: 'Actions', onPressed: menu.toggle),
          ),
        );

    /// The rows that can be seen, clipped to the scrolling viewport.
    List<Rect> visibleRows(WidgetTester tester) {
      final viewport = tester.getRect(find.byType(AerosWholeRows));
      return [
        for (final element in find.byType(AerosMenuRow).evaluate())
          if (tester.getRect(find.byWidget(element.widget)).overlaps(viewport))
            tester.getRect(find.byWidget(element.widget)).intersect(viewport),
      ];
    }

    for (final density in AerosDensity.values) {
      testWidgets('4px above the first row and below the last, at every scroll offset · ${density.name}',
          (tester) async {
        _surface(tester, const Size(400, 330));
        await tester.pumpWidget(_app(menu(), density: density));
        await tester.tap(find.text('Actions'));
        await tester.pumpAndSettle();

        final panel = tester.getRect(
          find.ancestor(of: find.byType(AerosMenuList), matching: find.byType(AerosSurface)).first,
        );
        final rowHeight = AerosControlSize.sm.heightFor(density);

        void expectPadded(String when) {
          final rows = visibleRows(tester);
          expect(rows, isNotEmpty);
          expect(rows.first.top - panel.top, AerosMenu.panelPadding, reason: 'top, $when');
          expect(panel.bottom - rows.last.bottom, AerosMenu.panelPadding, reason: 'bottom, $when');
        }

        expectPadded('at the top');
        // Not every row fits, and the visible ones are whole.
        expect(visibleRows(tester).length, lessThan(40));
        for (final row in visibleRows(tester)) {
          expect(row.height, rowHeight);
        }

        // Part of the way down: rows are cut at the padding, never at the edge.
        await tester.drag(find.text('Action 2'), Offset(0, -(rowHeight * 3 + 7)));
        await tester.pumpAndSettle();
        expectPadded('scrolled part way');

        // The end.
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expectPadded('at the end');
        expect(tester.getRect(find.text('Action 39')).bottom, lessThanOrEqualTo(panel.bottom - AerosMenu.panelPadding));
        for (final row in visibleRows(tester)) {
          expect(row.height, rowHeight);
        }
      });
    }

    testWidgets('a short menu is unchanged: padding, rows, padding', (tester) async {
      await tester.pumpWidget(
        _app(
          AerosMenu(
            items: const [AerosMenuItem<void>(label: 'Rename'), AerosMenuItem<void>(label: 'Delete')],
            trigger: (context, menu) => AerosButton.secondary(label: 'Actions', onPressed: menu.toggle),
          ),
          density: AerosDensity.pointer,
        ),
      );
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      final panel = tester.getRect(
        find.ancestor(of: find.byType(AerosMenuList), matching: find.byType(AerosSurface)).first,
      );
      expect(panel.height, 2 * AerosMenu.panelPadding + 2 * 28);
    });

    testWidgets('the select and the search dropdown lists keep it too', (tester) async {
      _surface(tester, const Size(500, 330));
      final items = [for (var i = 0; i < 40; i++) 'Option $i'];
      for (final field in <Widget>[
        AerosSelect<String>(
          placeholder: 'Pick one',
          value: null,
          onChanged: (_) {},
          items: [for (final item in items) AerosSelectItem(value: item, label: item)],
        ),
        AerosDropdownSearch<String>(
          hint: 'Pick one',
          items: items,
          itemAsString: (s) => s,
          mode: AerosDropdownMode.menu,
          showSearchBox: false,
        ),
      ]) {
        await tester.pumpWidget(
          _app(
            Align(alignment: Alignment.topLeft, child: SizedBox(width: 240, child: field)),
            density: AerosDensity.pointer,
          ),
        );
        await tester.tap(find.text('Pick one'));
        await tester.pumpAndSettle();
        final panel = tester.getRect(
          find.ancestor(of: find.byType(AerosWholeRows), matching: find.byType(AerosSurface)).first,
        );
        final viewport = tester.getRect(find.byType(AerosWholeRows));
        expect(viewport.top - panel.top, AerosMenu.panelPadding, reason: '${field.runtimeType}');
        expect(panel.bottom - viewport.bottom, AerosMenu.panelPadding, reason: '${field.runtimeType}');
        // A whole number of rows.
        expect(viewport.height % 28, 0, reason: '${field.runtimeType}');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('a disabled slider dims its value', () {
    const range = AerosNumericRange(min: 150, max: 350, step: 10);

    testWidgets('AerosRangeSlider: the readout is at the disabled opacity, like the track', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 320,
            child: AerosRangeSlider(
              label: 'Paper weight',
              unitLabel: 'gsm',
              range: range,
              value: 250,
              enabled: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        _opacityWithin<AerosRangeSlider>(tester, find.text('250 gsm')),
        AerosMetricTokens.opacityDisabled,
      );
      expect(_opacityWithin<AerosRangeSlider>(tester, find.byType(Slider)), AerosMetricTokens.opacityDisabled);
      // The label names the field; it is not dimmed.
      expect(_opacityWithin<AerosRangeSlider>(tester, find.byType(RichText).first), 1);
    });

    testWidgets('AerosRangeSlider: a null onChanged disables it the same way; enabled is not dimmed', (tester) async {
      Widget slider(ValueChanged<num>? onChanged) => _app(
            SizedBox(
              width: 320,
              child: AerosRangeSlider(label: 'Paper weight', range: range, value: 250, onChanged: onChanged),
            ),
          );
      await tester.pumpWidget(slider(null));
      expect(_opacityWithin<AerosRangeSlider>(tester, find.text('250')), AerosMetricTokens.opacityDisabled);
      await tester.pumpWidget(slider((_) {}));
      expect(_opacityWithin<AerosRangeSlider>(tester, find.text('250')), 1);
    });

    testWidgets('AerosNumericRangeBand: the band readout is at the disabled opacity', (tester) async {
      Widget band({required bool enabled}) => _app(
            SizedBox(
              width: 320,
              child: AerosNumericRangeBand(
                label: 'GSM offered',
                range: range,
                values: const RangeValues(180, 220),
                enabled: enabled,
                onChanged: (_) {},
              ),
            ),
          );
      await tester.pumpWidget(band(enabled: false));
      expect(
        _opacityWithin<AerosNumericRangeBand>(tester, find.text('180 – 220')),
        AerosMetricTokens.opacityDisabled,
      );
      expect(
        _opacityWithin<AerosNumericRangeBand>(tester, find.byType(RangeSlider)),
        AerosMetricTokens.opacityDisabled,
      );
      await tester.pumpWidget(band(enabled: true));
      expect(_opacityWithin<AerosNumericRangeBand>(tester, find.text('180 – 220')), 1);
    });
  });

  group('disabled AerosEnumChips', () {
    const options = [
      AerosAttributeOption(id: 'pla', label: 'PLA'),
      AerosAttributeOption(id: 'pe', label: 'PE'),
    ];

    Widget chips({bool enabled = true, ValueChanged<String?>? onChanged}) => _app(
          AerosEnumChips(
            label: 'Coating',
            options: options,
            selectedId: 'pla',
            enabled: enabled,
            onChanged: onChanged,
          ),
        );

    testWidgets('enabled false dims the chips to the opacity token and ignores taps', (tester) async {
      final picked = <String?>[];
      await tester.pumpWidget(chips(enabled: false, onChanged: picked.add));
      expect(_opacityWithin<AerosEnumChips>(tester, find.text('PE')), AerosMetricTokens.opacityDisabled);
      expect(_opacityWithin<AerosEnumChips>(tester, find.text('PLA')), AerosMetricTokens.opacityDisabled);
      // The label is not dimmed, and the chosen chip still shows its check.
      expect(_opacityWithin<AerosEnumChips>(tester, find.byType(RichText).first), 1);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.tap(find.text('PE'));
      await tester.pump();
      expect(picked, isEmpty);
    });

    testWidgets('a null onChanged is the same disabled state; enabled chips are not dimmed', (tester) async {
      await tester.pumpWidget(chips());
      expect(_opacityWithin<AerosEnumChips>(tester, find.text('PE')), AerosMetricTokens.opacityDisabled);
      await tester.pumpWidget(chips(onChanged: (_) {}));
      expect(_opacityWithin<AerosEnumChips>(tester, find.text('PE')), 1);
    });

    testWidgets('no hover state, no keyboard focus', (tester) async {
      await tester.pumpWidget(chips(enabled: false, onChanged: (_) {}));
      Color fill() => tester
          .widget<AerosStateFill>(find.ancestor(of: find.text('PE'), matching: find.byType(AerosStateFill)))
          .color;
      final resting = fill();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('PE')));
      await tester.pumpAndSettle();
      expect(fill(), resting);
      // Tab finds nothing to land on in the group.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<AerosEnumChips>(),
        isNull,
      );
    });

    testWidgets('enabled chips do answer hover and focus (the control for the test above)', (tester) async {
      await tester.pumpWidget(chips(onChanged: (_) {}));
      Color fill() => tester
          .widget<AerosStateFill>(find.ancestor(of: find.text('PE'), matching: find.byType(AerosStateFill)))
          .color;
      final resting = fill();
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('PE')));
      await tester.pumpAndSettle();
      expect(fill(), isNot(resting));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<AerosEnumChips>(),
        isNotNull,
      );
    });

    testWidgets('each chip is announced as a disabled button, the chosen one as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(chips(enabled: false, onChanged: (_) {}));
      expect(
        tester.getSemantics(find.text('PE')),
        isSemantics(label: 'PE', isButton: true, hasEnabledState: true, isEnabled: false, hasSelectedState: true),
      );
      expect(
        tester.getSemantics(find.text('PLA')),
        isSemantics(
          label: 'PLA',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('AerosAttributeSelector: a locked enum attribute renders the disabled chips', (tester) async {
      final changes = <AerosAttributeValue>[];
      await tester.pumpWidget(
        _app(
          AerosAttributeSelector(
            spec: const AerosAttributeSpec(
              key: 'coating',
              label: 'Coating',
              datatype: AerosAttributeDatatype.enumValue,
              optionSource: AerosAttributeOptionSource.enumOptions,
              lockedByAdmin: true,
              options: options,
            ),
            value: const AerosAttributeValue(enumValueId: 'pla'),
            onChanged: changes.add,
          ),
        ),
      );
      expect(tester.widget<AerosEnumChips>(find.byType(AerosEnumChips)).enabled, isFalse);
      expect(_opacityWithin<AerosEnumChips>(tester, find.text('PE')), AerosMetricTokens.opacityDisabled);
      // The lock hint under the chips stays at full strength.
      expect(_opacityWithin<AerosAttributeSelector>(tester, find.text('Locked by seller')), 1);
      await tester.tap(find.text('PE'));
      await tester.pump();
      expect(changes, isEmpty);
    });
  });

  group('AerosDataTable cell emphasis', () {
    const rows = ['Boson Machines', 'Lorven Foods'];

    Widget table({required bool dark}) => _app(
          dark: dark,
          SizedBox(
            width: 600,
            child: AerosDataTable<String>(
              rows: rows,
              columns: [
                AerosDataColumn(label: 'Buyer', emphasis: true, cell: (r) => Text(r)),
                AerosDataColumn(label: 'City', cell: (r) => Text('City of $r')),
                AerosDataColumn(label: 'Total', numeric: true, cell: (r) => Text('₹ ${r.length}')),
                AerosDataColumn(
                  label: 'Own style',
                  cell: (r) => Text('styled $r', style: const TextStyle(color: Color(0xFF123456))),
                ),
              ],
            ),
          ),
        );

    TextStyle styleOf(WidgetTester tester, String text) =>
        tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      final a = dark ? AerosAliasColors.dark : AerosAliasColors.light;

      testWidgets('body text is fgSecondary; the emphasised column is fgPrimary at w500 · $theme', (tester) async {
        await tester.pumpWidget(table(dark: dark));

        final plain = styleOf(tester, 'City of Boson Machines');
        expect(plain.color, a.fgSecondary);
        expect(plain.fontSize, AerosTypography.bodySm().fontSize);

        final strong = styleOf(tester, 'Boson Machines');
        expect(strong.color, a.fgPrimary);
        expect(strong.fontWeight, FontWeight.w500);
        expect(strong.fontVariations, contains(const FontVariation('wght', 500)));

        // Amounts stay mono in fgPrimary.
        final amount = styleOf(tester, '₹ 14');
        expect(amount.color, a.fgPrimary);
        expect(amount.fontFamily, contains('IBM Plex Mono'));

        // A cell with its own style keeps it.
        expect(styleOf(tester, 'styled Boson Machines').color, const Color(0xFF123456));
      });

      test('fgSecondary cell text clears WCAG AA (4.5:1) on every row state · $theme', () {
        // Resting, hovered, pressed, selected, and selected under the pointer.
        final states = <String, Color>{
          'rest': a.bgSurface,
          'hovered': AerosStateLayer.resolve(a, a.bgSurface, hovered: true),
          'pressed': AerosStateLayer.resolve(a, a.bgSurface, pressed: true),
          'selected': AerosStateLayer.resolve(a, a.bgSurface, selected: true),
          'selected + hovered': AerosStateLayer.resolve(a, a.bgSurface, selected: true, hovered: true),
          'selected + pressed': AerosStateLayer.resolve(a, a.bgSurface, selected: true, pressed: true),
        };
        for (final state in states.entries) {
          final ratio = _contrast(a.fgSecondary, state.value);
          // AA for body text is 4.5:1. Measured: 7.7:1 at rest and 5.6:1 at
          // worst (selected + pressed) in light; 12.2:1 and 6.4:1 in dark.
          expect(ratio, greaterThan(4.5), reason: '${state.key}: ${ratio.toStringAsFixed(2)}:1');
          // And the emphasised column must still stand out from it.
          expect(_contrast(a.fgPrimary, state.value), greaterThan(ratio), reason: state.key);
        }
      });
    }

    test('cellStyle documents the three roles', () {
      const a = AerosAliasColors.light;
      String cell(String r) => r;
      expect(AerosDataColumn<String>(label: 'x', cell: (r) => Text(cell(r))).cellStyle(a).color, a.fgSecondary);
      expect(
        AerosDataColumn<String>(label: 'x', emphasis: true, cell: (r) => Text(cell(r))).cellStyle(a).color,
        a.fgPrimary,
      );
      expect(
        AerosDataColumn<String>(label: 'x', numeric: true, cell: (r) => Text(cell(r))).cellStyle(a).color,
        a.fgPrimary,
      );
      expect(const AerosDataColumn<String>(label: 'x', cell: Text.new).emphasis, isFalse);
    });
  });

  group('AerosVariantPicker swatch hairline', () {
    const variants = [
      AerosVariantOption(id: 'ink', label: 'Ink', swatchColor: 0xFF1A1917),
      AerosVariantOption(id: 'white', label: 'White', swatchColor: 0xFFFFFFFF),
      AerosVariantOption(id: 'kraft', label: 'Kraft', swatchColor: 0xFFB08D57),
    ];

    BoxDecoration swatchOf(WidgetTester tester, String label) {
      final tile = find.ancestor(of: find.text(label), matching: find.byType(Column)).first;
      final box = find.descendant(of: tile, matching: find.byType(AnimatedContainer)).first;
      return tester.widget<AnimatedContainer>(box).decoration! as BoxDecoration;
    }

    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      final a = dark ? AerosAliasColors.dark : AerosAliasColors.light;

      testWidgets('an unselected swatch has a 1px borderStrong hairline · $theme', (tester) async {
        await tester.pumpWidget(
          _app(
            dark: dark,
            AerosVariantPicker(
              variants: variants,
              selectedVariantId: 'kraft',
              onChanged: (_) {},
              style: AerosVariantPickerStyle.swatch,
            ),
          ),
        );
        for (final label in ['Ink', 'White']) {
          final border = swatchOf(tester, label).border! as Border;
          expect(border.top.color, a.borderStrong, reason: label);
          expect(border.top.width, AerosMetricTokens.borderHairline, reason: label);
        }
        // The chosen swatch keeps the thick fgPrimary border.
        final chosen = swatchOf(tester, 'Kraft').border! as Border;
        expect(chosen.top.color, a.fgPrimary);
        expect(chosen.top.width, AerosMetricTokens.borderThick);
      });

      test('the hairline separates a near-black and a white sample from the surfaces · $theme', () {
        // The old hairline, borderDefault, is the comparison: borderStrong
        // must be the more visible of the two against every resting surface.
        for (final surface in [a.bgCanvas, a.bgSurface, a.bgElevated]) {
          expect(
            _contrast(a.borderStrong, surface),
            greaterThan(_contrast(a.borderDefault, surface)),
            reason: '$surface',
          );
        }
      });

      testWidgets('the colour dot inside a chip has the same hairline · $theme', (tester) async {
        await tester.pumpWidget(
          _app(
            dark: dark,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AerosVariantPicker(variants: variants, selectedVariantId: null, onChanged: (_) {}),
                AerosEnumChips(
                  options: const [AerosAttributeOption(id: 'ink', label: 'Ink dot', swatchColor: 0xFF1A1917)],
                  selectedId: null,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
        final dots = tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) => d.shape == BoxShape.circle && d.border != null)
            .toList();
        expect(dots, hasLength(4));
        for (final dot in dots) {
          expect((dot.border! as Border).top.color, a.borderStrong);
        }
      });
    }
  });
}
