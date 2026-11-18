// Pumps the example gallery (example/lib) page by page at a phone and a
// desktop width, in both themes and both densities, and fails on any layout
// overflow or build error. The gallery is the reference usage of every
// widget, so it has to stay working.
import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../example/lib/app.dart';
import '../../example/lib/destinations.dart';

const _sizes = <String, Size>{'phone 390×844': Size(390, 844), 'desktop 1280×800': Size(1280, 800)};

Future<void> _pump(WidgetTester tester, Size size,
    {required String page, ThemeMode theme = ThemeMode.light, AerosDensity density = AerosDensity.pointer}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    GalleryApp(key: UniqueKey(), initialPage: page, initialThemeMode: theme, initialDensity: density),
  );
  // The thinking orb and indeterminate progress never settle.
  await tester.pump(const Duration(milliseconds: 400));
}

/// Two fixed pumps: one to rebuild, one to let state animations finish.
/// (`pumpAndSettle` never returns on a page with the thinking orb.)
Future<void> _rest(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final size in _sizes.entries) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final density in AerosDensity.values) {
        testWidgets('every page lays out · ${size.key} · ${theme.name} · ${density.name}', (tester) async {
          for (final destination in destinations) {
            await _pump(tester, size.value, page: destination.id, theme: theme, density: density);
            expect(tester.takeException(), isNull, reason: destination.id);
            expect(find.byType(AerosScaffold), findsWidgets, reason: destination.id);

            // Scroll to the end, so everything below the fold is built too.
            final scrollable = find.byType(Scrollable).last;
            await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -20000), warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull, reason: '${destination.id}, scrolled');
            expect(scrollable, findsOneWidget);
          }
        });
      }
    }
  }

  testWidgets('desktop: the sidenav is inline, a row opens its page, the rail toggle collapses it', (tester) async {
    await _pump(tester, const Size(1280, 800), page: 'overview');
    expect(find.byType(Drawer), findsNothing);
    // The rail's box, less the hairline that divides it from the page.
    expect(
      tester.getSize(find.byType(AerosSidenav)).width,
      AerosMetricTokens.layoutSidebar - AerosMetricTokens.borderHairline,
    );
    expect(find.byType(AerosWordmark), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav:buttons')));
    await _rest(tester);
    expect(find.text('One primary action per view. Everything else is secondary or ghost.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Collapse sidebar'));
    await _rest(tester);
    expect(
      tester.getSize(find.byType(AerosSidenav)).width,
      AerosMetricTokens.layoutSidebarRail - AerosMetricTokens.borderHairline,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: the sidenav is a drawer; choosing a page closes it', (tester) async {
    await _pump(tester, const Size(390, 844), page: 'buttons');
    expect(find.byType(AerosSidenav), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open navigation'));
    await _rest(tester);
    expect(find.byType(AerosSidenav), findsOneWidget);
    expect(tester.getSize(find.byType(AerosSidenav)).width, AerosMetricTokens.layoutSidebarMobile);

    await tester.tap(find.byKey(const ValueKey('nav:fields')));
    await _rest(tester);
    expect(find.byType(AerosSidenav), findsNothing);
    expect(find.text('One frame for every input: a hairline that stays 1px, and the focus ring.'), findsOneWidget);
  });

  testWidgets('the top bar switches theme and density live', (tester) async {
    await _pump(tester, const Size(1280, 800), page: 'buttons');
    double buttonHeight() => tester.getSize(find.widgetWithText(AerosStateFill, 'Primary')).height;
    expect(buttonHeight(), AerosSizeTokens.pointer.controlMd);

    await tester.tap(find.bySemanticsLabel('Switch to touch density'));
    await _rest(tester);
    expect(buttonHeight(), AerosSizeTokens.touch.controlMd);

    expect(Theme.of(tester.element(find.byType(AerosScaffold))).brightness, Brightness.light);
    await tester.tap(find.bySemanticsLabel('Theme, Light'));
    await _rest(tester);
    await tester.tap(find.text('Dark'));
    await _rest(tester);
    expect(Theme.of(tester.element(find.byType(AerosScaffold))).brightness, Brightness.dark);
  });
}
