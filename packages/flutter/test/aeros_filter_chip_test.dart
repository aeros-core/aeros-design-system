import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double wght(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!.fontVariations!.firstWhere((v) => v.axis == 'wght').value;

  Future<void> pump(WidgetTester tester, Widget chip, {AerosDensity density = AerosDensity.pointer}) =>
      tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(body: Center(child: AerosDensityScope(density: density, child: chip))),
      ));

  Finder pill() => find.descendant(of: find.byType(AerosFilterChip), matching: find.byType(Material)).first;

  testWidgets('the pill is 28px at pointer', (tester) async {
    await pump(tester, AerosFilterChip(label: 'All', onTap: () {}));
    expect(tester.getSize(pill()).height, 28);
    expect(tester.getSize(find.byType(AerosFilterChip)).height, 28);
  });

  testWidgets('at touch the pill is 32px but the tap target is 44px', (tester) async {
    var taps = 0;
    await pump(tester, AerosFilterChip(label: 'All', onTap: () => taps++), density: AerosDensity.touch);
    expect(tester.getSize(pill()).height, 32);
    expect(tester.getSize(find.byType(AerosFilterChip)).height, AerosFilterChip.touchTargetHeight);

    // A tap in the transparent band above the pill still counts.
    final chip = tester.getRect(find.byType(AerosFilterChip));
    await tester.tapAt(Offset(chip.center.dx, chip.top + 3));
    expect(taps, 1);
  });

  testWidgets('selected weight actually renders heavier (wght axis), and fills brandPrimary', (tester) async {
    await pump(tester, AerosFilterChip(label: 'Mine', onTap: () {}));
    expect(wght(tester, 'Mine'), 500);
    expect(tester.widget<Material>(pill()).color, AerosAliasColors.light.bgSubtle);

    await pump(tester, AerosFilterChip(label: 'Mine', selected: true, onTap: () {}));
    expect(wght(tester, 'Mine'), 600);
    expect(tester.widget<Material>(pill()).color, AerosAliasColors.light.brandPrimary);
  });

  testWidgets('counts: plain, floor and the 99+ cap', (tester) async {
    await pump(tester, AerosFilterChip(label: 'Mine', count: 6, countIsFloor: true, onTap: () {}));
    expect(find.text('6+'), findsOneWidget);
    await pump(tester, AerosFilterChip(label: 'Unassigned', count: 3, onTap: () {}));
    expect(find.text('3'), findsOneWidget);
    await pump(tester, AerosFilterChip(label: 'Unassigned', count: 400, onTap: () {}));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('dropdown draws a caret; warning tone is amber at rest', (tester) async {
    await pump(
      tester,
      AerosFilterChip(
        label: 'Needs attention',
        leadingIcon: Icons.flag_rounded,
        tone: AerosFilterChipTone.warning,
        dropdown: true,
        onTap: () {},
      ),
    );
    expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);
    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    expect(tester.widget<Material>(pill()).color, AerosSemanticColors.resolve(false).warningBg);
  });

  testWidgets('the clear ✕ shows only while selected, and clears without tapping the chip', (tester) async {
    var taps = 0;
    var clears = 0;
    Widget chip(bool selected) => AerosFilterChip(
          label: 'Stage: Won',
          selected: selected,
          dropdown: true,
          onTap: () => taps++,
          onClear: () => clears++,
        );

    await pump(tester, chip(false));
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await pump(tester, chip(true));
    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(clears, 1);
    expect(taps, 0);

    await tester.tap(find.text('Stage: Won'));
    expect(taps, 1);
  });

  testWidgets('announces itself as a selectable button', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, AerosFilterChip(label: 'All', selected: true, onTap: () {}));
    expect(
      tester.getSemantics(find.text('All')),
      matchesSemantics(
        label: 'All',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });
}
