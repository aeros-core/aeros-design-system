// Test configuration for the golden suite only. Flutter picks this file up for
// every test in this directory (and below), so the rest of the suite keeps the
// default test font.
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final package = _packageRoot();
  await _loadFont(
    'packages/aeros_design_system/Inter',
    File('${package.path}/assets/fonts/InterVariable.ttf'),
  );
  // Both mono faces go into one family; the engine picks by weight.
  await _loadFamily('packages/aeros_design_system/IBM Plex Mono', [
    File('${package.path}/assets/fonts/IBMPlexMono-Regular.ttf'),
    File('${package.path}/assets/fonts/IBMPlexMono-Medium.ttf'),
  ]);
  await _loadFont(
    'packages/aeros_design_system/AerosWordmark',
    File('${package.path}/assets/fonts/AerosWordmark-NunitoSansExpanded-Medium.ttf'),
  );

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _loadFont(
      'MaterialIcons',
      File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'),
    );
  } else {
    stderr.writeln('golden: FLUTTER_ROOT is not set; icons will render as boxes.');
  }

  await testMain();
}

Future<void> _loadFont(String family, File file) => _loadFamily(family, [file]);

Future<void> _loadFamily(String family, List<File> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    if (!file.existsSync()) {
      stderr.writeln('golden: font not found, "$family" will render as boxes: ${file.path}');
      return;
    }
    final bytes = await file.readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// The package root (the directory holding this package's pubspec.yaml),
/// whatever directory the tests were started from.
Directory _packageRoot() {
  var dir = Directory.current.absolute;
  // Started from the repo root or above: step down into the package.
  final nested = Directory('${dir.path}/packages/flutter');
  if (_isPackageRoot(nested)) return nested;
  // Started from the package root or somewhere inside it: walk up.
  while (true) {
    if (_isPackageRoot(dir)) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('golden: cannot find the aeros_design_system package root from ${Directory.current.path}');
}

bool _isPackageRoot(Directory dir) {
  final pubspec = File('${dir.path}/pubspec.yaml');
  return pubspec.existsSync() && pubspec.readAsStringSync().contains('name: aeros_design_system');
}
