// Shared harness for the golden suite: one scene, four images
// (light/dark × pointer/touch).
import 'dart:async';
import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// How a scene is brought to rest before the screenshot.
enum GoldenSettle {
  /// `pumpAndSettle` — for scenes whose animations all finish.
  settle,

  /// A fixed run of pumps — for scenes holding something that never stops
  /// (a spinner, an indeterminate bar, the thinking orb). The test clock is
  /// fake, so the frame captured is the same on every run.
  bounded,
}

const _themes = <String, bool>{'light': false, 'dark': true};
const _densities = <String, AerosDensity>{
  'pointer': AerosDensity.pointer,
  'touch': AerosDensity.touch,
};

final _surfaceKey = GlobalKey(debugLabel: 'golden surface');
final _sceneKey = GlobalKey(debugLabel: 'golden scene');

/// Sizing aid for scene authors: `GOLDEN_MEASURE=1 flutter test --tags golden`
/// lays every padded scene out on an oversized surface and prints the size it
/// needs (padding included) next to the size it was given, without comparing
/// or writing any image.
final _measure = Platform.environment['GOLDEN_MEASURE'] == '1';

/// Registers one golden test per theme {light, dark} × density {pointer,
/// touch} for the scene [builder] builds.
///
/// The scene sits top-left on a [size] surface, padded by 16. The image is the
/// whole surface, so dialogs, sheets, menus, tooltips and snackbars opened in
/// [act] are captured too.
///
/// [act] runs after the first settle and before the screenshot: hover a
/// button with [hover], focus a field with [focus], open an overlay. Leave
/// [padded] off for scenes that fill the surface (the app shell). [semantics]
/// off runs the scene without a semantics tree, for a widget whose semantics
/// currently assert (say why at the call site).
void goldenMatrix(
  String name,
  WidgetBuilder builder, {
  Size size = const Size(800, 600),
  Future<void> Function(WidgetTester tester)? act,
  GoldenSettle settle = GoldenSettle.settle,
  bool padded = true,
  bool semantics = true,
}) {
  for (final theme in _themes.entries) {
    for (final density in _densities.entries) {
      testWidgets(
        '$name · ${theme.key} · ${density.key}',
        tags: 'golden',
        semanticsEnabled: semantics,
        (tester) => _withoutMonoFontNoise(() async {
          tester.view.physicalSize = _measure ? const Size(3000, 3000) : size;
          tester.view.devicePixelRatio = 1.0;
          tester.platformDispatcher.textScaleFactorTestValue = 1.0;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          // Tests paint shadows as solid blocks by default. Elevation is part
          // of the look being pinned, so real shadows are switched on for the
          // scene and put back before the framework checks its debug flags.
          debugDisableShadows = false;
          try {
            await tester.pumpWidget(
              _app(builder, dark: theme.value, density: density.value, padded: padded),
            );
            await _rest(tester, settle);
            if (act != null) {
              await act(tester);
              await _rest(tester, settle);
            }

            if (_measure) {
              if (padded && !theme.value) {
                final needs = tester.getSize(find.byKey(_sceneKey));
                // ignore: avoid_print
                print(
                  'MEASURE $name ${density.key} needs ${needs.width.ceil()}x${needs.height.ceil()} '
                  'has ${size.width.round()}x${size.height.round()}',
                );
              }
              return;
            }

            await expectLater(
              find.byKey(_surfaceKey),
              matchesGoldenFile('goldens/${Platform.operatingSystem}/$name.${theme.key}.${density.key}.png'),
            );
          } finally {
            debugDisableShadows = true;
          }
        }),
      );
    }
  }
}

Widget _app(WidgetBuilder builder, {required bool dark, required AerosDensity density, required bool padded}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AerosTheme.dark() : AerosTheme.light(),
    // Above the Navigator, so routes pushed by a scene (dialogs, sheets,
    // menus) get the density and land in the image.
    builder: (context, child) => RepaintBoundary(
      key: _surfaceKey,
      child: AerosDensityScope(density: density, child: child!),
    ),
    home: padded
        ? Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: _sceneKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Builder(builder: builder),
                ),
              ),
            ),
          )
        : Builder(builder: builder),
  );
}

/// Runs [body] with google_fonts' "unable to load font" report filtered out of
/// the log.
///
/// Mono text asks google_fonts for IBM Plex Mono, which is not bundled and
/// cannot be fetched in a test (see flutter_test_config.dart). google_fonts
/// handles that failure itself but prints a six-line report every time, which
/// would bury real output. Everything else still prints.
Future<void> _withoutMonoFontNoise(Future<void> Function() body) {
  var inReport = false;
  return runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (line.startsWith('Error: google_fonts was unable to load font IBMPlexMono')) {
          inReport = true;
          return;
        }
        if (inReport) {
          if (line.startsWith("If troubleshooting doesn't solve the problem")) inReport = false;
          return;
        }
        parent.print(zone, line);
      },
    ),
  );
}

Future<void> _rest(WidgetTester tester, GoldenSettle settle) async {
  switch (settle) {
    case GoldenSettle.settle:
      await tester.pumpAndSettle();
    case GoldenSettle.bounded:
      // Long enough for route, ink and tooltip transitions to finish; a
      // looping animation is simply caught at t = 1s.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Puts a mouse pointer over [target] so its hover state is drawn.
Future<void> hover(WidgetTester tester, Finder target) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(tester.getCenter(target));
}

/// Presses and holds on [target] so its pressed state is drawn.
Future<void> press(WidgetTester tester, Finder target) async {
  final gesture = await tester.startGesture(tester.getCenter(target));
  addTearDown(gesture.up);
}

/// Gives keyboard focus to the first focusable at or below [target], with the
/// keyboard highlight mode on, so focus rings are drawn as they are for Tab.
Future<void> focus(WidgetTester tester, Finder target) async {
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
  FocusNode? node;
  void visit(Element element) {
    if (node != null) return;
    if (element.widget is Focus && element.widget is! FocusScope) {
      // The node a Focus widget owns is the nearest one seen from its child.
      Element? child;
      element.visitChildren((c) => child ??= c);
      final candidate = child == null ? null : Focus.maybeOf(child!, createDependency: false);
      if (candidate != null && candidate.canRequestFocus && !candidate.skipTraversal) {
        node = candidate;
        return;
      }
    }
    element.visitChildren(visit);
  }

  visit(tester.element(target));
  expect(node, isNotNull, reason: 'nothing focusable under $target');
  node!.requestFocus();
}

/// A captioned group inside a scene: a small label above [child].
class GoldenSection extends StatelessWidget {
  const GoldenSection(this.title, {super.key, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AerosTypography.caption(color: a.fgMuted)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Lays sections out top to bottom at a fixed [width].
class GoldenColumn extends StatelessWidget {
  const GoldenColumn({super.key, required this.children, this.width});

  final List<Widget> children;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    return width == null ? column : SizedBox(width: width, child: column);
  }
}

/// A wrapping row with the suite's standard gaps.
class GoldenRow extends StatelessWidget {
  const GoldenRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
}
