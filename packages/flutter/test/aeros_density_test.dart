import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double wght(TextStyle style) => style.fontVariations!.firstWhere((v) => v.axis == 'wght').value;

  Future<void> pump(WidgetTester tester, Widget child, {AerosDensity? density}) async {
    final body = density == null ? child : AerosDensityScope(density: density, child: child);
    await tester.pumpWidget(MaterialApp(theme: AerosTheme.light(), home: Scaffold(body: Center(child: body))));
  }

  group('AerosDensity', () {
    testWidgets('with no scope it is touch — unscoped screens do not change', (tester) async {
      late AerosDensity seen;
      await pump(tester, Builder(builder: (context) {
        seen = AerosDensity.of(context);
        return const SizedBox();
      }));
      expect(seen, AerosDensity.touch);
    });

    testWidgets('a scope sets it for its subtree', (tester) async {
      late AerosDensity seen;
      await pump(
        tester,
        Builder(builder: (context) {
          seen = AerosDensity.of(context);
          return const SizedBox();
        }),
        density: AerosDensity.pointer,
      );
      expect(seen, AerosDensity.pointer);
    });

    test('pointer is denser than touch on every metric', () {
      const p = AerosDensity.pointer;
      const t = AerosDensity.touch;
      expect(p.controlHeight, 28);
      expect(t.controlHeight, 32);
      expect(p.headerHeight, 48);
      expect(t.headerHeight, 56);
      expect(p.listAvatar, lessThan(t.listAvatar));
      expect(p.inlineAvatar, lessThan(t.inlineAvatar));
      expect(p.iconButton, lessThan(t.iconButton));
      expect(p.rowPadding.horizontal, lessThan(t.rowPadding.horizontal));
      expect(p.titleStyle().fontSize, 14);
      expect(t.titleStyle().fontSize, 16);
    });

    test('the ramp tightens line heights below the base body styles', () {
      for (final d in AerosDensity.values) {
        expect(d.bodyStyle().height, lessThan(AerosTypography.bodyMd().height!));
        expect(d.secondaryStyle().height, lessThan(AerosTypography.bodySm().height!));
        expect(d.metaStyle().height, lessThan(AerosTypography.caption().height!));
      }
    });

    test('weights move the wght axis, not just fontWeight', () {
      final title = AerosDensity.pointer.titleStyle(weight: FontWeight.w700);
      expect(title.fontWeight, FontWeight.w700);
      expect(wght(title), 700);
      expect(wght(AerosDensity.pointer.labelStyle()), 600);
      expect(wght(AerosDensity.touch.metaStyle(weight: FontWeight.w400)), 400);
    });
  });

  group('AerosCountBadge', () {
    test('labels: plain, floor, capped', () {
      expect(AerosCountBadge.label(3), '3');
      expect(AerosCountBadge.label(6, floor: true), '6+');
      expect(AerosCountBadge.label(120), '99+');
      expect(AerosCountBadge.label(120, floor: true), '99+');
    });

    testWidgets('is 18px tall at pointer and 20px at touch, never narrower than tall', (tester) async {
      await pump(tester, const AerosCountBadge(count: 3), density: AerosDensity.pointer);
      expect(tester.getSize(find.byType(AerosCountBadge)).height, 18);
      expect(tester.getSize(find.byType(AerosCountBadge)).width, greaterThanOrEqualTo(18));

      await pump(tester, const AerosCountBadge(count: 3), density: AerosDensity.touch);
      expect(tester.getSize(find.byType(AerosCountBadge)).height, 20);
    });

    testWidgets('muted swaps the brand fill for fgMuted', (tester) async {
      Color fill() => (tester.widget<Container>(find.descendant(
                of: find.byType(AerosCountBadge),
                matching: find.byType(Container),
              )).decoration as BoxDecoration)
          .color!;

      await pump(tester, const AerosCountBadge(count: 3));
      expect(fill(), AerosAliasColors.light.brandPrimary);
      await pump(tester, const AerosCountBadge(count: 3, muted: true));
      expect(fill(), AerosAliasColors.light.fgMuted);
    });

    testWidgets('a semantics label replaces the bare number', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const AerosCountBadge(count: 3, semanticsLabel: '3 unread'));
      expect(find.bySemanticsLabel('3 unread'), findsOneWidget);
      handle.dispose();
    });
  });
}
