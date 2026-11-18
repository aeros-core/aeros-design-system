import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AerosTheme.light(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

/// Controlled harness so the tag field's parent state updates on change.
class _TagHarness extends StatefulWidget {
  const _TagHarness({this.initial = const []});
  final List<String> initial;
  @override
  State<_TagHarness> createState() => _TagHarnessState();
}

class _TagHarnessState extends State<_TagHarness> {
  late List<String> _tags = List.of(widget.initial);
  @override
  Widget build(BuildContext context) => AerosTagField(
        tags: _tags,
        onChanged: (next) => setState(() => _tags = next),
      );
}

void main() {
  group('AerosControlSize ladder', () {
    // 3.0: the ladder is the `size.control*` tokens, per density; with no
    // density scope a control is touch-sized.
    test('heights are the control size tokens', () {
      expect(AerosControlSize.sm.height, AerosSizeTokens.touch.controlSm);
      expect(AerosControlSize.md.height, AerosSizeTokens.touch.controlMd);
      expect(AerosControlSize.lg.height, AerosSizeTokens.touch.controlLg);
      expect(AerosControlSize.sm.heightFor(AerosDensity.pointer), AerosSizeTokens.pointer.controlSm);
      expect(AerosControlSize.md.heightFor(AerosDensity.pointer), AerosSizeTokens.pointer.controlMd);
      expect(AerosControlSize.lg.heightFor(AerosDensity.pointer), AerosSizeTokens.pointer.controlLg);
    });

    test('value text is w500', () {
      expect(AerosControlSize.md.valueStyle().fontWeight, FontWeight.w500);
      expect(AerosControlSize.sm.valueStyle().fontWeight, FontWeight.w500);
    });
  });

  group('AerosTextField', () {
    testWidgets('single-line field lands on the size ladder', (t) async {
      await t.pumpWidget(_wrap(Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          AerosTextField(hint: 'md', size: AerosControlSize.md),
          SizedBox(height: 8),
          AerosTextField(hint: 'sm', size: AerosControlSize.sm),
        ],
      )));
      expect(t.getSize(find.byType(AerosTextField).at(0)).height, AerosSizeTokens.touch.controlMd);
      expect(t.getSize(find.byType(AerosTextField).at(1)).height, AerosSizeTokens.touch.controlSm);
    });
  });

  group('AerosSearchField', () {
    testWidgets('renders at its size height', (t) async {
      await t.pumpWidget(_wrap(const AerosSearchField(hint: 'Search')));
      expect(t.getSize(find.byType(AerosSearchField)).height, AerosSizeTokens.touch.controlMd);
    });

    testWidgets('shows a clear affix only after typing, and clears', (t) async {
      String? changed;
      await t.pumpWidget(_wrap(AerosSearchField(
        hint: 'Search',
        onChanged: (v) => changed = v,
      )));
      expect(find.byIcon(Icons.close), findsNothing);

      await t.enterText(find.byType(TextField), 'pgvector');
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await t.tap(find.byIcon(Icons.close));
      await t.pumpAndSettle();
      expect(changed, '');
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AerosTagField', () {
    testWidgets('adds a tag on submit and dedupes / strips #', (t) async {
      await t.pumpWidget(_wrap(const _TagHarness()));

      await t.enterText(find.byType(TextField), '#design');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(find.text('#design'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'design');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(find.text('#design'), findsOneWidget); // still just one
    });

    testWidgets('removes a tag when its chip is tapped', (t) async {
      await t.pumpWidget(_wrap(const _TagHarness(initial: ['launch'])));
      expect(find.text('#launch'), findsOneWidget);

      await t.tap(find.text('#launch'));
      await t.pumpAndSettle();
      expect(find.text('#launch'), findsNothing);
    });
  });
}
