// The 3.0 foundation layer: pressable, state layer, focus ring, surface,
// control sizes — and the controls rebuilt on it.
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool dark = false, AerosDensity? density}) => MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      home: Scaffold(
        body: Center(
          child: density == null ? child : AerosDensityScope(density: density, child: child),
        ),
      ),
    );

/// WCAG 2.x contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Draw focus rings as they are for Tab, whatever the last input device was.
void _keyboardFocusMode() {
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
}

/// The painted box of an [AerosButton] (the hit target around it may be larger).
Finder _buttonFill(Finder button) => find.descendant(of: button, matching: find.byType(AerosStateFill));

void main() {
  group('AerosFocusRing', () {
    testWidgets('showing the ring moves and resizes nothing', (tester) async {
      Widget scene(bool focused) => _app(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AerosFocusRing(
                  focused: focused,
                  child: const SizedBox(key: Key('ringed'), width: 120, height: 32),
                ),
                const SizedBox(key: Key('neighbour'), width: 40, height: 32),
              ],
            ),
          );

      await tester.pumpWidget(scene(false));
      final ring = tester.getRect(find.byType(AerosFocusRing));
      final child = tester.getRect(find.byKey(const Key('ringed')));
      final neighbour = tester.getRect(find.byKey(const Key('neighbour')));

      await tester.pumpWidget(scene(true));
      expect(tester.getRect(find.byType(AerosFocusRing)), ring);
      expect(tester.getRect(find.byKey(const Key('ringed'))), child);
      expect(tester.getRect(find.byKey(const Key('neighbour'))), neighbour);
      // The ring is the child's size: it is painted outside, not laid out.
      expect(ring.size, child.size);
    });

    testWidgets('a keyboard-focused button keeps its size and its neighbours in place', (tester) async {
      _keyboardFocusMode();
      await tester.pumpWidget(_app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AerosButton(key: const Key('a'), label: 'First', onPressed: () {}),
            AerosButton(key: const Key('b'), label: 'Second', onPressed: () {}, variant: AerosButtonVariant.secondary),
          ],
        ),
      ));
      final before = [
        tester.getRect(find.byKey(const Key('a'))),
        tester.getRect(find.byKey(const Key('b'))),
        tester.getRect(_buttonFill(find.byKey(const Key('a')))),
      ];
      bool ringShown() => tester
          .widget<AerosFocusRing>(find.descendant(of: find.byKey(const Key('a')), matching: find.byType(AerosFocusRing)))
          .focused;
      expect(ringShown(), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(ringShown(), isTrue);
      expect([
        tester.getRect(find.byKey(const Key('a'))),
        tester.getRect(find.byKey(const Key('b'))),
        tester.getRect(_buttonFill(find.byKey(const Key('a')))),
      ], before);
    });

    testWidgets('a focused text field keeps its size', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(width: 240, child: AerosTextField(hint: 'Name'))));
      final before = tester.getRect(find.byType(AerosFieldFrame));
      await tester.tap(find.byType(AerosTextField));
      await tester.pumpAndSettle();
      // A text input shows the ring for pointer focus too.
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).focused, isTrue);
      expect(tester.getRect(find.byType(AerosFieldFrame)), before);
    });
  });

  group('AerosPressable', () {
    testWidgets('activates on Enter and on Space', (tester) async {
      var presses = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(
        AerosPressable(
          focusNode: node,
          onPressed: () => presses++,
          builder: (context, state) => const SizedBox(width: 80, height: 32),
        ),
      ));
      node.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(presses, 2);
    });

    testWidgets('reports hover, press and keyboard focus to the builder', (tester) async {
      _keyboardFocusMode();
      late AerosInteraction seen;
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(
        AerosPressable(
          focusNode: node,
          onPressed: () {},
          builder: (context, state) {
            seen = state;
            return const SizedBox(width: 80, height: 32);
          },
        ),
      ));
      expect(seen, const AerosInteraction());

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(AerosPressable)));
      await tester.pump();
      expect(seen.hovered, isTrue);
      expect(seen.pressed, isFalse);

      await mouse.down(tester.getCenter(find.byType(AerosPressable)));
      await tester.pump();
      expect(seen.pressed, isTrue);
      await mouse.up();
      await tester.pump();
      expect(seen.pressed, isFalse);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(seen.hovered, isFalse);

      node.requestFocus();
      await tester.pumpAndSettle();
      expect(seen.focused, isTrue);
    });

    testWidgets('a disabled pressable ignores taps and keys and reports disabled', (tester) async {
      late AerosInteraction seen;
      var presses = 0;
      await tester.pumpWidget(_app(
        AerosPressable(
          enabled: false,
          onPressed: () => presses++,
          builder: (context, state) {
            seen = state;
            return const SizedBox(width: 80, height: 32);
          },
        ),
      ));
      await tester.tap(find.byType(AerosPressable));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 0);
      expect(seen.disabled, isTrue);
      expect(seen.focused, isFalse);
    });

    testWidgets('the hit target grows around the visual without resizing it', (tester) async {
      for (final density in AerosDensity.values) {
        await tester.pumpWidget(_app(
          AerosPressable(
            onPressed: () {},
            builder: (context, state) => const SizedBox(key: Key('visual'), width: 10, height: 10),
          ),
          density: density,
        ));
        expect(tester.getSize(find.byKey(const Key('visual'))), const Size(10, 10));
        expect(tester.getSize(find.byType(AerosPressable)), Size.square(density.sizes.minTarget));
        expect(
          tester.getCenter(find.byKey(const Key('visual'))),
          tester.getCenter(find.byType(AerosPressable)),
        );
      }
    });
  });

  group('hit targets', () {
    final controls = <String, Widget>{
      'button xs': AerosButton(label: 'Go', onPressed: () {}, size: AerosControlSize.xs),
      'icon button xs': AerosButton.icon(
        icon: const Icon(Icons.add),
        semanticLabel: 'Add',
        onPressed: () {},
        size: AerosControlSize.xs,
      ),
      'checkbox': AerosCheckbox(value: true, onChanged: (_) {}),
      'radio': AerosRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
      'switch': AerosSwitch(value: true, onChanged: (_) {}),
    };

    for (final density in AerosDensity.values) {
      for (final control in controls.entries) {
        testWidgets('${control.key} is at least minTarget at ${density.name}', (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(_app(control.value, density: density));
          final min = density.sizes.minTarget;

          final box = tester.getSize(find.byType(AerosPressable));
          expect(box.width, greaterThanOrEqualTo(min));
          expect(box.height, greaterThanOrEqualTo(min));

          // What assistive technology (and the tap-target guideline) sees.
          final node = tester.getSemantics(find.byType(AerosPressable));
          expect(node.rect.width, greaterThanOrEqualTo(min));
          expect(node.rect.height, greaterThanOrEqualTo(min));

          await expectLater(
            tester,
            meetsGuideline(MinimumTapTargetGuideline(size: Size.square(min), link: 'size.minTarget')),
          );
          handle.dispose();
        });
      }
    }

    testWidgets('compact shrinks the target to the glyph', (tester) async {
      await tester.pumpWidget(_app(AerosCheckbox(value: true, compact: true, onChanged: (_) {})));
      expect(tester.getSize(find.byType(AerosCheckbox)), const Size.square(AerosSizeTokens.iconMd));
    });
  });

  group('AerosButton', () {
    for (final density in AerosDensity.values) {
      testWidgets('heights are the control size tokens at ${density.name}', (tester) async {
        final sizes = density.sizes;
        final expected = {
          AerosControlSize.xs: sizes.controlXs,
          AerosControlSize.sm: sizes.controlSm,
          AerosControlSize.md: sizes.controlMd,
          AerosControlSize.lg: sizes.controlLg,
          AerosControlSize.xl: sizes.controlXl,
        };
        await tester.pumpWidget(_app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final size in AerosControlSize.values)
                AerosButton(key: ValueKey(size), label: 'Button', onPressed: () {}, size: size),
              for (final size in AerosControlSize.values)
                AerosButton.icon(
                  key: ValueKey('icon-${size.name}'),
                  icon: const Icon(Icons.add),
                  semanticLabel: 'Add',
                  onPressed: () {},
                  size: size,
                ),
            ],
          ),
          density: density,
        ));
        for (final size in AerosControlSize.values) {
          expect(tester.getSize(_buttonFill(find.byKey(ValueKey(size)))).height, expected[size], reason: '$size');
          // An icon button is a square of the same height.
          expect(
            tester.getSize(_buttonFill(find.byKey(ValueKey('icon-${size.name}')))),
            Size.square(expected[size]!),
            reason: 'icon $size',
          );
        }
      });
    }

    testWidgets('a button and a field of the same size are the same height', (tester) async {
      for (final density in AerosDensity.values) {
        await tester.pumpWidget(_app(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 200, child: AerosTextField(hint: 'Name')),
              AerosButton(label: 'Save', onPressed: () {}),
            ],
          ),
          density: density,
        ));
        expect(
          tester.getSize(find.byType(AerosFieldFrame)).height,
          tester.getSize(_buttonFill(find.byType(AerosButton))).height,
        );
      }
    });

    test('danger label contrast is at least 4.5:1, at rest and hovered, in both themes', () {
      for (final (aliases, semantic) in [
        (AerosAliasColors.light, AerosSemanticColors.light),
        (AerosAliasColors.dark, AerosSemanticColors.dark),
      ]) {
        expect(_contrast(aliases.fgInverse, semantic.danger), greaterThanOrEqualTo(4.5));
        expect(_contrast(aliases.fgInverse, semantic.dangerHover), greaterThanOrEqualTo(4.5));
      }
    });

    for (final dark in [false, true]) {
      testWidgets('danger is solid and its rendered label clears 4.5:1 (${dark ? 'dark' : 'light'})', (tester) async {
        await tester.pumpWidget(_app(AerosButton.danger(label: 'Delete', onPressed: () {}), dark: dark));
        final semantic = dark ? AerosSemanticColors.dark : AerosSemanticColors.light;
        final fill = tester.widget<AerosStateFill>(_buttonFill(find.byType(AerosButton))).color;
        final label = tester.widget<Text>(find.text('Delete')).style!.color!;
        expect(fill, semantic.danger);
        expect(_contrast(label, fill), greaterThanOrEqualTo(4.5));
      });
    }

    testWidgets('dangerSubtle keeps the tinted look', (tester) async {
      await tester.pumpWidget(_app(
        AerosButton(label: 'Remove', onPressed: () {}, variant: AerosButtonVariant.dangerSubtle),
      ));
      final fill = tester.widget<AerosStateFill>(_buttonFill(find.byType(AerosButton)));
      expect(fill.color, AerosSemanticColors.light.dangerBg);
      expect(fill.borderColor, AerosSemanticColors.light.dangerBorder);
      expect(tester.widget<Text>(find.text('Remove')).style!.color, AerosSemanticColors.light.dangerText);
    });

    testWidgets('hover changes the fill only — never the size', (tester) async {
      await tester.pumpWidget(_app(AerosButton.secondary(label: 'Export', onPressed: () {})));
      final before = tester.getRect(_buttonFill(find.byType(AerosButton)));
      final rest = tester.widget<AerosStateFill>(_buttonFill(find.byType(AerosButton))).color;

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(AerosButton)));
      await tester.pumpAndSettle();

      final hovered = tester.widget<AerosStateFill>(_buttonFill(find.byType(AerosButton))).color;
      expect(hovered, isNot(rest));
      expect(hovered, Color.alphaBlend(AerosAliasColors.light.stateHover, AerosAliasColors.light.bgSurface));
      expect(tester.getRect(_buttonFill(find.byType(AerosButton))), before);
    });

    testWidgets('an icon button announces its semantic label as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(
        AerosButton.icon(icon: const Icon(Icons.delete_outline), semanticLabel: 'Delete row', onPressed: () {}),
      ));
      expect(
        tester.getSemantics(find.byType(AerosButton)),
        containsSemantics(label: 'Delete row', isButton: true, isEnabled: true, hasTapAction: true),
      );
      handle.dispose();
    });

    test('the old size names still compile', () {
      // ignore: deprecated_member_use_from_same_package, deprecated_member_use
      expect(AerosButtonSize.md, AerosControlSize.md);
      // ignore: deprecated_member_use_from_same_package, deprecated_member_use
      expect(AerosFieldSize.lg, AerosControlSize.lg);
    });
  });

  group('selection control semantics', () {
    testWidgets('checkbox: checked, mixed, enabled and disabled', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_app(AerosCheckbox(value: true, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosCheckbox)),
        containsSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );

      await tester.pumpWidget(_app(AerosCheckbox(value: false, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosCheckbox)),
        containsSemantics(hasCheckedState: true, isChecked: false, isEnabled: true),
      );

      await tester.pumpWidget(_app(AerosCheckbox(value: null, tristate: true, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosCheckbox)),
        containsSemantics(hasCheckedState: true, isChecked: false, isCheckStateMixed: true),
      );

      // Both ways of disabling.
      for (final disabled in [
        const AerosCheckbox(value: true, onChanged: null),
        AerosCheckbox(value: true, onChanged: (_) {}, enabled: false),
      ]) {
        await tester.pumpWidget(_app(disabled));
        expect(
          tester.getSemantics(find.byType(AerosCheckbox)),
          containsSemantics(
            hasCheckedState: true,
            isChecked: true,
            hasEnabledState: true,
            isEnabled: false,
            hasTapAction: false,
          ),
        );
      }
      handle.dispose();
    });

    testWidgets('radio: checked, mutually exclusive, enabled and disabled', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_app(AerosRadio<int>(value: 1, groupValue: 1, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosRadio<int>)),
        containsSemantics(
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await tester.pumpWidget(_app(AerosRadio<int>(value: 2, groupValue: 1, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosRadio<int>)),
        containsSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true),
      );

      await tester.pumpWidget(_app(const AerosRadio<int>(value: 1, groupValue: 1, onChanged: null)));
      expect(
        tester.getSemantics(find.byType(AerosRadio<int>)),
        containsSemantics(
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('switch: toggled, enabled and disabled', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_app(AerosSwitch(value: true, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosSwitch)),
        containsSemantics(
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await tester.pumpWidget(_app(AerosSwitch(value: false, onChanged: (_) {})));
      expect(
        tester.getSemantics(find.byType(AerosSwitch)),
        containsSemantics(hasToggledState: true, isToggled: false),
      );

      await tester.pumpWidget(_app(AerosSwitch(value: true, onChanged: (_) {}, enabled: false)));
      expect(
        tester.getSemantics(find.byType(AerosSwitch)),
        containsSemantics(
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });
  });

  group('selection control behaviour', () {
    testWidgets('checkbox cycles false → true → false, and through null when tristate', (tester) async {
      final seen = <bool?>[];
      Future<void> tapWith(bool? value, {bool tristate = false}) async {
        await tester.pumpWidget(_app(AerosCheckbox(value: value, tristate: tristate, onChanged: seen.add)));
        await tester.tap(find.byType(AerosCheckbox));
      }

      await tapWith(false);
      await tapWith(true);
      await tapWith(true, tristate: true);
      await tapWith(null, tristate: true);
      expect(seen, [true, false, null, false]);
    });

    testWidgets('radio reports its value; switch reports the flipped value', (tester) async {
      int? picked;
      await tester.pumpWidget(_app(AerosRadio<int>(value: 7, groupValue: 1, onChanged: (v) => picked = v)));
      await tester.tap(find.byType(AerosRadio<int>));
      expect(picked, 7);

      bool? flipped;
      await tester.pumpWidget(_app(AerosSwitch(value: true, onChanged: (v) => flipped = v)));
      await tester.tap(find.byType(AerosSwitch));
      expect(flipped, isFalse);
    });

    testWidgets('disabled controls do not call back and take no keyboard focus', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AerosCheckbox(value: false, onChanged: (_) => calls++, enabled: false),
            AerosRadio<int>(value: 2, groupValue: 1, onChanged: (_) => calls++, enabled: false),
            AerosSwitch(value: false, onChanged: (_) => calls++, enabled: false),
          ],
        ),
      ));
      await tester.tap(find.byType(AerosCheckbox), warnIfMissed: false);
      await tester.tap(find.byType(AerosRadio<int>), warnIfMissed: false);
      await tester.tap(find.byType(AerosSwitch), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('Space toggles a focused checkbox', (tester) async {
      bool? seen;
      await tester.pumpWidget(_app(AerosCheckbox(value: false, onChanged: (v) => seen = v)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(seen, isTrue);
    });
  });

  group('AerosStateLayer', () {
    test('composites the state aliases over the base colour', () {
      const a = AerosAliasColors.light;
      final base = a.bgSurface;
      expect(AerosStateLayer.resolve(a, base), base);
      expect(AerosStateLayer.resolve(a, base, hovered: true), Color.alphaBlend(a.stateHover, base));
      expect(AerosStateLayer.resolve(a, base, pressed: true), Color.alphaBlend(a.statePressed, base));
      expect(AerosStateLayer.resolve(a, base, selected: true), Color.alphaBlend(a.stateSelected, base));
      // Pressed wins over hovered; disabled ignores both.
      expect(
        AerosStateLayer.resolve(a, base, hovered: true, pressed: true),
        Color.alphaBlend(a.statePressed, base),
      );
      expect(AerosStateLayer.resolve(a, base, hovered: true, pressed: true, enabled: false), base);
      // Every state is a visible change from rest, in both themes.
      for (final aliases in [AerosAliasColors.light, AerosAliasColors.dark]) {
        final rest = aliases.bgSurface;
        expect(AerosStateLayer.resolve(aliases, rest, hovered: true), isNot(rest));
        expect(AerosStateLayer.resolve(aliases, rest, pressed: true), isNot(rest));
        expect(AerosStateLayer.resolve(aliases, rest, selected: true), isNot(rest));
      }
    });
  });

  group('AerosSurface', () {
    BoxDecoration decorationOf(WidgetTester tester) =>
        tester.widget<Container>(find.descendant(of: find.byType(AerosSurface), matching: find.byType(Container))).decoration!
            as BoxDecoration;

    testWidgets('flat is a fill and a hairline with no shadow', (tester) async {
      await tester.pumpWidget(_app(const AerosSurface(child: SizedBox(width: 80, height: 40))));
      final d = decorationOf(tester);
      expect(d.color, AerosAliasColors.light.bgSurface);
      expect(d.boxShadow, isNull);
      expect((d.border! as Border).top.width, AerosMetricTokens.borderHairline);
      expect((d.border! as Border).top.color, AerosAliasColors.light.borderDefault);
    });

    testWidgets('overlay and modal float on the elevation shadow, with no border of their own', (tester) async {
      for (final dark in [false, true]) {
        final elevation = AerosElevation.resolve(dark);
        final aliases = AerosAliasColors.resolve(dark);
        for (final (level, shadow, radius) in [
          (AerosSurfaceLevel.overlay, elevation.overlay, AerosShapeTokens.surface),
          (AerosSurfaceLevel.modal, elevation.modal, AerosShapeTokens.modal),
        ]) {
          await tester.pumpWidget(_app(
            AerosSurface(level: level, child: const SizedBox(width: 80, height: 40)),
            dark: dark,
          ));
          // MaterialApp animates a theme change; read the settled theme.
          await tester.pumpAndSettle();
          final d = decorationOf(tester);
          expect(d.color, aliases.bgElevated);
          expect(d.border, isNull);
          expect(d.boxShadow, shadow);
          expect(d.borderRadius, BorderRadius.circular(radius));
        }
      }
    });
  });

  group('theme', () {
    test('extension lerp interpolates aliases, status colours and elevation', () {
      const a = AerosThemeExtension.light;
      const b = AerosThemeExtension.dark;
      final mid = a.lerp(b, 0.5);

      expect(mid.aliases.bgSurface, isNot(a.aliases.bgSurface));
      expect(mid.aliases.bgSurface, isNot(b.aliases.bgSurface));
      expect(mid.semantic.danger, isNot(a.semantic.danger));
      expect(mid.semantic.danger, isNot(b.semantic.danger));
      expect(mid.semantic.successBg, isNot(a.semantic.successBg));
      expect(mid.semantic.successBg, isNot(b.semantic.successBg));
      expect(mid.elevation.overlay, isNot(a.elevation.overlay));
      expect(mid.elevation.overlay, isNot(b.elevation.overlay));
      expect(mid.elevation.raised.first.color, isNot(a.elevation.raised.first.color));
      expect(mid.elevation.raised.first.color, isNot(b.elevation.raised.first.color));

      // The ends are the ends.
      expect(a.lerp(b, 0).semantic.danger, a.semantic.danger);
      expect(a.lerp(b, 1).semantic.danger, b.semantic.danger);
      expect(a.lerp(b, 1).elevation.raised, b.elevation.raised);
    });

    test('an extension built without status colours or elevation takes its brightness', () {
      const ext = AerosThemeExtension(aliases: AerosAliasColors.dark, isDark: true);
      expect(ext.semantic, AerosSemanticColors.dark);
      expect(ext.elevation, AerosElevation.dark);
    });

    testWidgets('context accessors read the extension', (tester) async {
      late AerosSemanticColors semantic;
      late AerosElevation elevation;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          semantic = context.aerosSemantic;
          elevation = context.aerosElevation;
          return const SizedBox();
        }),
        dark: true,
      ));
      expect(semantic, AerosSemanticColors.dark);
      expect(elevation, AerosElevation.dark);
    });

    test('ThemeData: no ripple, no tint, token colours, readable onError', () {
      for (final (theme, aliases, semantic) in [
        (AerosTheme.light(), AerosAliasColors.light, AerosSemanticColors.light),
        (AerosTheme.dark(), AerosAliasColors.dark, AerosSemanticColors.dark),
      ]) {
        final scheme = theme.colorScheme;
        expect(theme.splashFactory, NoSplash.splashFactory);
        expect(theme.splashColor, Colors.transparent);
        expect(theme.highlightColor, Colors.transparent);
        expect(theme.hoverColor, aliases.stateHover);
        expect(scheme.surfaceTint, Colors.transparent);
        expect(scheme.scrim, aliases.scrim);
        expect(scheme.error, semantic.danger);
        expect(_contrast(scheme.onError, scheme.error), greaterThanOrEqualTo(4.5));
        expect(_contrast(scheme.onPrimary, scheme.primary), greaterThanOrEqualTo(4.5));
        expect(_contrast(scheme.onSecondary, scheme.secondary), greaterThanOrEqualTo(4.5));
        expect(theme.dialogTheme.elevation, 0);

        // The input border is a hairline in every state.
        final input = theme.inputDecorationTheme;
        for (final border in [input.enabledBorder, input.focusedBorder, input.errorBorder, input.focusedErrorBorder]) {
          expect(border!.borderSide.width, AerosMetricTokens.borderHairline);
          expect((border as OutlineInputBorder).borderRadius, BorderRadius.circular(AerosShapeTokens.control));
        }
      }
    });
  });

  group('fields', () {
    for (final dark in [false, true]) {
      testWidgets('an error uses the theme danger colours (${dark ? 'dark' : 'light'})', (tester) async {
        final semantic = dark ? AerosSemanticColors.dark : AerosSemanticColors.light;
        await tester.pumpWidget(_app(
          const SizedBox(width: 240, child: AerosTextField(label: 'Email', errorText: 'Enter a valid email')),
          dark: dark,
        ));
        expect(tester.widget<Text>(find.text('Enter a valid email')).style!.color, semantic.dangerText);
        final fill = tester.widget<AerosStateFill>(
          find.descendant(of: find.byType(AerosFieldFrame), matching: find.byType(AerosStateFill)),
        );
        expect(fill.borderColor, semantic.danger);
        // Legible on the field's surface.
        expect(
          _contrast(semantic.dangerText, dark ? AerosAliasColors.dark.bgCanvas : AerosAliasColors.light.bgCanvas),
          greaterThanOrEqualTo(4.5),
        );
      });
    }

    testWidgets('every field type shares the control radius', (tester) async {
      await tester.pumpWidget(_app(
        SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AerosTextField(hint: 'Name', size: AerosControlSize.sm),
              const AerosSearchField(size: AerosControlSize.lg),
              AerosTagField(tags: const ['a'], onChanged: (_) {}),
            ],
          ),
        ),
      ));
      final fills = tester.widgetList<AerosStateFill>(
        find.descendant(of: find.byType(AerosFieldFrame), matching: find.byType(AerosStateFill)),
      );
      expect(fills, hasLength(3));
      for (final fill in fills) {
        expect(fill.radius, BorderRadius.circular(AerosShapeTokens.control));
        expect(fill.color, AerosAliasColors.light.bgSurface);
        expect(fill.borderColor, AerosAliasColors.light.borderStrong);
      }
    });
  });
}
