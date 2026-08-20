import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AerosTheme.dark() : AerosTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('touch targets (Material 48dp)', () {
    testWidgets('AerosCheckbox default meets the tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosCheckbox(value: true, onChanged: (_) {})));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('AerosRadio default meets the tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosRadio<int>(value: 1, groupValue: 1, onChanged: (_) {})));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('AerosSwitch default meets the tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosSwitch(value: true, onChanged: (_) {})));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  });

  group('AerosButton semantics', () {
    testWidgets('disabled button still announces as a disabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const AerosButton(label: 'Save', onPressed: null)));
      expect(
        tester.getSemantics(find.byType(AerosButton)),
        containsSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('loading button announces the busy state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(AerosButton(label: 'Save', onPressed: () {}, loading: true)));
      expect(find.bySemanticsLabel('Save, loading'), findsOneWidget);
      handle.dispose();
    });
  });

  group('AerosSearchField clear affix', () {
    testWidgets('is a labeled button that clears the query', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController(text: 'pgvector');
      addTearDown(controller.dispose);
      await tester.pumpWidget(_app(AerosSearchField(controller: controller)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Clear search'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Clear search'));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      handle.dispose();
    });
  });

  group('AerosTypography theme safety', () {
    test('role styles inherit ambient color — no hardcoded light defaults', () {
      expect(AerosTypography.bodyMd().color, isNull);
      expect(AerosTypography.caption().color, isNull);
      expect(AerosTypography.overline().color, isNull);
      expect(AerosTypography.monoMd().color, isNull);
      expect(AerosTypography.monoSm().color, isNull);
    });
  });

  group('AerosSemanticColors', () {
    test('dark set diverges from light (status chips must flip in dark)', () {
      expect(AerosSemanticColors.dark.successBg,
          isNot(AerosSemanticColors.light.successBg));
      expect(AerosSemanticColors.resolve(true), AerosSemanticColors.dark);
      expect(AerosSemanticColors.resolve(false), AerosSemanticColors.light);
    });
  });
}
