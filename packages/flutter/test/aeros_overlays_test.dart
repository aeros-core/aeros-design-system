import 'dart:ui' show CheckedState;

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) => MaterialApp(
      theme: AerosTheme.light(),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: Center(child: child)),
      ),
    );

void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Whether keyboard focus is inside a widget of type [T].
bool _focusIsInside<T extends Widget>() =>
    FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<T>() != null;

void main() {
  group('AerosDialog', () {
    Widget opener({bool barrierDismissible = true, ValueChanged<String?>? onResult}) => Builder(
          builder: (context) => AerosButton(
            label: 'Open',
            onPressed: () async {
              final result = await AerosDialog.show<String>(
                context,
                barrierDismissible: barrierDismissible,
                builder: (context) => AerosDialog(
                  title: 'Edit address',
                  description: 'Shown on invoices.',
                  content: const AerosTextField(label: 'Street'),
                  actions: [
                    AerosButton.secondary(label: 'Cancel', onPressed: () => Navigator.of(context).pop('cancelled')),
                    AerosButton(label: 'Save', onPressed: () => Navigator.of(context).pop('saved')),
                  ],
                ),
              );
              onResult?.call(result);
            },
          ),
        );

    testWidgets('opens and returns the value it was popped with', (tester) async {
      String? result;
      await tester.pumpWidget(_app(opener(onResult: (r) => result = r)));
      expect(find.byType(AerosDialog), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Edit address'), findsOneWidget);
      expect(find.text('Shown on invoices.'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);
      expect(result, 'saved');
    });

    testWidgets('Escape closes it', (tester) async {
      var closed = false;
      await tester.pumpWidget(_app(opener(onResult: (r) => closed = r == null)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);
      expect(closed, isTrue);
    });

    testWidgets('a tap on the scrim closes it; the close button too', (tester) async {
      await tester.pumpWidget(_app(opener()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);
    });

    testWidgets('with barrierDismissible false neither Escape nor the scrim closes it', (tester) async {
      await tester.pumpWidget(_app(opener(barrierDismissible: false)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsOneWidget);
    });

    testWidgets('keyboard focus stays inside while it is open, and returns to the trigger', (tester) async {
      await tester.pumpWidget(_app(opener()));
      // Open from the keyboard, so the trigger holds the focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsOneWidget);

      // Close, field, Cancel, Save — then round again.
      for (var i = 0; i < 9; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_focusIsInside<AerosDialog>(), isTrue, reason: 'Tab $i left the dialog');
      }
      for (var i = 0; i < 9; i++) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        expect(_focusIsInside<AerosDialog>(), isTrue, reason: 'Shift+Tab $i left the dialog');
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AerosDialog), findsNothing);
      expect(_focusIsInside<AerosButton>(), isTrue);
    });

    testWidgets('is a route named by its title', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(opener()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final node = tester.getSemantics(
        find.descendant(of: find.byType(AerosDialog), matching: find.byType(Semantics)).first,
      );
      expect(node.label, 'Edit address');
      expect(node.flagsCollection.scopesRoute, isTrue);
      expect(node.flagsCollection.namesRoute, isTrue);
      handle.dispose();
    });

    testWidgets('sizes are the layout tokens', (tester) async {
      _surface(tester, const Size(1400, 900));
      const expected = <AerosDialogSize, double>{
        AerosDialogSize.sm: AerosMetricTokens.layoutDialogSm,
        AerosDialogSize.md: AerosMetricTokens.layoutDialogMd,
        AerosDialogSize.lg: AerosMetricTokens.layoutDialogLg,
        AerosDialogSize.xl: AerosMetricTokens.layoutDialogXl,
      };
      for (final entry in expected.entries) {
        await tester.pumpWidget(_app(AerosDialog(title: 'Size', size: entry.key, content: const Text('Body'))));
        final surface = find.descendant(of: find.byType(AerosDialog), matching: find.byType(AerosSurface));
        expect(tester.getSize(surface).width, entry.value, reason: '${entry.key}');
      }
      expect(const AerosDialog().size, AerosDialogSize.md);
    });

    testWidgets('never wider than the screen, and a long body scrolls', (tester) async {
      _surface(tester, const Size(360, 480));
      await tester.pumpWidget(
        _app(
          AerosDialog(
            title: 'Terms',
            size: AerosDialogSize.xl,
            content: Text(List.filled(80, 'Orders are fulfilled by the seller.').join(' ')),
            actions: [AerosButton(label: 'Accept', onPressed: () {})],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final surface = find.descendant(of: find.byType(AerosDialog), matching: find.byType(AerosSurface));
      final rect = tester.getRect(surface);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(360));
      expect(rect.bottom, lessThanOrEqualTo(480));
      expect(
        find.descendant(of: find.byType(AerosDialog), matching: find.byType(SingleChildScrollView)),
        findsOneWidget,
      );
      // The footer stays in view.
      expect(tester.getRect(find.text('Accept')).bottom, lessThanOrEqualTo(rect.bottom));
    });

    testWidgets('is the modal surface with no shadow of its own making', (tester) async {
      await tester.pumpWidget(_app(const AerosDialog(title: 'Surface', content: Text('Body'))));
      final surface = tester.widget<AerosSurface>(
        find.descendant(of: find.byType(AerosDialog), matching: find.byType(AerosSurface)),
      );
      expect(surface.level, AerosSurfaceLevel.modal);
    });

    testWidgets('opens instantly when the platform asks for reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Scaffold(body: Center(child: opener())),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('Edit address'), findsOneWidget);
    });
  });

  group('AerosConfirmDialog', () {
    testWidgets('is a small AerosDialog; destructive uses the solid danger button', (tester) async {
      _surface(tester, const Size(900, 700));
      bool? answer;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => AerosButton(
              label: 'Delete',
              onPressed: () async => answer = await AerosConfirmDialog.show(
                context,
                title: 'Delete industry?',
                body: 'This cannot be undone.',
                confirmLabel: 'Yes, delete',
                destructive: true,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(tester.widget<AerosDialog>(find.byType(AerosDialog)).size, AerosDialogSize.sm);
      expect(
        tester.widget<AerosButton>(find.widgetWithText(AerosButton, 'Yes, delete')).variant,
        AerosButtonVariant.danger,
      );
      await tester.tap(find.text('Yes, delete'));
      await tester.pumpAndSettle();
      expect(answer, isTrue);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(answer, isFalse);
    });
  });

  group('AerosSheet', () {
    Widget opener(AerosSheetSide side, {AerosSheetSize size = AerosSheetSize.md}) => Builder(
          builder: (context) => AerosButton(
            label: 'Open',
            onPressed: () => AerosSheet.show<void>(
              context,
              side: side,
              size: size,
              builder: (context) => AerosSheet(
                title: 'Filters',
                content: const Text('Body'),
                actions: [AerosButton(label: 'Apply', onPressed: () => Navigator.of(context).pop())],
              ),
            ),
          ),
        );

    testWidgets('a bottom sheet spans the screen, sits on its bottom edge and closes on Escape', (tester) async {
      _surface(tester, const Size(500, 800));
      await tester.pumpWidget(_app(opener(AerosSheetSide.bottom)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final rect = tester.getRect(
        find.descendant(of: find.byType(AerosSheet), matching: find.byType(AerosSurface)),
      );
      expect(rect.left, 0);
      expect(rect.width, 500);
      expect(rect.bottom, 800);
      expect(rect.top, greaterThan(0));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AerosSheet), findsNothing);
    });

    testWidgets('dragging a bottom sheet down dismisses it', (tester) async {
      _surface(tester, const Size(500, 800));
      await tester.pumpWidget(_app(opener(AerosSheetSide.bottom)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.drag(find.text('Filters'), const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(find.byType(AerosSheet), findsNothing);
    });

    testWidgets('a side sheet is full height and as wide as its drawer token', (tester) async {
      _surface(tester, const Size(1200, 800));
      for (final size in AerosSheetSize.values) {
        await tester.pumpWidget(_app(opener(AerosSheetSide.right, size: size)));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final rect = tester.getRect(
          find.descendant(of: find.byType(AerosSheet), matching: find.byType(AerosSurface)),
        );
        expect(rect.width, size.maxWidth);
        expect(rect.right, 1200);
        expect(rect.height, 800);
        // The footer is pinned to the bottom of a full-height sheet.
        expect(tester.getRect(find.text('Apply')).bottom, greaterThan(700));
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
        expect(find.byType(AerosSheet), findsNothing);
      }
      expect(AerosSheetSize.sm.maxWidth, AerosMetricTokens.layoutDrawerSm);
      expect(AerosSheetSize.md.maxWidth, AerosMetricTokens.layoutDrawerMd);
      expect(AerosSheetSize.lg.maxWidth, AerosMetricTokens.layoutDrawerLg);
    });
  });

  group('AerosMenu', () {
    Widget menu({
      required List<AerosMenuEntry> items,
      AlignmentGeometry alignment = Alignment.center,
    }) =>
        Align(
          alignment: alignment,
          child: AerosMenu(
            items: items,
            trigger: (context, menu) => AerosButton.secondary(label: 'Actions', onPressed: menu.toggle),
          ),
        );

    bool highlighted(WidgetTester tester, String label) =>
        tester.widget<AerosMenuRow>(find.widgetWithText(AerosMenuRow, label)).highlighted;

    testWidgets('opens; arrows move past a disabled row; Enter activates', (tester) async {
      final chosen = <String>[];
      await tester.pumpWidget(
        _app(
          menu(
            items: [
              AerosMenuItem<void>(label: 'Rename', onSelected: () => chosen.add('rename')),
              AerosMenuItem<void>(label: 'Archive', enabled: false, onSelected: () => chosen.add('archive')),
              const AerosMenuSeparator(),
              AerosMenuItem<void>(label: 'Delete', destructive: true, onSelected: () => chosen.add('delete')),
            ],
          ),
        ),
      );
      expect(find.byType(AerosMenuList), findsNothing);
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsOneWidget);
      expect(highlighted(tester, 'Rename'), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);

      // Archive is disabled and the separator is not a row: both are skipped.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Archive'), isFalse);
      expect(highlighted(tester, 'Delete'), isTrue);

      // Wraps round to the first row, and back.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(chosen, ['delete']);
      expect(find.byType(AerosMenuList), findsNothing);
    });

    testWidgets('a tap chooses a row; a disabled row does nothing', (tester) async {
      final chosen = <String>[];
      await tester.pumpWidget(
        _app(
          menu(
            items: [
              AerosMenuItem<void>(label: 'Rename', onSelected: () => chosen.add('rename')),
              AerosMenuItem<void>(label: 'Archive', enabled: false, onSelected: () => chosen.add('archive')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(chosen, isEmpty);
      expect(find.byType(AerosMenuList), findsOneWidget);
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(chosen, ['rename']);
      expect(find.byType(AerosMenuList), findsNothing);
    });

    testWidgets('closes on an outside tap and on Escape, and gives focus back to the trigger', (tester) async {
      await tester.pumpWidget(
        _app(menu(items: [AerosMenuItem<void>(label: 'Rename', onSelected: () {})])),
      );
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(_focusIsInside<AerosMenuList>(), isTrue);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsNothing);
      expect(_focusIsInside<AerosButton>(), isTrue);

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsNothing);
      expect(_focusIsInside<AerosButton>(), isTrue);
    });

    testWidgets('stays inside the screen when its trigger is at an edge', (tester) async {
      _surface(tester, const Size(400, 300));
      final items = [for (var i = 0; i < 6; i++) AerosMenuItem<void>(label: 'A fairly long action number $i')];
      for (final alignment in [Alignment.bottomRight, Alignment.bottomLeft, Alignment.topRight]) {
        await tester.pumpWidget(_app(menu(items: items, alignment: alignment)));
        await tester.tap(find.text('Actions'));
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byType(AerosMenuList));
        expect(rect.left, greaterThanOrEqualTo(0), reason: '$alignment');
        expect(rect.top, greaterThanOrEqualTo(0), reason: '$alignment');
        expect(rect.right, lessThanOrEqualTo(400), reason: '$alignment');
        expect(rect.bottom, lessThanOrEqualTo(300), reason: '$alignment');
        // It never covers its trigger.
        expect(rect.overlaps(tester.getRect(find.byType(AerosButton))), isFalse, reason: '$alignment');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('a menu taller than the screen scrolls inside it', (tester) async {
      _surface(tester, const Size(400, 300));
      await tester.pumpWidget(
        _app(menu(items: [for (var i = 0; i < 40; i++) AerosMenuItem<void>(label: 'Action $i')])),
      );
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final rect = tester.getRect(find.byType(AerosMenuList));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(300));
      // End jumps to the last row and scrolls it into view.
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(highlighted(tester, 'Action 39'), isTrue);
      expect(tester.getRect(find.text('Action 39')).bottom, lessThanOrEqualTo(rect.bottom));
    });

    testWidgets('checkbox and radio items report checked, and call back with the new value', (tester) async {
      final handle = tester.ensureSemantics();
      bool? grid;
      String? density;
      final items = <AerosMenuEntry>[
        const AerosMenuLabel('View'),
        AerosMenuCheckboxItem(label: 'Show grid', checked: true, onChanged: (v) => grid = v),
        AerosMenuCheckboxItem(label: 'Show rulers', checked: false, onChanged: (_) {}),
        const AerosMenuSeparator(),
        AerosMenuRadioItem<String>(
          label: 'Compact',
          value: 'compact',
          groupValue: 'comfortable',
          onChanged: (v) => density = v,
        ),
        AerosMenuRadioItem<String>(
          label: 'Comfortable',
          value: 'comfortable',
          groupValue: 'comfortable',
          onChanged: (v) => density = v,
        ),
      ];
      await tester.pumpWidget(_app(menu(items: items)));
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      CheckedState checked(String label) =>
          tester.getSemantics(find.widgetWithText(AerosMenuRow, label)).flagsCollection.isChecked;
      expect(checked('Show grid'), CheckedState.isTrue);
      expect(checked('Show rulers'), CheckedState.isFalse);
      expect(checked('Compact'), CheckedState.isFalse);
      expect(checked('Comfortable'), CheckedState.isTrue);
      final radio = tester.getSemantics(find.widgetWithText(AerosMenuRow, 'Compact'));
      expect(radio.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      await tester.tap(find.text('Show grid'));
      await tester.pumpAndSettle();
      expect(grid, isFalse);

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compact'));
      await tester.pumpAndSettle();
      expect(density, 'compact');
      handle.dispose();
    });

    testWidgets('AerosMenu.show completes with the chosen value, or null', (tester) async {
      String? result = 'unset';
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => AerosButton(
              label: 'Sort',
              onPressed: () async => result = await AerosMenu.show<String>(
                context,
                items: const [
                  AerosMenuItem<String>(label: 'Newest', value: 'new'),
                  AerosMenuItem<String>(label: 'Oldest', value: 'old'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oldest'));
      await tester.pumpAndSettle();
      expect(result, 'old');

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('sits on the overlay surface: rows are control-sm high with the item radius', (tester) async {
      await tester.pumpWidget(
        _app(menu(items: [AerosMenuItem<void>(label: 'Rename', onSelected: () {})])),
      );
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      final surface = tester.widget<AerosSurface>(
        find.ancestor(of: find.byType(AerosMenuList), matching: find.byType(AerosSurface)),
      );
      expect(surface.level, AerosSurfaceLevel.overlay);
      expect(tester.getSize(find.byType(AerosMenuRow)).height, AerosSizeTokens.touch.controlSm);
      expect(find.descendant(of: find.byType(AerosMenuList), matching: find.byType(InkWell)), findsNothing);
    });
  });

  group('AerosPopover', () {
    testWidgets('shows any content, and its controller opens and closes it', (tester) async {
      final controller = AerosPopoverController();
      addTearDown(controller.dispose);
      final changes = <bool>[];
      await tester.pumpWidget(
        _app(
          AerosPopover(
            controller: controller,
            onOpenChanged: changes.add,
            trigger: (context, popover) => AerosButton(label: 'Filters', onPressed: popover.toggle),
            content: (context) => const SizedBox(width: 200, height: 80, child: Text('Popover body')),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Popover body'), findsOneWidget);
      expect(controller.isOpen, isTrue);
      // Below the trigger, by the gap.
      final trigger = tester.getRect(find.byType(AerosButton));
      final surface = tester.getRect(
        find.ancestor(of: find.text('Popover body'), matching: find.byType(AerosSurface)),
      );
      expect(surface.top, trigger.bottom + AerosPopover.gap);
      expect(surface.left, trigger.left);

      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Popover body'), findsNothing);
      expect(controller.isOpen, isFalse);
      expect(changes, [true, false]);
    });
  });

  group('AerosSelect', () {
    const items = [
      AerosSelectItem(value: 'kraft', label: 'Kraft'),
      AerosSelectItem(value: 'white', label: 'White board'),
      AerosSelectItem(value: 'pe', label: 'PE coated', enabled: false, detail: 'Not for this size'),
    ];

    Widget select({
      String? initial,
      String? error,
      bool enabled = true,
      ValueChanged<String>? onChanged,
    }) {
      var value = initial;
      return SizedBox(
        width: 320,
        child: StatefulBuilder(
          builder: (context, setState) => AerosSelect<String>(
            label: 'Material',
            placeholder: 'Select…',
            helper: 'Shown on the quote',
            error: error,
            enabled: enabled,
            items: items,
            value: value,
            onChanged: (v) {
              setState(() => value = v);
              onChanged?.call(v);
            },
          ),
        ),
      );
    }

    testWidgets('choosing an option updates the trigger and calls back', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_app(select(onChanged: changes.add)));
      expect(find.text('Select…'), findsOneWidget);
      expect(find.text('Shown on the quote'), findsOneWidget);

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsOneWidget);
      // At least as wide as the field, and hanging from its start edge.
      expect(
        tester.getSize(find.byType(AerosMenuList)).width,
        greaterThanOrEqualTo(tester.getSize(find.byType(AerosFieldFrame)).width),
      );
      expect(tester.getRect(find.byType(AerosMenuList)).left, tester.getRect(find.byType(AerosFieldFrame)).left);
      await tester.tap(find.text('White board'));
      await tester.pumpAndSettle();
      expect(changes, ['white']);
      expect(find.byType(AerosMenuList), findsNothing);
      expect(find.text('White board'), findsOneWidget);
      expect(find.text('Select…'), findsNothing);
    });

    testWidgets('the open list checks the chosen option and skips a disabled one', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_app(select(initial: 'white', onChanged: changes.add)));
      // From the keyboard: Tab to the field, arrow down to open.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final row = tester.widget<AerosMenuRow>(find.widgetWithText(AerosMenuRow, 'White board'));
      expect(row.checked, isTrue);
      expect(row.highlighted, isTrue);
      expect(row.mark, AerosMenuRowMark.selection);
      expect(find.text('Not for this size'), findsOneWidget);

      // Down from the chosen row skips the disabled one and wraps.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(tester.widget<AerosMenuRow>(find.widgetWithText(AerosMenuRow, 'Kraft')).highlighted, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, ['kraft']);
      expect(_focusIsInside<AerosSelect<String>>(), isTrue);

      await tester.tap(find.byType(AerosFieldFrame));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PE coated'));
      await tester.pumpAndSettle();
      expect(changes, ['kraft']);
    });

    testWidgets('an error turns the frame to the error state and replaces the helper', (tester) async {
      await tester.pumpWidget(_app(select(error: 'Choose a material')));
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isTrue);
      expect(find.text('Choose a material'), findsOneWidget);
      expect(find.text('Shown on the quote'), findsNothing);
    });

    testWidgets('disabled: dimmed, and it does not open', (tester) async {
      await tester.pumpWidget(_app(select(enabled: false)));
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).enabled, isFalse);
      final opacity = tester.widget<Opacity>(
        find.descendant(of: find.byType(AerosFieldFrame), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, AerosMetricTokens.opacityDisabled);
      await tester.tap(find.byType(AerosFieldFrame), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(AerosMenuList), findsNothing);
    });

    testWidgets('is the same height as a text field of its size', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 400,
            child: Row(
              children: [
                Expanded(child: AerosTextField(label: 'Name')),
                SizedBox(width: 8),
                Expanded(
                  child: AerosSelect<String>(label: 'Material', items: items, value: null, onChanged: null),
                ),
              ],
            ),
          ),
        ),
      );
      final frames = find.byType(AerosFieldFrame);
      expect(frames, findsNWidgets(2));
      expect(tester.getRect(frames.at(0)).top, tester.getRect(frames.at(1)).top);
      expect(tester.getSize(frames.at(0)).height, tester.getSize(frames.at(1)).height);
    });
  });

  group('AerosDropdownSearch', () {
    final cities = [for (var i = 0; i < 30; i++) 'City number $i'];

    Widget dropdown(AerosDropdownMode mode, {List<String>? items, ValueChanged<String?>? onChanged}) => SizedBox(
          width: 320,
          child: AerosDropdownSearch<String>(
            label: 'City',
            hint: 'Select a city',
            items: items ?? cities,
            itemAsString: (s) => s,
            mode: mode,
            onChanged: onChanged,
          ),
        );

    testWidgets('the menu never cuts its last visible row', (tester) async {
      for (final size in const [Size(640, 560), Size(640, 430), Size(640, 700)]) {
        _surface(tester, size);
        await tester.pumpWidget(_app(dropdown(AerosDropdownMode.menu)));
        await tester.tap(find.text('Select a city'));
        await tester.pumpAndSettle();

        final viewport = tester.getRect(find.byType(AerosWholeRows));
        final panel = tester.getRect(
          find.ancestor(of: find.byType(AerosWholeRows), matching: find.byType(AerosSurface)),
        );
        final rows = tester.widgetList<AerosMenuRow>(find.byType(AerosMenuRow)).length;
        expect(rows, cities.length);
        Rect? lastVisible;
        for (var i = 0; i < rows; i++) {
          final rect = tester.getRect(find.byType(AerosMenuRow).at(i));
          if (rect.top < viewport.bottom) lastVisible = rect;
        }
        expect(lastVisible, isNotNull);
        // Not every row fits — and the last one showing is whole.
        expect(lastVisible!.bottom, lessThan(tester.getRect(find.byType(AerosMenuRow).last).bottom));
        expect(lastVisible.bottom, lessThanOrEqualTo(viewport.bottom), reason: '$size');
        expect(lastVisible.bottom, lessThanOrEqualTo(panel.bottom), reason: '$size');
        expect(panel.bottom, lessThanOrEqualTo(size.height), reason: '$size');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('each presentation opens on its own surface and returns the pick', (tester) async {
      _surface(tester, const Size(900, 800));
      const expected = <AerosDropdownMode, Type>{
        AerosDropdownMode.dialog: AerosDialog,
        AerosDropdownMode.sheet: AerosSheet,
        AerosDropdownMode.menu: AerosWholeRows,
      };
      for (final entry in expected.entries) {
        String? picked;
        await tester.pumpWidget(
          _app(dropdown(entry.key, items: const ['Delhi', 'Mumbai', 'Pune'], onChanged: (v) => picked = v)),
        );
        await tester.tap(find.text('Select a city'));
        await tester.pumpAndSettle();
        expect(find.byType(entry.value), findsOneWidget, reason: '${entry.key}');
        expect(find.byType(AerosSearchField), findsOneWidget);
        expect(find.byType(AerosMenuRow), findsNWidgets(3));

        await tester.tap(find.text('Mumbai'));
        await tester.pumpAndSettle();
        expect(picked, 'Mumbai', reason: '${entry.key}');
        expect(find.byType(AerosMenuRow), findsNothing);
        // The trigger shows the pick.
        expect(find.text('Mumbai'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('typing filters; arrows and Enter choose without leaving the search box', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _app(
          dropdown(
            AerosDropdownMode.dialog,
            items: const ['Delhi', 'Mumbai', 'Pune'],
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.tap(find.text('Select a city'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'u');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AerosMenuRow), findsNWidgets(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 'Pune');
    });

    testWidgets('the trigger is one field frame; the clear button clears', (tester) async {
      String? value = 'Delhi';
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 320,
            child: AerosDropdownSearch<String>(
              label: 'City',
              items: const ['Delhi', 'Mumbai'],
              selectedItem: value,
              itemAsString: (s) => s,
              showClearButton: true,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );
      expect(find.byType(AerosFieldFrame), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      await tester.tap(find.bySemanticsLabel('Clear'));
      await tester.pumpAndSettle();
      expect(value, isNull);
      expect(find.byType(AerosMenuRow), findsNothing);
    });
  });

  group('right-to-left', () {
    testWidgets('dialog, sheet, menu, select and the search dropdown open without error', (tester) async {
      _surface(tester, const Size(900, 800));
      await tester.pumpWidget(
        _app(
          direction: TextDirection.rtl,
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AerosButton(
                  label: 'Dialog',
                  onPressed: () => AerosDialog.show<void>(
                    context,
                    builder: (context) => AerosDialog(
                      title: 'Title',
                      description: 'Description',
                      content: const Text('Body'),
                      actions: [AerosButton(label: 'Done', onPressed: () => Navigator.of(context).pop())],
                    ),
                  ),
                ),
                AerosButton(
                  label: 'Confirm',
                  onPressed: () => AerosConfirmDialog.show(context, title: 'Sure?', body: 'Body'),
                ),
                for (final side in AerosSheetSide.values)
                  AerosButton(
                    label: 'Sheet ${side.name}',
                    onPressed: () => AerosSheet.show<void>(
                      context,
                      side: side,
                      builder: (context) => const AerosSheet(title: 'Title', content: Text('Body')),
                    ),
                  ),
                AerosMenu(
                  items: [
                    const AerosMenuLabel('Group'),
                    AerosMenuItem<void>(
                      label: 'Rename',
                      leading: const Icon(Icons.edit),
                      shortcut: 'F2',
                      onSelected: () {},
                    ),
                    AerosMenuCheckboxItem(label: 'Pinned', checked: true, onChanged: (_) {}),
                    AerosMenuRadioItem<int>(label: 'One', value: 1, groupValue: 1, onChanged: (_) {}),
                    const AerosMenuSeparator(),
                    AerosMenuItem<void>(label: 'Delete', destructive: true, onSelected: () {}),
                  ],
                  trigger: (context, menu) => AerosButton(label: 'Menu', onPressed: menu.toggle),
                ),
                SizedBox(
                  width: 300,
                  child: AerosSelect<int>(
                    label: 'Select',
                    placeholder: 'Pick one',
                    items: const [AerosSelectItem(value: 1, label: 'One'), AerosSelectItem(value: 2, label: 'Two')],
                    value: 1,
                    onChanged: (_) {},
                  ),
                ),
                for (final mode in AerosDropdownMode.values)
                  SizedBox(
                    width: 300,
                    child: AerosDropdownSearch<String>(
                      hint: 'Dropdown ${mode.name}',
                      items: const ['Delhi', 'Mumbai'],
                      itemAsString: (s) => s,
                      mode: mode,
                      showClearButton: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      for (final label in [
        'Dialog',
        'Confirm',
        'Sheet bottom',
        'Sheet right',
        'Sheet left',
        'Menu',
        'One',
        'Dropdown dialog',
        'Dropdown sheet',
        'Dropdown menu',
      ]) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
    });

    testWidgets('a menu with start alignment hangs from the right edge of its trigger', (tester) async {
      await tester.pumpWidget(
        _app(
          direction: TextDirection.rtl,
          AerosMenu(
            items: [AerosMenuItem<void>(label: 'A long enough action label', onSelected: () {})],
            trigger: (context, menu) => AerosButton(label: 'Menu', onPressed: menu.toggle),
          ),
        ),
      );
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(AerosMenuList)).right, tester.getRect(find.byType(AerosButton)).right);
    });
  });
}
