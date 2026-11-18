// 3.0 restyle: cards, badges and chips, feedback, tabs and small navigation,
// and the app shell — the behaviour the look depends on.
import 'dart:ui' show PointerDeviceKind;

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
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
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: density == null ? child : AerosDensityScope(density: density, child: child),
          ),
        ),
      ),
    );

double _wght(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.fontVariations!.firstWhere((v) => v.axis == 'wght').value;

/// Every BoxDecoration with a shadow at or below [root].
Iterable<BoxDecoration> _shadowed(WidgetTester tester, Finder root) sync* {
  for (final box in tester.widgetList<DecoratedBox>(find.descendant(of: root, matching: find.byType(DecoratedBox)))) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration && (decoration.boxShadow?.isNotEmpty ?? false)) yield decoration;
  }
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

List<AerosNavItem> _navItems() => [
      AerosNavItem(label: 'Home', icon: Icons.home_outlined, onTap: () {}),
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: () {}, selected: true, count: 4),
      AerosNavItem(
        label: 'Catalogue',
        icon: Icons.inventory_2_outlined,
        section: 'Selling',
        children: [AerosNavItem(label: 'Products', onTap: () {})],
      ),
    ];

void main() {
  group('cards', () {
    testWidgets('a card is flat: a hairline, the surface radius and no shadow — raised included', (tester) async {
      for (final variant in AerosCardVariant.values) {
        await tester.pumpWidget(_app(
          SizedBox(width: 300, child: AerosCard(variant: variant, title: 'Order', child: const Text('Body'))),
        ));
        final surface = tester.widget<AerosSurface>(find.byType(AerosSurface));
        expect(surface.level, AerosSurfaceLevel.flat);
        expect(surface.radius, BorderRadius.circular(AerosShapeTokens.surface));
        expect(_shadowed(tester, find.byType(AerosCard)), isEmpty);
      }
    });

    testWidgets('the footer has no fill of its own', (tester) async {
      await tester.pumpWidget(_app(
        const SizedBox(width: 300, child: AerosCard(footer: Text('Footer'), child: Text('Body'))),
      ));
      final footer = tester.widget<Container>(
        find.ancestor(of: find.text('Footer'), matching: find.byType(Container)).first,
      );
      final decoration = footer.decoration! as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.border!.top.color, AerosAliasColors.light.borderDefault);
      expect(decoration.border!.top.width, AerosMetricTokens.borderHairline);
    });

    testWidgets('a tappable card is one button: hover strengthens the hairline, Enter activates', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(
        SizedBox(width: 300, child: AerosCard(onTap: () => taps++, child: const Text('Body'))),
      ));
      const a = AerosAliasColors.light;
      AerosSurface surface() => tester.widget<AerosSurface>(find.byType(AerosSurface));
      expect(surface().borderColor, a.borderDefault);
      expect(surface().color, a.bgSurface);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Body')));
      await tester.pump();
      expect(surface().borderColor, a.borderStrong);
      expect(surface().color, Color.alphaBlend(a.stateHover, a.bgSurface));

      await tester.tap(find.text('Body'));
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(tester.widget<AerosFocusRing>(find.byType(AerosFocusRing)).focused, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 2);
      // Nothing ripples.
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a stat card says which way the number moved, in words', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SizedBox(
        width: 240,
        child: AerosStatCard(label: 'Orders', value: '1,284', delta: '+12.4%', deltaDirection: AerosDelta.up),
      )));
      final label = tester.getSemantics(find.byType(AerosStatCard)).label;
      expect(label, contains('Orders'));
      expect(label, contains('1,284'));
      expect(label, contains('up +12.4%'));
      expect(_shadowed(tester, find.byType(AerosStatCard)), isEmpty);

      await tester.pumpWidget(_app(const SizedBox(
        width: 240,
        child: AerosStatCard(label: 'Returns', value: '37', delta: '-3.1%', deltaDirection: AerosDelta.down),
      )));
      expect(tester.getSemantics(find.byType(AerosStatCard)).label, contains('down -3.1%'));

      await tester.pumpWidget(_app(const SizedBox(
        width: 240,
        child: AerosStatCard(
          label: 'Open RFQs',
          value: '18',
          delta: '0.0%',
          deltaSemanticLabel: 'unchanged since last week',
        ),
      )));
      expect(tester.getSemantics(find.byType(AerosStatCard)).label, contains('unchanged since last week'));
      handle.dispose();
    });

    testWidgets('a stat card value is a type role, not a resized one', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(width: 240, child: AerosStatCard(label: 'Orders', value: '12'))));
      expect(tester.widget<Text>(find.text('12')).style!.fontSize, AerosTypography.h1().fontSize);
      await tester.pumpWidget(
        _app(const SizedBox(width: 240, child: AerosStatCard(label: 'Orders', value: '12', mono: true))),
      );
      expect(tester.widget<Text>(find.text('12')).style!.fontSize, AerosTypography.monoLg().fontSize);
    });

    testWidgets('an empty state title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SizedBox(width: 320, child: AerosEmptyState(title: 'No orders yet'))));
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.text('No orders yet')), containsSemantics(isHeader: true));
      handle.dispose();
    });

    testWidgets('an intent card announces its selection', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(SizedBox(
        width: 320,
        child: AerosIntentCard(title: 'Sell on Aeros', subtitle: 'List products', selected: true, onTap: () {}),
      )));
      expect(
        tester.getSemantics(find.byType(AerosIntentCard)),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, isSelected: true, hasTapAction: true),
      );
      handle.dispose();
    });
  });

  group('badges and chips', () {
    testWidgets('a count badge shrink-wraps inside a Wrap', (tester) async {
      await tester.pumpWidget(_app(
        const SizedBox(
          width: 400,
          child: Wrap(children: [AerosCountBadge(count: 3), AerosCountBadge(count: 120)]),
        ),
        density: AerosDensity.pointer,
      ));
      final badges = find.byType(AerosCountBadge);
      final h = AerosSizeTokens.pointer.badge;
      // Each is as wide as its own text and padding (the test font is a wide
      // one), nowhere near the 400 the Wrap offers.
      expect(tester.getSize(badges.at(0)).height, h);
      expect(tester.getSize(badges.at(0)).width, inInclusiveRange(h, h * 1.5));
      expect(tester.getSize(badges.at(1)).width, lessThan(h * 3));
      expect(tester.getSize(badges.at(1)).width, greaterThan(tester.getSize(badges.at(0)).width));
      // Side by side on one run, not one per row.
      expect(tester.getTopLeft(badges.at(1)).dy, tester.getTopLeft(badges.at(0)).dy);
    });

    testWidgets('a count badge also shrink-wraps in a stretching Column', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [AerosCountBadge(count: 7)],
        ),
      )));
      final h = AerosSizeTokens.touch.badge;
      expect(tester.getSize(find.byType(AerosCountBadge)).height, h);
      expect(tester.getSize(find.byType(AerosCountBadge)).width, inInclusiveRange(h, h * 1.5));
    });

    testWidgets('badge, tag and count badge are one height per density', (tester) async {
      for (final density in AerosDensity.values) {
        await tester.pumpWidget(_app(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [AerosBadge(label: 'Paid'), AerosTag(label: 'RFQ'), AerosCountBadge(count: 2)],
          ),
          density: density,
        ));
        final h = density.sizes.badge;
        expect(tester.getSize(find.byType(AerosBadge)).height, h);
        expect(tester.getSize(find.byType(AerosTag)).height, h);
        expect(tester.getSize(find.byType(AerosCountBadge)).height, h);
      }
    });

    testWidgets('a badge is a pill and a tag is not; both carry a hairline in the tone colour', (tester) async {
      await tester.pumpWidget(_app(const Row(
        mainAxisSize: MainAxisSize.min,
        children: [AerosBadge(label: 'Paid', tone: AerosBadgeTone.success), AerosTag(label: 'RFQ')],
      )));
      BoxDecoration decorationOf(Type type) => tester
          .widget<Container>(find.descendant(of: find.byType(type), matching: find.byType(Container)).first)
          .decoration! as BoxDecoration;

      final badge = decorationOf(AerosBadge);
      expect(badge.borderRadius, BorderRadius.circular(AerosShapeTokens.pill));
      expect(badge.color, AerosSemanticColors.light.successBg);
      expect((badge.border! as Border).top.color, AerosSemanticColors.light.successBorder);
      expect((badge.border! as Border).top.width, AerosMetricTokens.borderHairline);

      final tag = decorationOf(AerosTag);
      expect(tag.borderRadius, BorderRadius.circular(AerosShapeTokens.item));
      expect((tag.border! as Border).top.color, AerosAliasColors.light.borderDefault);
      expect(tester.widget<Text>(find.text('RFQ')).style!.fontSize, AerosTypography.labelXs().fontSize);
    });

    testWidgets('a removable tag fires onRemove from a hit area of at least the minimum target', (tester) async {
      for (final density in AerosDensity.values) {
        var removed = 0;
        await tester.pumpWidget(_app(AerosTag(label: 'launch', onRemove: () => removed++), density: density));
        final min = density.sizes.minTarget;
        final target = tester.getRect(find.byType(AerosTag));
        expect(target.height, greaterThanOrEqualTo(min));
        expect(target.width, greaterThanOrEqualTo(min));
        // The tag itself keeps the badge height, centred in the target.
        expect(tester.getSize(find.text('launch')).height, lessThan(density.sizes.badge));

        // The very edge of the target — outside the painted tag at touch.
        await tester.tapAt(target.topCenter + const Offset(0, 1));
        expect(removed, 1);
        await tester.tap(find.byIcon(Icons.close));
        expect(removed, 2);
      }
    });

    testWidgets('a removable tag meets the 48dp guideline and is named for what it does', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosTag(label: 'launch', onRemove: () {})));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      expect(find.bySemanticsLabel('Remove launch'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a filter chip hover changes the fill only, with no ink', (tester) async {
      await tester.pumpWidget(_app(AerosFilterChip(label: 'All', onTap: () {}), density: AerosDensity.pointer));
      const a = AerosAliasColors.light;
      AerosStateFill fill() => tester.widget<AerosStateFill>(
            find.descendant(of: find.byType(AerosFilterChip), matching: find.byType(AerosStateFill)),
          );
      final rest = tester.getRect(find.byType(AerosFilterChip));
      expect(fill().borderColor, a.borderDefault);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('All')));
      await tester.pump();
      expect(fill().color, Color.alphaBlend(a.stateHover, a.bgSubtle));
      expect(tester.getRect(find.byType(AerosFilterChip)), rest);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(InkResponse), findsNothing);
    });
  });

  group('feedback', () {
    testWidgets('a determinate progress bar builds with semantics on and exposes its value', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(
        const SizedBox(width: 300, child: AerosProgress(value: 0.35, label: 'Uploading artwork')),
      ));
      expect(tester.takeException(), isNull);
      final data = tester.getSemantics(find.byType(LinearProgressIndicator)).getSemanticsData();
      expect(data.label, 'Uploading artwork');
      // A bare number between min and max — what a progress bar must report.
      expect(data.value, '35');
      expect(double.parse(data.minValue!), 0);
      expect(double.parse(data.maxValue!), 100);
      // The visible "35%" is not announced a second time.
      expect(find.bySemanticsLabel('35%'), findsNothing);
      handle.dispose();
    });

    testWidgets('progress clamps out-of-range values instead of throwing', (tester) async {
      final handle = tester.ensureSemantics();
      for (final (value, announced) in [(-0.5, '0'), (0.0, '0'), (1.0, '100'), (7.0, '100')]) {
        await tester.pumpWidget(_app(SizedBox(width: 300, child: AerosProgress(value: value, label: 'Sync'))));
        expect(tester.takeException(), isNull);
        expect(tester.getSemantics(find.byType(LinearProgressIndicator)).getSemanticsData().value, announced);
      }
      handle.dispose();
    });

    testWidgets('the progress track is the 4px pill', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(width: 300, child: AerosProgress(value: 0.5))));
      expect(tester.getSize(find.byType(LinearProgressIndicator)).height, AerosProgress.trackHeight);
      expect(AerosProgress.trackHeight, 4);
      expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).borderRadius,
        BorderRadius.circular(AerosShapeTokens.pill),
      );
    });

    testWidgets('a stepper is a named progress bar', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(
        const SizedBox(width: 300, child: AerosStepper(currentStep: 2, totalSteps: 5, label: 'Tax details')),
      ));
      expect(tester.takeException(), isNull);
      final data = tester.getSemantics(find.byType(LinearProgressIndicator)).getSemanticsData();
      expect(data.label, 'Step 2 of 5 — Tax details');
      expect(data.value, '40');
      handle.dispose();
    });

    testWidgets('an alert is a tinted hairline box with a labelSm title and a bodySm body', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(
        width: 320,
        child: AerosAlert(tone: AerosAlertTone.danger, title: 'Payment failed', body: 'Try another card.'),
      )));
      final decoration = tester
          .widget<Container>(find.descendant(of: find.byType(AerosAlert), matching: find.byType(Container)))
          .decoration! as BoxDecoration;
      const s = AerosSemanticColors.light;
      expect(decoration.color, s.dangerBg);
      expect(decoration.borderRadius, BorderRadius.circular(AerosShapeTokens.surface));
      expect((decoration.border! as Border).top.color, s.dangerBorder);
      expect(decoration.boxShadow, isNull);
      expect(tester.widget<Text>(find.text('Payment failed')).style!.fontSize, AerosTypography.labelSm().fontSize);
      expect(tester.widget<Text>(find.text('Try another card.')).style!.fontSize, AerosTypography.bodySm().fontSize);
    });

    testWidgets('a snackbar is an elevated surface; the tone colours the message, not the slab', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(key: Key('anchor'))));
      var undone = 0;
      AerosSnackbar.show(
        tester.element(find.byKey(const Key('anchor'))),
        'Order archived',
        description: 'It moved to the archive.',
        tone: AerosSnackbarTone.success,
        actionLabel: 'Undo',
        onAction: () => undone++,
      );
      await tester.pumpAndSettle();

      final surface = tester.widget<AerosSurface>(
        find.descendant(of: find.byType(SnackBar), matching: find.byType(AerosSurface)),
      );
      expect(surface.level, AerosSurfaceLevel.overlay);
      expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor, Colors.transparent);
      expect(tester.widget<Text>(find.text('Order archived')).style!.color, AerosSemanticColors.light.successText);
      expect(
        tester.widget<Text>(find.text('It moved to the archive.')).style!.color,
        AerosAliasColors.light.fgSecondary,
      );

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(undone, 1);
      expect(find.text('Order archived'), findsNothing);
    });
  });

  group('tabs and small navigation', () {
    for (final variant in AerosTabVariant.values) {
      testWidgets('${variant.name} tabs: the active label is heavier; tap and arrows select', (tester) async {
        var selected = 0;
        await tester.pumpWidget(_app(StatefulBuilder(
          builder: (context, setState) => AerosTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: selected,
            variant: variant,
            onChanged: (i) => setState(() => selected = i),
          ),
        )));
        expect(_wght(tester, 'Day'), greaterThan(_wght(tester, 'Week')));
        expect(_wght(tester, 'Day'), 600);

        await tester.tap(find.text('Month'));
        await tester.pump();
        expect(selected, 2);
        expect(_wght(tester, 'Month'), greaterThan(_wght(tester, 'Day')));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(selected, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 2);
        // Stops at the ends.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 2);
      });

      testWidgets('${variant.name} tabs: Tab shows a focus ring and Enter activates the focused tab', (tester) async {
        var selected = 2;
        await tester.pumpWidget(_app(StatefulBuilder(
          builder: (context, setState) => AerosTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: selected,
            variant: variant,
            onChanged: (i) => setState(() => selected = i),
          ),
        )));
        bool ringOn(String tab) => tester
            .widget<AerosFocusRing>(find.ancestor(of: find.text(tab), matching: find.byType(AerosFocusRing)).first)
            .focused;
        expect(ringOn('Day'), isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(ringOn('Day'), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(selected, 0);
        expect(find.byType(InkWell), findsNothing);
      });
    }

    testWidgets('arrow keys follow the reading direction', (tester) async {
      var selected = 1;
      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (context, setState) => AerosTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
        direction: TextDirection.rtl,
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // In right-to-left the next tab is on the left.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(selected, 2);
    });

    testWidgets('a tab is announced as a selected button in a group', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosTabs(tabs: const ['Day', 'Week'], selectedIndex: 0, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.text('Day')),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, isSelected: true, isInMutuallyExclusiveGroup: true, hasTapAction: true),
      );
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.text('Week')), containsSemantics(isButton: true, isSelected: false));
      handle.dispose();
    });

    testWidgets('underline tabs: a 1px baseline and a 2px indicator; pill tabs lift the active segment', (tester) async {
      await tester.pumpWidget(_app(
        SizedBox(width: 400, child: AerosTabs(tabs: const ['Day', 'Week'], selectedIndex: 0, onChanged: (_) {})),
        density: AerosDensity.pointer,
      ));
      const a = AerosAliasColors.light;
      final bars = tester.widgetList<ColoredBox>(
        find.descendant(of: find.byType(AerosTabs), matching: find.byType(ColoredBox)),
      );
      expect(bars.map((b) => b.color), containsAll([a.borderDefault, a.fgPrimary]));
      final strip = tester.getRect(find.byType(AerosTabs));
      expect(strip.height, AerosSizeTokens.pointer.row);
      final sizes = [
        for (final e in find.descendant(of: find.byType(AerosTabs), matching: find.byType(ColoredBox)).evaluate())
          (e.widget as ColoredBox, tester.getRect(find.byWidget(e.widget))),
      ];
      final baseline = sizes.firstWhere((s) => s.$1.color == a.borderDefault).$2;
      final indicator = sizes.firstWhere((s) => s.$1.color == a.fgPrimary).$2;
      expect(baseline.height, AerosMetricTokens.borderHairline);
      expect(baseline.width, strip.width);
      expect(indicator.height, AerosMetricTokens.borderThick);
      // Both sit on the bottom edge: the indicator covers the baseline.
      expect(baseline.bottom, strip.bottom);
      expect(indicator.bottom, strip.bottom);

      await tester.pumpWidget(_app(
        AerosTabs(tabs: const ['Day', 'Week'], selectedIndex: 0, onChanged: (_) {}, variant: AerosTabVariant.pill),
        density: AerosDensity.pointer,
      ));
      expect(tester.getSize(find.byType(AerosTabs)).height, AerosSizeTokens.pointer.controlMd);
      final active = tester.widget<AerosSurface>(
        find.ancestor(of: find.text('Day'), matching: find.byType(AerosSurface)),
      );
      expect(active.level, AerosSurfaceLevel.raised);
      expect(find.ancestor(of: find.text('Week'), matching: find.byType(AerosSurface)), findsNothing);
    });

    testWidgets('pagination buttons are one control high; the arrows are named and disable at the ends',
        (tester) async {
      final handle = tester.ensureSemantics();
      var page = 1;
      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (context, setState) => AerosPagination(
            page: page,
            totalPages: 3,
            variant: AerosPaginationVariant.numbered,
            onChanged: (p) => setState(() => page = p),
          ),
        ),
        density: AerosDensity.pointer,
      ));
      final side = AerosControlSize.sm.heightFor(AerosDensity.pointer);
      for (final fill in find
          .descendant(of: find.byType(AerosPagination), matching: find.byType(AerosStateFill))
          .evaluate()) {
        expect(tester.getSize(find.byWidget(fill.widget)).height, side);
      }
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.bySemanticsLabel('Previous page')), containsSemantics(isEnabled: false));
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.bySemanticsLabel('Page 1')), containsSemantics(isSelected: true));

      await tester.tap(find.text('3'));
      await tester.pump();
      expect(page, 3);
      await tester.tap(find.bySemanticsLabel('Previous page'));
      await tester.pump();
      expect(page, 2);
      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pump();
      expect(page, 3);
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.bySemanticsLabel('Next page')), containsSemantics(isEnabled: false));
      handle.dispose();
    });

    testWidgets('a breadcrumb link is a button; the current page is not', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(_app(AerosBreadcrumb(items: [
        AerosBreadcrumbItem('Orders', onTap: () => taps++),
        AerosBreadcrumbItem('#4821', onTap: () => taps += 10),
      ])));
      await tester.tap(find.text('Orders'));
      await tester.tap(find.text('#4821'), warnIfMissed: false);
      expect(taps, 1);
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.text('Orders')), containsSemantics(isButton: true, hasTapAction: true));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('avatars follow the token ladder with a 1px border', (tester) async {
      await tester.pumpWidget(_app(Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final size in AerosAvatarSize.values) AerosAvatar(initials: 'PP', size: size)],
      )));
      expect(
        [for (var i = 0; i < 5; i++) tester.getSize(find.byType(AerosAvatar).at(i)).width],
        [
          AerosSizeTokens.avatarXs,
          AerosSizeTokens.avatarSm,
          AerosSizeTokens.avatarMd,
          AerosSizeTokens.avatarLg,
          AerosSizeTokens.avatarXl,
        ],
      );
      expect([for (final size in AerosAvatarSize.values) size.dimension], [20, 24, 32, 40, 56]);
      final decoration = tester
          .widget<Container>(find.descendant(of: find.byType(AerosAvatar).first, matching: find.byType(Container)))
          .decoration! as BoxDecoration;
      expect((decoration.border! as Border).top.width, AerosMetricTokens.borderHairline);
    });
  });

  group('shell', () {
    Widget shell({double? scopeWidth, AerosSidenav? sidenav, AerosDensity? density}) {
      Widget scaffold = AerosScaffold(
        topnav: const AerosTopnav(title: 'Dashboard'),
        sidenav: sidenav ??
            AerosSidenav(
              header: const AerosSidenavHeader(title: 'Boson Machines'),
              items: _navItems(),
            ),
        body: const Text('Body'),
      );
      if (density != null) scaffold = AerosDensityScope(density: density, child: scaffold);
      return MaterialApp(
        theme: AerosTheme.light(),
        home: scopeWidth == null ? scaffold : AerosViewportScope(width: scopeWidth, child: scaffold),
      );
    }

    testWidgets('the sidenav is inline from the md breakpoint and a drawer below it', (tester) async {
      expect(const AerosScaffold(body: SizedBox()).sidenavBreakpoint, AerosBreakpoints.md);
      expect(AerosBreakpoints.md, 768);

      _setView(tester, const Size(AerosBreakpoints.md, 700));
      await tester.pumpWidget(shell());
      expect(find.byType(AerosSidenav), findsOneWidget);
      expect(tester.getSize(find.byType(AerosSidenav)).width,
          AerosMetricTokens.layoutSidebar - AerosMetricTokens.borderHairline);
      expect(tester.firstState<ScaffoldState>(find.byType(Scaffold)).hasDrawer, isFalse);

      _setView(tester, const Size(AerosBreakpoints.md - 1, 700));
      await tester.pumpWidget(shell());
      await tester.pump();
      expect(find.byType(AerosSidenav), findsNothing);
      final state = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      expect(state.hasDrawer, isTrue);
      state.openDrawer();
      await tester.pumpAndSettle();
      expect(find.byType(AerosSidenav), findsOneWidget);
      expect(tester.getSize(find.byType(Drawer)).width, AerosMetricTokens.layoutSidebarMobile);
    });

    testWidgets('the breakpoint reads AerosViewportScope before MediaQuery', (tester) async {
      // A phone-sized MediaQuery (a web shell's ScreenUtil clamp) inside a desktop viewport.
      _setView(tester, const Size(480, 700));
      await tester.pumpWidget(shell(scopeWidth: 1280));
      expect(find.byType(AerosSidenav), findsOneWidget);
      expect(tester.firstState<ScaffoldState>(find.byType(Scaffold)).hasDrawer, isFalse);

      // And the other way round: a wide window whose real viewport is narrow.
      _setView(tester, const Size(1280, 700));
      await tester.pumpWidget(shell(scopeWidth: 480));
      await tester.pump();
      expect(find.byType(AerosSidenav), findsNothing);
      expect(tester.firstState<ScaffoldState>(find.byType(Scaffold)).hasDrawer, isTrue);
    });

    testWidgets('topnav, sidenav header and page header share one header height per density', (tester) async {
      for (final density in AerosDensity.values) {
        _setView(tester, const Size(1280, 700));
        await tester.pumpWidget(MaterialApp(
          theme: AerosTheme.light(),
          home: AerosDensityScope(
            density: density,
            child: AerosScaffold(
              topnav: const AerosTopnav(title: 'Orders'),
              sidenav: AerosSidenav(
                header: const AerosSidenavHeader(title: 'Boson Machines'),
                footer: const AerosSidenavFooter(name: 'Parth'),
                items: _navItems(),
              ),
              body: const Align(alignment: Alignment.topLeft, child: AerosPageHeader(title: 'Orders')),
            ),
          ),
        ));
        final header = density.sizes.header;
        expect(tester.getSize(find.byType(AerosTopnav)).height, header);
        expect(tester.getSize(find.byType(AerosSidenavHeader)).height, header);
        expect(tester.getSize(find.byType(AerosSidenavFooter)).height, header);
        expect(tester.getSize(find.byType(AerosPageHeader)).height, header);
        // The page header starts level with the rail's header block.
        expect(tester.getTopLeft(find.byType(AerosPageHeader)).dy, tester.getTopLeft(find.byType(AerosSidenavHeader)).dy);
      }
      expect((AerosSizeTokens.pointer.header, AerosSizeTokens.touch.header), (48, 56));
    });

    testWidgets('the topnav title is h4', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(width: 400, child: AerosTopnav(title: 'Orders'))));
      final style = tester.widget<Text>(find.text('Orders')).style!;
      expect(style.fontSize, AerosTypography.h4().fontSize);
      expect(style.fontWeight, AerosTypography.h4().fontWeight);
    });

    testWidgets('the selected nav row is announced as a selected button, with its count', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(SizedBox(width: 240, height: 400, child: AerosSidenav(items: _navItems()))));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Orders, 4')),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, isSelected: true, hasTapAction: true, isFocusable: true),
      );
      // ignore: deprecated_member_use
      expect(tester.getSemantics(find.bySemanticsLabel('Home')), containsSemantics(isButton: true, isSelected: false));
      // A parent says whether it is open.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Catalogue')),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
      );
      handle.dispose();
    });

    testWidgets('nav rows answer the keyboard: a focus ring on Tab, Enter activates, no ink', (tester) async {
      var opened = 0;
      await tester.pumpWidget(_app(SizedBox(
        width: 240,
        height: 400,
        child: AerosSidenav(items: [AerosNavItem(label: 'Home', icon: Icons.home_outlined, onTap: () => opened++)]),
      )));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .widget<AerosFocusRing>(find.ancestor(of: find.text('Home'), matching: find.byType(AerosFocusRing)).first)
            .focused,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(opened, 1);
      expect(find.byType(InkWell), findsNothing);
      final fill = tester.widget<AerosStateFill>(
        find.ancestor(of: find.text('Home'), matching: find.byType(AerosStateFill)).first,
      );
      expect(fill.radius, BorderRadius.circular(AerosShapeTokens.item));
    });

    testWidgets('a collapsed sidenav is the 56px rail: icons only, labels still announced', (tester) async {
      final handle = tester.ensureSemantics();
      _setView(tester, const Size(1280, 700));
      var expand = 0;
      await tester.pumpWidget(shell(
        sidenav: AerosSidenav(
          collapsed: true,
          onExpandRequested: () => expand++,
          header: const AerosSidenavHeader(title: 'Boson Machines'),
          footer: AerosSidenavFooter(name: 'Parth', actionIcon: Icons.logout, actionLabel: 'Sign out', onAction: () {}),
          items: _navItems(),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AerosSidenav)).width,
          AerosMetricTokens.layoutSidebarRail - AerosMetricTokens.borderHairline);
      expect(find.text('Orders'), findsNothing);
      expect(find.text('Selling'), findsNothing);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.bySemanticsLabel('Orders, 4'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsNothing);

      // A parent cannot show its children here: it asks the rail to open.
      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      expect(expand, 1);
      handle.dispose();
    });

    testWidgets('a collapsed sidenav is shown in full inside the drawer', (tester) async {
      _setView(tester, const Size(390, 800));
      await tester.pumpWidget(shell(sidenav: AerosSidenav(collapsed: true, items: _navItems())));
      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Selling'), findsOneWidget);
    });
  });

  group('right-to-left', () {
    final scenes = <String, Widget Function()>{
      'cards': () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AerosCard(
                title: 'Order',
                subtitle: 'Placed today',
                trailing: const AerosBadge(label: 'Paid', tone: AerosBadgeTone.success),
                footer: const Text('Footer'),
                onTap: () {},
                child: const Text('Body'),
              ),
              const AerosStatCard(label: 'Orders', value: '12', delta: '+1%', deltaDirection: AerosDelta.up),
              AerosIntentCard(title: 'Buy', subtitle: 'Browse', icon: Icons.shop, badge: 'New', onTap: () {}),
              const AerosEmptyState(icon: Icons.inbox, title: 'Nothing', description: 'Nothing here yet.'),
            ],
          ),
      'badges and chips': () => Wrap(
            children: [
              for (final tone in AerosBadgeTone.values) AerosBadge(label: tone.name, tone: tone),
              for (final tone in AerosTagTone.values) AerosTag(label: tone.name, tone: tone, onRemove: () {}),
              const AerosTag(label: 'pill', pill: true),
              const AerosCountBadge(count: 120),
              AerosFilterChip(
                label: 'Stage',
                selected: true,
                count: 3,
                leadingIcon: Icons.flag,
                dropdown: true,
                onTap: () {},
                onClear: () {},
              ),
              AerosFilterChip(label: 'Late', tone: AerosFilterChipTone.warning, onTap: () {}),
              AerosEnumChips(
                label: 'Size',
                required: true,
                selectedId: 'a',
                onChanged: (_) {},
                options: const [
                  AerosAttributeOption(id: 'a', label: 'A'),
                  AerosAttributeOption(id: 'b', label: 'B', disabled: true, disabledReason: 'Out of stock'),
                ],
              ),
              AerosRoutingSignalBadge(
                signal: const AerosRoutingSignal(kind: 'RFQ', label: 'Quote required'),
                onTap: () {},
              ),
              const AerosRoutingSignalBadge(
                dense: true,
                signal: AerosRoutingSignal(kind: 'MTO', label: 'Made to order', severity: AerosRoutingSeverity.warn),
              ),
            ],
          ),
      'feedback': () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tone in AerosAlertTone.values) AerosAlert(tone: tone, title: 'Title', body: 'Body'),
              AerosConstraintErrorAlert(
                messageByLocale: const {'en': 'Too thin'},
                locale: 'en',
                onResolve: () {},
                resolveLabel: 'Fix',
                onDismiss: () {},
              ),
              const AerosProgress(value: 0.4, label: 'Uploading'),
              const AerosTooltip(message: 'Copy', child: Icon(Icons.link)),
            ],
          ),
      'tabs and navigation': () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AerosTabs(tabs: const ['Day', 'Week'], selectedIndex: 0, onChanged: (_) {}),
              AerosTabs(tabs: const ['Day', 'Week'], selectedIndex: 1, onChanged: (_) {}, variant: AerosTabVariant.pill),
              AerosBreadcrumb(items: [AerosBreadcrumbItem('Orders', onTap: () {}), const AerosBreadcrumbItem('#1')]),
              AerosPagination(page: 2, totalPages: 9, onChanged: (_) {}),
              AerosPagination(page: 5, totalPages: 9, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
              const AerosStepper(currentStep: 1, totalSteps: 3, label: 'Details'),
              const AerosAvatar(initials: 'PP'),
              AerosPageHeader(
                title: 'Orders',
                subtitle: '128 orders',
                breadcrumbs: [AerosBreadcrumbItem('Home', onTap: () {}), const AerosBreadcrumbItem('Orders')],
                leading: const Icon(Icons.arrow_back),
                actions: [AerosButton(label: 'Add', onPressed: () {})],
              ),
            ],
          ),
    };

    for (final entry in scenes.entries) {
      testWidgets('${entry.key} build and lay out without error', (tester) async {
        final handle = tester.ensureSemantics();
        _setView(tester, const Size(900, 1400));
        for (final density in AerosDensity.values) {
          await tester.pumpWidget(_app(
            SizedBox(width: 640, child: SingleChildScrollView(child: entry.value())),
            direction: TextDirection.rtl,
            density: density,
          ));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull, reason: '${entry.key} at ${density.name}');
        }
        handle.dispose();
      });
    }

    testWidgets('the shell builds mirrored: the rail sits on the right', (tester) async {
      final handle = tester.ensureSemantics();
      _setView(tester, const Size(1280, 700));
      for (final collapsed in [false, true]) {
        await tester.pumpWidget(MaterialApp(
          theme: AerosTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AerosScaffold(
              topnav: const AerosTopnav(title: 'Orders', leading: Icon(Icons.menu), actions: [Icon(Icons.search)]),
              sidenav: AerosSidenav(
                collapsed: collapsed,
                header: AerosSidenavHeader(title: 'Boson Machines', subtitle: 'Seller', onTap: () {}),
                footer: AerosSidenavFooter(
                  name: 'Parth',
                  subtitle: 'Owner',
                  actionIcon: Icons.logout,
                  actionLabel: 'Sign out',
                  onAction: () {},
                ),
                items: _navItems(),
              ),
              body: const Text('Body'),
            ),
          ),
        ));
        expect(tester.takeException(), isNull);
        expect(tester.getTopRight(find.byType(AerosSidenav)).dx, 1280);
      }
      handle.dispose();
    });

    testWidgets('a snackbar shows in right-to-left', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(key: Key('anchor')), direction: TextDirection.rtl));
      AerosSnackbar.show(
        tester.element(find.byKey(const Key('anchor'))),
        'Saved',
        tone: AerosSnackbarTone.success,
        actionLabel: 'Undo',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Saved'), findsOneWidget);
    });
  });
}
