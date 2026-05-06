import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper: renders a widget that captures the resolved breakpoint
/// so a test can assert on it.
class _BreakpointProbe extends StatelessWidget {
  const _BreakpointProbe({required this.onResolve});
  final ValueChanged<AerosBreakpoint> onResolve;
  @override
  Widget build(BuildContext context) {
    onResolve(AerosBreakpoints.of(context));
    return const SizedBox.shrink();
  }
}

class _ClampedMediaQuery extends StatelessWidget {
  const _ClampedMediaQuery({required this.clampedWidth, required this.child});
  final double clampedWidth;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final outer = MediaQuery.of(context);
    return MediaQuery(
      data: outer.copyWith(size: Size(clampedWidth, outer.size.height)),
      child: child,
    );
  }
}

void main() {
  group('AerosBreakpoints.forWidth', () {
    test('classifies viewport widths', () {
      expect(AerosBreakpoints.forWidth(320), AerosBreakpoint.xs);
      expect(AerosBreakpoints.forWidth(599), AerosBreakpoint.xs);
      expect(AerosBreakpoints.forWidth(600), AerosBreakpoint.sm);
      expect(AerosBreakpoints.forWidth(899), AerosBreakpoint.sm);
      expect(AerosBreakpoints.forWidth(900), AerosBreakpoint.md);
      expect(AerosBreakpoints.forWidth(1199), AerosBreakpoint.md);
      expect(AerosBreakpoints.forWidth(1200), AerosBreakpoint.lg);
      expect(AerosBreakpoints.forWidth(1599), AerosBreakpoint.lg);
      expect(AerosBreakpoints.forWidth(1600), AerosBreakpoint.xl);
      expect(AerosBreakpoints.forWidth(2560), AerosBreakpoint.xl);
    });
  });

  group('AerosResponsiveValue', () {
    test('falls back to closest defined value below', () {
      const v = AerosResponsiveValue<int>(xs: 1, md: 4);
      expect(v.resolveFor(AerosBreakpoint.xs), 1);
      expect(v.resolveFor(AerosBreakpoint.sm), 1);
      expect(v.resolveFor(AerosBreakpoint.md), 4);
      expect(v.resolveFor(AerosBreakpoint.lg), 4);
      expect(v.resolveFor(AerosBreakpoint.xl), 4);
    });

    test('AerosResponsiveValue.all uses one value everywhere', () {
      const v = AerosResponsiveValue<int>.all(3);
      for (final bp in AerosBreakpoint.values) {
        expect(v.resolveFor(bp), 3);
      }
    });
  });

  group('AerosResponsiveGrid', () {
    Future<void> pumpAt(WidgetTester tester, double width,
        {AerosResponsiveValue<int>? cols, double? tileMin}) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          home: Scaffold(
            body: AerosResponsiveGrid(
              crossAxisCount: cols,
              tileMinWidth: tileMin,
              aspectRatio: const AerosResponsiveValue<double>.all(1.0),
              children: List.generate(8, (i) => Text('cell$i')),
            ),
          ),
        ),
      );
    }

    testWidgets('explicit crossAxisCount wins', (tester) async {
      await pumpAt(
        tester,
        1440,
        cols: const AerosResponsiveValue<int>(xs: 2, md: 4),
        tileMin: 99999, // intentionally absurd; explicit cols should win
      );
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
    });

    testWidgets('tileMinWidth fallback fills the row', (tester) async {
      await pumpAt(tester, 1200, tileMin: 300);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
    });
  });

  group('AerosBreakpoints with AerosViewportScope', () {
    testWidgets('resolves from scope width, ignoring inner MediaQuery clamp',
        (tester) async {
      AerosBreakpoint? observed;
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          home: AerosViewportScope(
            width: 1440, // real browser width
            child: _ClampedMediaQuery(
              clampedWidth: 480, // simulates AerosWebShell's ScreenUtil clamp
              child: _BreakpointProbe(onResolve: (bp) => observed = bp),
            ),
          ),
        ),
      );
      expect(observed, AerosBreakpoint.lg);
    });

    testWidgets('falls back to MediaQuery when no scope is present',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      AerosBreakpoint? observed;
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          home: _BreakpointProbe(onResolve: (bp) => observed = bp),
        ),
      );
      expect(observed, AerosBreakpoint.sm);
    });
  });

  group('AerosTwoColumn', () {
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          home: const Scaffold(
            body: AerosTwoColumn(
              primary: SizedBox(key: ValueKey('p'), width: 100, height: 50),
              aside: SizedBox(key: ValueKey('a'), width: 100, height: 50),
            ),
          ),
        ),
      );
    }

    testWidgets('stacks below md', (tester) async {
      await pumpAt(tester, 800);
      expect(find.byType(Row), findsNothing);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('side-by-side at md and above', (tester) async {
      await pumpAt(tester, 1200);
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('AerosHoverable', () {
    testWidgets('flips hover flag on enter/exit', (tester) async {
      var seenHovered = false;
      var renderCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AerosTheme.light(),
          home: Scaffold(
            body: Center(
              child: AerosHoverable(
                builder: (context, hovered) {
                  renderCount++;
                  if (hovered) seenHovered = true;
                  return const SizedBox(width: 100, height: 100);
                },
              ),
            ),
          ),
        ),
      );

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(AerosHoverable)));
      await tester.pumpAndSettle();
      expect(seenHovered, isTrue);

      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      // Re-rendered with hovered=false at least once after exit.
      expect(renderCount, greaterThan(2));
    });
  });
}
