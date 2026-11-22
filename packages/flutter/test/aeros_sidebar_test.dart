// The uniform sidebar (docs/sidebar/spec.md): three presentations, the 28px
// centre line, the remembered choice, the shortcut, the rail menu.
import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _rail = AerosMetricTokens.layoutSidebarRail - AerosMetricTokens.borderHairline;
const _full = AerosMetricTokens.layoutSidebar - AerosMetricTokens.borderHairline;

void main() {
  final chosen = <String>[];
  setUp(chosen.clear);

  List<AerosNavItem> items({String selected = 'Dashboard'}) => [
        AerosNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selected: selected == 'Dashboard',
          onTap: () => chosen.add('Dashboard'),
        ),
        AerosNavItem(label: 'Inbox', icon: Icons.inbox_outlined, count: 4, onTap: () => chosen.add('Inbox')),
        AerosNavItem(
          label: 'Catalogue',
          icon: Icons.inventory_2_outlined,
          children: [
            AerosNavItem(label: 'Products', selected: selected == 'Products', onTap: () => chosen.add('Products')),
            AerosNavItem(label: 'Collections', onTap: () => chosen.add('Collections')),
          ],
        ),
      ];

  Widget shell({
    AerosSidebarController? controller,
    AerosDensity density = AerosDensity.pointer,
    String selected = 'Dashboard',
    Widget body = const Text('Body'),
  }) =>
      MaterialApp(
        theme: AerosTheme.light(),
        home: AerosDensityScope(
          density: density,
          child: AerosScaffold(
            sidebarController: controller,
            topnav: const AerosTopnav(title: 'Dashboard'),
            sidenav: AerosSidenav(
              header: const AerosSidenavHeader(title: 'Aeros'),
              footer: const AerosSidenavFooter(name: 'Meera Shah'),
              items: items(selected: selected),
            ),
            body: body,
          ),
        ),
      );

  double navWidth(WidgetTester tester) => tester.getSize(find.byType(AerosSidenav)).width;
  AerosScaffoldState state(WidgetTester tester) => tester.state<AerosScaffoldState>(find.byType(AerosScaffold));

  group('the 28px centre line', () {
    for (final density in AerosDensity.values) {
      testWidgets('icons, mark and avatar stay centred 28px in, expanded and collapsed · ${density.name}',
          (tester) async {
        _setView(tester, const Size(1280, 800));
        final controller = AerosSidebarController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(shell(controller: controller, density: density));

        void expectOnLine() {
          expect(tester.getCenter(find.byIcon(Icons.dashboard_outlined)).dx, 28);
          expect(tester.getCenter(find.byIcon(Icons.inventory_2_outlined)).dx, 28);
          expect(tester.getCenter(find.byType(AerosSidenavMark)).dx, 28);
          expect(tester.getCenter(find.byType(AerosAvatar)).dx, 28);
        }

        expect(navWidth(tester), _full);
        expectOnLine();
        final rowTop = tester.getTopLeft(find.byIcon(Icons.inventory_2_outlined)).dy;

        controller.toggle();
        await tester.pumpAndSettle();
        expect(navWidth(tester), _rail);
        expectOnLine();
        // Rows keep their vertical positions too.
        expect(tester.getTopLeft(find.byIcon(Icons.inventory_2_outlined)).dy, rowTop);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the width animates and nothing overflows on the way', (tester) async {
      _setView(tester, const Size(1280, 800));
      final controller = AerosSidebarController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller));
      controller.toggle();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final body = tester.getTopLeft(find.text('Body')).dx;
      expect(body, greaterThan(AerosMetricTokens.layoutSidebarRail));
      expect(body, lessThan(AerosMetricTokens.layoutSidebar));
      expect(tester.getCenter(find.byIcon(Icons.dashboard_outlined)).dx, 28);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Body')).dx, AerosMetricTokens.layoutSidebarRail);
    });
  });

  group('AerosSidebarController', () {
    testWidgets('owns the rail: the top bar button toggles it and the choice is saved', (tester) async {
      _setView(tester, const Size(1280, 800));
      final saved = <bool>[];
      final controller = AerosSidebarController(save: saved.add);
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller));
      expect(state(tester).canToggleRail, isTrue);

      await tester.tap(find.bySemanticsLabel('Collapse sidebar'));
      await tester.pumpAndSettle();
      expect(controller.collapsed, isTrue);
      expect(state(tester).isRailCollapsed, isTrue);
      expect(saved, [true]);

      await tester.tap(find.bySemanticsLabel('Expand sidebar'));
      await tester.pumpAndSettle();
      expect(navWidth(tester), _full);
      expect(saved, [true, false]);
    });

    testWidgets('restores what load returns, unless the user chose first', (tester) async {
      final restored = AerosSidebarController(load: () async => true);
      addTearDown(restored.dispose);
      expect(restored.collapsed, isFalse);
      await tester.pump();
      expect(restored.collapsed, isTrue);

      final touched = AerosSidebarController(load: () async => true);
      addTearDown(touched.dispose);
      touched.collapsed = true;
      touched.collapsed = false;
      await tester.pump();
      expect(touched.collapsed, isFalse);
    });

    testWidgets('Cmd/Ctrl+B toggles, but not while typing in a field', (tester) async {
      _setView(tester, const Size(1280, 800));
      final controller = AerosSidebarController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller, body: const Material(child: TextField())));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(controller.collapsed, isTrue);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(controller.collapsed, isTrue);
    });
  });

  group('between md and lg', () {
    testWidgets('rests as a rail whatever the remembered choice, and floats open without moving the page',
        (tester) async {
      _setView(tester, const Size(820, 1000));
      final saved = <bool>[];
      final controller = AerosSidebarController(save: saved.add);
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller));
      expect(navWidth(tester), _rail);
      expect(state(tester).isSidenavRailOnly, isTrue);
      final bodyX = tester.getTopLeft(find.text('Body')).dx;
      expect(bodyX, AerosMetricTokens.layoutSidebarRail);

      await tester.tap(find.bySemanticsLabel('Expand sidebar'));
      await tester.pumpAndSettle();
      expect(state(tester).isSidenavFloating, isTrue);
      expect(navWidth(tester), _full);
      expect(tester.getTopLeft(find.text('Body')).dx, bodyX);
      // Floating is not the remembered choice.
      expect(saved, isEmpty);
      expect(controller.collapsed, isFalse);
    });

    testWidgets('the floating sidenav closes on Escape, a tap outside, and choosing a destination', (tester) async {
      _setView(tester, const Size(820, 1000));
      await tester.pumpWidget(shell());

      state(tester).toggleRail();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(navWidth(tester), _rail);

      state(tester).toggleRail();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(navWidth(tester), _rail);

      state(tester).toggleRail();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(chosen, ['Inbox']);
      expect(navWidth(tester), _rail);
    });
  });

  group('the drawer', () {
    testWidgets('uses touch rows whatever the app density, and closes when a destination is chosen', (tester) async {
      _setView(tester, const Size(390, 800));
      await tester.pumpWidget(shell());
      state(tester).openDrawer();
      await tester.pumpAndSettle();
      expect(AerosSidenavScope.of(tester.element(find.text('Inbox'))).density, AerosSidenavDensity.touch);
      expect(tester.getCenter(find.byIcon(Icons.dashboard_outlined)).dx, 28);

      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(chosen, ['Inbox']);
      expect(state(tester).isDrawerOpen, isFalse);
    });
  });

  group('the rail', () {
    testWidgets('a parent opens its children in a menu; choosing one navigates', (tester) async {
      _setView(tester, const Size(1280, 800));
      final controller = AerosSidebarController(collapsed: true);
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller));

      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Products'), findsOneWidget);
      await tester.tap(find.text('Collections'));
      await tester.pumpAndSettle();
      expect(chosen, ['Collections']);
      expect(find.byType(AerosMenuList), findsNothing);
      expect(controller.collapsed, isTrue);
    });

    testWidgets('hovering a row names it beside the rail, with its count', (tester) async {
      _setView(tester, const Size(1280, 800));
      final controller = AerosSidebarController(collapsed: true);
      addTearDown(controller.dispose);
      await tester.pumpWidget(shell(controller: controller));
      expect(find.text('Inbox · 4'), findsNothing);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.inbox_outlined)));
      await tester.pumpAndSettle();
      expect(find.text('Inbox · 4'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Inbox · 4')).dx, greaterThan(AerosMetricTokens.layoutSidebarRail));

      await mouse.moveTo(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.text('Inbox · 4'), findsNothing);
    });
  });

  testWidgets('a group opens when the selection moves into it', (tester) async {
    _setView(tester, const Size(1280, 800));
    await tester.pumpWidget(shell());
    expect(find.text('Products'), findsNothing);
    await tester.pumpWidget(shell(selected: 'Products'));
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('a count is a quiet number by default and a pill with countEmphasis', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AerosTheme.light(),
      home: const Material(
        child: SizedBox(
          width: 240,
          child: AerosSidenav(items: [
            AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, count: 128),
            AerosNavItem(label: 'Messages', icon: Icons.chat_outlined, count: 4, countEmphasis: true),
          ]),
        ),
      ),
    ));
    expect(find.text('99+'), findsOneWidget);
    expect(find.byType(AerosCountBadge), findsOneWidget);
  });
}
