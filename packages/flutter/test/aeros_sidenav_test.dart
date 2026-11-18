import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSidenav(
    WidgetTester tester, {
    AerosSidenavDensity density = AerosSidenavDensity.pointer,
    ThemeData? theme,
    Widget? header,
    Widget? footer,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AerosTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: AerosSidenav(
              density: density,
              header: header,
              footer: footer,
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

  // The row's painted fill: the nearest AerosStateFill around its label.
  Color? fillOf(WidgetTester tester, Finder f) => tester
      .widgetList<AerosStateFill>(find.ancestor(of: f, matching: find.byType(AerosStateFill)))
      .first
      .color;

  group('AerosSidenav density', () {
    testWidgets('pointer rows are 32px with 16px icons and 13px labels', (tester) async {
      const sizes = AerosSizeTokens.pointer;
      expect((sizes.navRow, sizes.navIcon, sizes.navLabel), (32, 16, 13));
      await pumpSidenav(tester);

      final label = tester.widget<Text>(find.text('Orders'));
      expect(label.style!.fontSize, sizes.navLabel);
      expect(label.maxLines, 1);
      expect(label.overflow, TextOverflow.ellipsis);
      expect(tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined)).size, sizes.navIcon);
      // The row + the 2px gap that keeps a hovered row from fusing with the selected one.
      expect(tester.getSize(find.byKey(const ValueKey('nav:orders'))).height, sizes.navRow + AerosSpacing.s0_5);
      // AerosSidenavDensity is a view onto the same tokens.
      expect(AerosSidenavDensity.pointer.rowHeight, sizes.navRow);
      expect(AerosSidenavDensity.pointer.iconSize, sizes.navIcon);
      expect(AerosSidenavDensity.pointer.labelSize, sizes.navLabel);
    });

    testWidgets('touch rows are 48px with 20px icons', (tester) async {
      const sizes = AerosSizeTokens.touch;
      expect((sizes.navRow, sizes.navIcon), (48, 20));
      await pumpSidenav(tester, density: AerosSidenavDensity.touch);
      expect(tester.getSize(find.byKey(const ValueKey('nav:orders'))).height, sizes.navRow + AerosSpacing.s0_5);
      expect(tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined)).size, sizes.navIcon);
    });
  });

  group('AerosSidenav structure', () {
    testWidgets('a group label is drawn once, in sentence case, where the section starts', (tester) async {
      await pumpSidenav(tester);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('ADMIN'), findsNothing);
      expect(tester.getTopLeft(find.text('Admin')).dy, lessThan(tester.getTopLeft(find.text('Masters')).dy));
    });

    testWidgets('icons and group labels share one leading edge, 20px in', (tester) async {
      await pumpSidenav(tester);
      expect(tester.getTopLeft(find.byIcon(Icons.receipt_long_outlined)).dx, 20);
      expect(tester.getTopLeft(find.text('Admin')).dx, 20);
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

    testWidgets('selected fills bgSubtle; hover is the state overlay on the rail, in both themes', (tester) async {
      for (final theme in [AerosTheme.light(), AerosTheme.dark()]) {
        await pumpSidenav(tester, theme: theme);
        final a = tester.element(find.text('Orders')).aerosColors;
        expect(fillOf(tester, find.text('Industry Master')), a.bgSubtle);
        // At rest a row is the rail itself.
        expect(fillOf(tester, find.text('Orders')), a.bgSurface);

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Orders')));
        await tester.pump();
        final hover = fillOf(tester, find.text('Orders'))!;
        // 3.0: hover is the shared `stateHover` overlay over the rail (it was a
        // bespoke half-step between the rail and the selected fill). It is
        // opaque, and distinct from the rail it rests on.
        expect(hover, Color.alphaBlend(a.stateHover, a.bgSurface));
        expect(hover.a, 1.0);
        expect(hover.computeLuminance(), isNot(a.bgSurface.computeLuminance()));
        await mouse.removePointer();
      }
    });
  });

  group('AerosSidenav blocks', () {
    testWidgets('header and footer are one app header high; mark and avatar sit on the 20px line', (tester) async {
      var switched = 0, signedOut = 0;
      await pumpSidenav(
        tester,
        header: AerosSidenavHeader(
          title: 'Aeros Packaging',
          subtitle: 'Organisation',
          onTap: () => switched++,
        ),
        footer: AerosSidenavFooter(
          name: 'Parth Panchal',
          subtitle: 'Admin',
          actionIcon: Icons.logout_rounded,
          actionLabel: 'Sign out',
          actionKey: const ValueKey('action:sign-out'),
          onAction: () => signedOut++,
        ),
      );

      // No AerosDensityScope here, so the ambient density is touch: 56.
      final header = AerosDensity.touch.sizes.header;
      expect(header, 56);
      expect(tester.getSize(find.byType(AerosSidenavHeader)).height, header);
      expect(tester.getSize(find.byType(AerosSidenavFooter)).height, header);
      // Default mark = the title's first letter.
      expect(tester.getTopLeft(find.byType(AerosSidenavMark)).dx, 20);
      expect(find.descendant(of: find.byType(AerosSidenavMark), matching: find.text('A')), findsOneWidget);
      expect(tester.getCenter(find.text('P')).dx, 20 + 12);

      // A switchable header says so with a chevron.
      expect(find.byIcon(Icons.unfold_more_rounded), findsOneWidget);
      await tester.tap(find.text('Aeros Packaging'));
      await tester.tap(find.byKey(const ValueKey('action:sign-out')));
      expect(switched, 1);
      expect(signedOut, 1);
    });

    testWidgets('a static header draws no chevron; a footer with no action has no button', (tester) async {
      await pumpSidenav(
        tester,
        header: const AerosSidenavHeader(title: 'FactoryOS', mark: AerosSidenavMark(icon: Icons.factory)),
        footer: const AerosSidenavFooter(name: 'Floor tablet'),
      );
      expect(find.byIcon(Icons.unfold_more_rounded), findsNothing);
      expect(find.byIcon(Icons.factory), findsOneWidget);
      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('a rail with no Overlay above it still builds (no tooltip)', (tester) async {
      // Where a web shell puts its rail: in MaterialApp.builder, above the Navigator's Overlay.
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          builder: (context, child) => Row(
            textDirection: TextDirection.ltr,
            children: [
              SizedBox(
                width: 240,
                child: Material(
                  child: AerosSidenav(
                    items: const [AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined)],
                    footer: AerosSidenavFooter(
                      name: 'Parth',
                      actionIcon: Icons.logout_rounded,
                      actionLabel: 'Sign out',
                      onAction: () {},
                    ),
                  ),
                ),
              ),
              Expanded(child: child!),
            ],
          ),
          home: const SizedBox(),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('the footer action is announced by its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSidenav(
        tester,
        footer: AerosSidenavFooter(
          name: 'Parth',
          actionIcon: Icons.logout_rounded,
          actionLabel: 'Sign out',
          onAction: () {},
        ),
      );
      expect(find.bySemanticsLabel('Sign out'), findsOneWidget);
      handle.dispose();
    });
  });

  test('withWeight moves the wght axis and keeps the optical size', () {
    final s = AerosTypography.bodySm().withWeight(FontWeight.w600);
    expect(s.fontWeight, FontWeight.w600);
    expect(s.fontVariations!.where((v) => v.axis == 'wght').single.value, 600);
    expect(s.fontVariations!.where((v) => v.axis == 'opsz'), hasLength(1));
  });
}
