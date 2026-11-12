import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

Finder get _paint => find.descendant(
      of: find.byType(AerosWordmark),
      matching: find.byType(CustomPaint),
    );

AerosLogoPainter _painterOf(WidgetTester t) =>
    t.widget<CustomPaint>(_paint).painter! as AerosLogoPainter;

void main() {
  group('AerosWordmark', () {
    testWidgets('is painted from outlines, never typed text', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(find.text('Aeros'), findsNothing);
      expect(_painterOf(t).showSymbol, isTrue);
    });

    testWidgets('announces itself as "Aeros" to screen readers', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(find.bySemanticsLabel('Aeros'), findsOneWidget);
    });

    testWidgets('defaults to a 24 px tall lockup at the artwork aspect',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(t.getSize(_paint).height, 24);
      expect(t.getSize(_paint).width, closeTo(24 * kAerosLockupAspect, 1e-6));
    });

    testWidgets('respects an explicit size', (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(size: 40)));
      expect(t.getSize(_paint).height, 40);
    });

    testWidgets('showSymbol: false draws the wordmark alone, narrower',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(showSymbol: false)));
      expect(_painterOf(t).showSymbol, isFalse);
      expect(
        t.getSize(_paint).width,
        closeTo(24 * (kAerosLockupAspect - kAerosWordmarkLeft), 1e-6),
      );
    });

    testWidgets('default colour resolves to aliases.fgPrimary (light)',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark()));
      expect(_painterOf(t).color, AerosAliasColors.light.fgPrimary);
    });

    testWidgets('default colour resolves to aliases.fgPrimary (dark)',
        (t) async {
      await t.pumpWidget(_wrap(const AerosWordmark(), dark: true));
      expect(_painterOf(t).color, AerosAliasColors.dark.fgPrimary);
    });

    testWidgets('an explicit color overrides the theme default', (t) async {
      await t.pumpWidget(
        _wrap(const AerosWordmark(color: Color(0xFFFF00FF))),
      );
      expect(_painterOf(t).color, const Color(0xFFFF00FF));
    });

    testWidgets('textAlign centres the logo inside a wider box', (t) async {
      await t.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: AerosWordmark(textAlign: TextAlign.center),
          ),
        ),
      ));
      expect(t.getRect(_paint).center.dx, closeTo(200, 0.5));
    });

    testWidgets('paints both variants without errors', (t) async {
      await t.pumpWidget(_wrap(const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AerosWordmark(size: 40),
          AerosWordmark(size: 18, showSymbol: false),
        ],
      )));
      expect(t.takeException(), isNull);
    });
  });
}
