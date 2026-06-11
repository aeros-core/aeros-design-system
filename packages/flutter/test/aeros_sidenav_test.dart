import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSidenav(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(
          body: AerosSidenav(
            items: [
              const AerosNavItem(
                label: 'Masters',
                icon: Icons.settings_outlined,
                children: [
                  AerosNavItem(label: 'Units Master'),
                  AerosNavItem(label: 'Industry Master', selected: true),
                ],
              ),
              AerosNavItem(
                label: 'Orders',
                icon: Icons.receipt_long_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('AerosSidenav density', () {
    testWidgets('leaf rows use 13px/1.4 labels, 16px icons, 34px rows',
        (tester) async {
      await pumpSidenav(tester);

      final label = tester.widget<Text>(find.text('Orders'));
      expect(label.style!.fontSize, 13);
      expect(label.style!.height, 1.4);
      expect(label.style!.fontWeight, FontWeight.w500);
      expect(label.maxLines, 1);
      expect(label.overflow, TextOverflow.ellipsis);

      final icon = tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined));
      expect(icon.size, 16);

      final row = tester.getSize(
        find.ancestor(of: find.text('Orders'), matching: find.byType(Container)).first,
      );
      // 8px vertical padding + 13px * 1.4 line height.
      expect(row.height, closeTo(2 * 8 + 13 * 1.4, 0.5));
    });

    testWidgets('sections indent children 16px per depth and bold the selected leaf',
        (tester) async {
      await pumpSidenav(tester);
      await tester.tap(find.text('Masters'));
      await tester.pumpAndSettle();

      final parent = tester.widget<Container>(
        find.ancestor(of: find.text('Masters'), matching: find.byType(Container)).first,
      );
      final child = tester.widget<Container>(
        find.ancestor(of: find.text('Units Master'), matching: find.byType(Container)).first,
      );
      expect((parent.padding! as EdgeInsets).left, 16);
      expect((child.padding! as EdgeInsets).left, 32);

      final header = tester.widget<Text>(find.text('Masters'));
      expect(header.style!.fontWeight, FontWeight.w600);

      final selected = tester.widget<Text>(find.text('Industry Master'));
      expect(selected.style!.fontWeight, FontWeight.w600);
    });
  });
}
