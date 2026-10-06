import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSidenav(
    WidgetTester tester, {
    AerosSidenavDensity density = AerosSidenavDensity.pointer,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AerosTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: AerosSidenav(
              density: density,
              items: [
                AerosNavItem(
                  key: const ValueKey('nav:orders'),
                  label: 'Orders',
                  icon: Icons.receipt_long_outlined,
                  onTap: () {},
                ),
                AerosNavItem(
                  key: const ValueKey('nav:inbox'),
                  label: 'Inbox',
                  icon: Icons.inbox_outlined,
                  count: 3,
                  onTap: () {},
                ),
                const AerosNavItem(
                  label: 'Masters',
                  icon: Icons.settings_outlined,
                  section: 'Admin',
                  children: [
                    AerosNavItem(label: 'Units Master'),
                    AerosNavItem(label: 'Industry Master', selected: true),
                  ],
                ),
                const AerosNavItem(label: 'Team', icon: Icons.groups_outlined, section: 'Admin'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double wght(WidgetTester tester, String text) => tester
      .widget<Text>(find.text(text))
      .style!
      .fontVariations!
      .firstWhere((v) => v.axis == 'wght')
      .value;

  group('AerosSidenav density', () {
    testWidgets('pointer rows are 32px with 16px icons and 13px labels', (tester) async {
      await pumpSidenav(tester);

      final label = tester.widget<Text>(find.text('Orders'));
      expect(label.style!.fontSize, 13);
      expect(label.maxLines, 1);
      expect(label.overflow, TextOverflow.ellipsis);
      expect(tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined)).size, 16);
      // 32px row + the 2px gap that keeps a hovered pill from fusing with the selected one.
      expect(tester.getSize(find.byKey(const ValueKey('nav:orders'))).height, 34);
    });

    testWidgets('touch rows are 48px with 20px icons', (tester) async {
      await pumpSidenav(tester, density: AerosSidenavDensity.touch);
      expect(tester.getSize(find.byKey(const ValueKey('nav:orders'))).height, 50);
      expect(tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined)).size, 20);
    });
  });

  group('AerosSidenav structure', () {
    testWidgets('a group label is drawn once, in sentence case, where the section starts', (tester) async {
      await pumpSidenav(tester);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('ADMIN'), findsNothing);
      expect(tester.getTopLeft(find.text('Admin')).dy, lessThan(tester.getTopLeft(find.text('Masters')).dy));
    });

    testWidgets('a parent holding the selection starts open; children align with its label', (tester) async {
      await pumpSidenav(tester);
      expect(find.text('Industry Master'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Units Master')).dx,
        tester.getTopLeft(find.text('Masters')).dx,
      );

      await tester.tap(find.text('Masters'));
      await tester.pumpAndSettle();
      expect(find.text('Industry Master'), findsNothing);
    });

    testWidgets('the selected row is bold on the variable-font axis, the rest are medium', (tester) async {
      await pumpSidenav(tester);
      // Inter follows the wght axis, not fontWeight: a copyWith(fontWeight:) alone renders unchanged.
      expect(wght(tester, 'Industry Master'), 600);
      expect(wght(tester, 'Orders'), 500);
    });

    testWidgets('a count is a pill and part of the announced label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSidenav(tester);
      expect(find.text('3'), findsOneWidget);
      expect(find.bySemanticsLabel('Inbox, 3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the selected row fills bgSubtle in both themes', (tester) async {
      for (final theme in [AerosTheme.light(), AerosTheme.dark()]) {
        await pumpSidenav(tester, theme: theme);
        final fill = tester
            .widgetList<Material>(find.ancestor(of: find.text('Industry Master'), matching: find.byType(Material)))
            .first
            .color;
        final ctx = tester.element(find.text('Industry Master'));
        expect(fill, ctx.aerosColors.bgSubtle);
      }
    });
  });

  test('withWeight moves the wght axis and keeps the optical size', () {
    final s = AerosTypography.bodySm().withWeight(FontWeight.w600);
    expect(s.fontWeight, FontWeight.w600);
    expect(s.fontVariations!.where((v) => v.axis == 'wght').single.value, 600);
    expect(s.fontVariations!.where((v) => v.axis == 'opsz'), hasLength(1));
  });
}
