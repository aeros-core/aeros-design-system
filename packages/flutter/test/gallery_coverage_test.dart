// The example gallery (example/lib) is the reference usage of the package.
// This test keeps it complete: every widget the barrel exports has to appear
// in the gallery, and the gallery may use the public API only.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Exported classes that are deliberately NOT required in the gallery, with
/// the reason. Keep this short: a widget an app developer can use belongs in
/// the gallery, not here.
const _allowlist = <String, String>{
  // A marker scope AerosScaffold puts around its drawer so the sidenav in it
  // never collapses to a rail. Apps do not place it themselves, and it draws
  // nothing.
  'AerosSidenavExpanded': 'internal scope set by AerosScaffold for its drawer',
};

/// Exported non-widget classes that are still required in the gallery,
/// because they are how something visible is shown.
const _alsoRequired = <String>{
  // Static API: `AerosSnackbar.show(context, …)`.
  'AerosSnackbar',
};

/// What a class has to extend to count as a widget: Flutter's widget bases,
/// or another Aeros class (an Aeros base, e.g. the menu entries, which are
/// what a menu is built from).
final _widgetClass = RegExp(
  r'^(?:abstract |sealed |final |base )*class\s+([A-Z]\w*)(?:<[^{]*?>)?\s+extends\s+'
  r'(StatelessWidget|StatefulWidget|InheritedWidget|SingleChildRenderObjectWidget|'
  r'MultiChildRenderObjectWidget|LeafRenderObjectWidget|Aeros\w+)\b',
  multiLine: true,
);

final _export = RegExp(r'''^export\s+'([^']+)'\s*(?:show\s+([^;]+))?;''', multiLine: true);

/// The package root, whether the tests run from it or from the repo root.
Directory _packageRoot() {
  var dir = Directory.current.absolute;
  final nested = Directory('${dir.path}/packages/flutter');
  if (File('${nested.path}/lib/aeros_design_system.dart').existsSync()) return nested;
  while (true) {
    if (File('${dir.path}/lib/aeros_design_system.dart').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) throw StateError('cannot find the aeros_design_system package root');
    dir = parent;
  }
}

/// Public widget class name → the exported file that declares it.
Map<String, String> _exportedWidgets(Directory root) {
  final barrel = File('${root.path}/lib/aeros_design_system.dart').readAsStringSync();
  final widgets = <String, String>{};
  for (final match in _export.allMatches(barrel)) {
    final path = match.group(1)!;
    final shown = match.group(2)?.split(',').map((name) => name.trim()).toSet();
    final file = File('${root.path}/lib/$path');
    if (!file.existsSync()) throw StateError('the barrel exports $path, which does not exist');
    for (final declaration in _widgetClass.allMatches(file.readAsStringSync())) {
      final name = declaration.group(1)!;
      if (name.startsWith('_')) continue;
      if (shown != null && !shown.contains(name)) continue;
      widgets[name] = path;
    }
    // Non-widget classes the gallery must show anyway.
    for (final name in _alsoRequired) {
      if (RegExp('^class\\s+$name\\b', multiLine: true).hasMatch(file.readAsStringSync())) widgets[name] = path;
    }
  }
  return widgets;
}

List<File> _gallerySources(Directory root) => Directory('${root.path}/example/lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  final root = _packageRoot();
  final widgets = _exportedWidgets(root);
  final sources = _gallerySources(root);

  test('the barrel is parsed: it exports a plausible number of widgets', () {
    // Guards the parser itself — if the barrel's format changes and nothing
    // is found, the coverage test below would pass vacuously.
    expect(widgets.length, greaterThan(60), reason: 'found only: ${widgets.keys.join(', ')}');
    expect(widgets.keys, containsAll(['AerosButton', 'AerosDataTable', 'AerosMenuItem', 'AerosWholeRows']));
    expect(sources, isNotEmpty, reason: 'no Dart files under example/lib');
  });

  test('every exported widget appears in the example gallery', () {
    final gallery = sources.map((file) => file.readAsStringSync()).join('\n');
    final missing = <String, String>{
      for (final widget in widgets.entries)
        if (!_allowlist.containsKey(widget.key) && !RegExp('\\b${widget.key}\\b').hasMatch(gallery))
          widget.key: widget.value,
    };
    expect(
      missing,
      isEmpty,
      reason: '''

${missing.length} exported widget${missing.length == 1 ? ' is' : 's are'} not shown in the example gallery:

${missing.entries.map((e) => '  • ${e.key}   (lib/${e.value})').join('\n')}

The gallery is the reference usage for app developers, so every exported widget needs an example.
For each name above, do ONE of:
  1. Add an example to the matching page in example/lib/pages/ (one page per family:
     buttons, fields, selection, badges, cards, feedback, navigation, overlays, data, responsive;
     foundations_page.dart for primitives). A new family needs a page and a row in
     example/lib/destinations.dart.
  2. If it is not something an app developer places (a scope, a controller, a model), add it to
     `_allowlist` in test/gallery_coverage_test.dart with the reason.
  3. If it should not be public at all, stop exporting it from lib/aeros_design_system.dart.
''',
    );
  });

  test('the allowlist holds only exported widgets that the gallery really omits', () {
    final gallery = sources.map((file) => file.readAsStringSync()).join('\n');
    for (final name in _allowlist.keys) {
      expect(widgets.containsKey(name), isTrue,
          reason: '$name is allowlisted but is not an exported widget: remove it');
      expect(
        RegExp('\\b$name\\b').hasMatch(gallery),
        isFalse,
        reason: '$name is allowlisted but the gallery shows it: remove it from _allowlist',
      );
    }
  });

  test('the gallery uses the public API only', () {
    final offenders = <String>[];
    final import = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);
    for (final file in sources) {
      final relative = file.path.substring(root.path.length + 1);
      for (final match in import.allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        final private = uri.startsWith('package:aeros_design_system/') &&
            uri != 'package:aeros_design_system/aeros_design_system.dart';
        // A relative path that climbs out of example/ into the package's lib/.
        final reachesIn = !uri.contains(':') && uri.contains('../') && uri.contains('lib/src/');
        if (private || reachesIn) offenders.add('  • $relative imports $uri');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: '''

The example gallery must import the package only through its barrel:
  import 'package:aeros_design_system/aeros_design_system.dart';

${offenders.join('\n')}

If the gallery needs something that only lib/src exposes, that is a missing export: export it from
lib/aeros_design_system.dart (and show it in the gallery) rather than importing the source file.
''',
    );
  });
}
