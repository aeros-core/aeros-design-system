import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      home: Scaffold(body: child),
    );

TextStyle _styleOf(WidgetTester t) => t.widget<Text>(find.text('Aeros')).style!;

void main() {
  group('AerosWordmark', () {
    testWidgets('renders the literal "Aeros" string', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(find.text('Aeros'), findsOneWidget);
    });

    testWidgets('uses the bundled expanded face, not google_fonts', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      // google_fonts serves static normal-width cuts (the wdth axis was
      // silently ignored), so the wordmark ships its own subset font.
      expect(
        _styleOf(t).fontFamily,
        'packages/aeros_design_system/${AerosWordmark.fontFamily}',
      );
      expect(_styleOf(t).fontVariations, isNull);
    });

    testWidgets('regular weight (Medium, 500)', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(_styleOf(t).fontWeight, FontWeight.w500);
    });

    testWidgets('tracks open at +0.01em of the size', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(size: 40)));
      expect(_styleOf(t).letterSpacing, closeTo(0.4, 1e-9));
    });

    testWidgets('defaults size to 24 logical pixels', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(_styleOf(t).fontSize, 24);
    });

    testWidgets('respects an explicit size', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(size: 40)));
      expect(_styleOf(t).fontSize, 40);
    });

    testWidgets('default colour resolves to aliases.fgPrimary (light)',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(_styleOf(t).color, AerosAliasColors.light.fgPrimary);
    });

    testWidgets('default colour resolves to aliases.fgPrimary (dark)',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(), dark: true));
      expect(_styleOf(t).color, AerosAliasColors.dark.fgPrimary);
    });

    testWidgets('an explicit color overrides the theme default', (t) async {
      await t.pumpWidget(
        _wrap(const AerosWordmark(color: Color(0xFFFF00FF))),
      );
      expect(_styleOf(t).color, const Color(0xFFFF00FF));
    });

    testWidgets('forwards textAlign onto the underlying Text', (t) async {
      await t.pumpWidget(
        _wrap(const AerosWordmark(textAlign: TextAlign.center)),
      );
      final text = t.widget<Text>(find.text('Aeros'));
      expect(text.textAlign, TextAlign.center);
    });
  });
}
