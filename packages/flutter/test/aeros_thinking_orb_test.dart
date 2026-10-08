import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {bool dark = false, bool reduceMotion = false}) =>
    MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('AerosThinkingOrb', () {
    testWidgets('animates through a full cycle without errors', (t) async {
      await t.pumpWidget(_wrap(const AerosThinkingOrb()));
      for (var i = 0; i < 40; i++) {
        await t.pump(const Duration(milliseconds: 160));
      }
      expect(t.takeException(), isNull);
      expect(t.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('renders on the dark theme', (t) async {
      await t.pumpWidget(_wrap(const AerosThinkingOrb(), dark: true));
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
      expect(find.byType(AerosThinkingOrb), findsOneWidget);
    });

    testWidgets('paints into a square of the given size', (t) async {
      await t.pumpWidget(_wrap(const AerosThinkingOrb(size: 48)));
      final box = t.getSize(find.descendant(
        of: find.byType(AerosThinkingOrb),
        matching: find.byType(CustomPaint),
      ));
      expect(box, const Size.square(48));
    });

    testWidgets('reduce motion: one static frame, no ticker', (t) async {
      await t.pumpWidget(_wrap(const AerosThinkingOrb(), reduceMotion: true));
      await t.pump();
      expect(t.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('accepts a custom color', (t) async {
      await t.pumpWidget(_wrap(const AerosThinkingOrb(
        color: Color(0xFF16A34A),
      )));
      await t.pump(const Duration(milliseconds: 500));
      expect(t.takeException(), isNull);
    });

    testWidgets('exposes its semantic label', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(
          _wrap(const AerosThinkingOrb(semanticLabel: 'Starting up')));
      expect(find.bySemanticsLabel('Starting up'), findsOneWidget);
      handle.dispose();
    });
  });
}
