import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AerosTheme.light(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

void main() {
  group('AerosNumericRangeBand', () {
    const range = AerosNumericRange(min: 100, max: 300, step: 10);

    testWidgets('renders both thumbs at the supplied values', (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: const RangeValues(180, 220),
        unitLabel: 'gsm',
        label: 'GSM',
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.byType(RangeSlider), findsOneWidget);
      // Header row shows both formatted values.
      expect(find.text('180 gsm – 220 gsm'), findsOneWidget);
      // Min/max captions render the outer bounds.
      expect(find.text('100 gsm'), findsOneWidget);
      expect(find.text('300 gsm'), findsOneWidget);
    });

    testWidgets('null values default to the full outer range', (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: null,
        unitLabel: 'gsm',
        label: 'GSM',
        onChanged: (_) {},
      )));
      await t.pump();
      // Default band is (range.min, range.max).
      expect(find.text('100 gsm – 300 gsm'), findsOneWidget);
    });

    testWidgets('inverted incoming values are auto-repaired', (t) async {
      // Caller passes start > end (stale state); widget should still render
      // a sensible band (lower as start, higher as end) and not crash.
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: const RangeValues(250, 150),
        unitLabel: 'gsm',
        label: 'GSM',
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.text('150 gsm – 250 gsm'), findsOneWidget);
    });

    testWidgets('out-of-range values are clamped into the outer bounds',
        (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        // Caller passes values outside [100, 300] — clamp into bounds.
        values: const RangeValues(50, 400),
        unitLabel: 'gsm',
        label: 'GSM',
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.text('100 gsm – 300 gsm'), findsOneWidget);
    });

    testWidgets('disabled hides interaction (onChanged null)', (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: const RangeValues(180, 220),
        unitLabel: 'gsm',
        label: 'GSM',
        enabled: false,
        onChanged: (_) {},
      )));
      await t.pump();
      // The Material RangeSlider receives `null` for onChanged when disabled.
      final slider = t.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.onChanged, isNull);
    });

    testWidgets('error text renders when supplied', (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: const RangeValues(180, 220),
        unitLabel: 'gsm',
        label: 'GSM',
        errorText: 'Pick a wider band',
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.text('Pick a wider band'), findsOneWidget);
    });

    testWidgets('formatValue overrides default formatter', (t) async {
      await t.pumpWidget(_wrap(AerosNumericRangeBand(
        range: range,
        values: const RangeValues(180, 220),
        formatValue: (v) => '#${v.toInt()}',
        label: 'GSM',
        onChanged: (_) {},
      )));
      await t.pump();
      expect(find.text('#180 – #220'), findsOneWidget);
    });
  });
}
