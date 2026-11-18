import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shell.dart';

/// The gallery app: the Aeros themes, and the two settings the top bar
/// changes live — the theme mode and the input density.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, this.initialThemeMode = ThemeMode.system, this.initialDensity, this.initialPage});

  final ThemeMode initialThemeMode;

  /// Null picks by platform: touch on phones and tablets, pointer elsewhere.
  final AerosDensity? initialDensity;

  /// The id of the page to open on (see `destinations.dart`).
  final String? initialPage;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;
  late AerosDensity _density = widget.initialDensity ?? _platformDensity();

  static AerosDensity _platformDensity() => switch (defaultTargetPlatform) {
        TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => AerosDensity.touch,
        _ => AerosDensity.pointer,
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aeros Design System',
      debugShowCheckedModeBanner: false,
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      themeMode: _themeMode,
      // The scope sits above the Navigator, so dialogs, sheets and menus are
      // sized for the same density as the page that opened them.
      builder: (context, child) => AerosDensityScope(density: _density, child: child!),
      home: GalleryShell(
        initialPage: widget.initialPage,
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        density: _density,
        onDensityChanged: (density) => setState(() => _density = density),
      ),
    );
  }
}
