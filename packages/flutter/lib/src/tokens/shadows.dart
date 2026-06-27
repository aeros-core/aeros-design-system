import 'package:flutter/material.dart';

/// Two-layer soft shadows (ambient + key) on neutral black, mirroring the
/// `shadow` block in tokens.json. Light-mode values; in dark mode elevation is
/// carried by the lighter surface fills (bgSurface → bgElevated), not shadow.
class AerosShadows {
  AerosShadows._();

  // color 0xNN0A0A0A — NN is the alpha byte (rgba(10,10,10, NN/255)).
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0A0A0A0A), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D0A0A0A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F0A0A0A), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0D0A0A0A), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x120A0A0A), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x0F0A0A0A), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x170A0A0A), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x120A0A0A), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x1F0A0A0A), blurRadius: 48, offset: Offset(0, 24)),
  ];

  /// Soft focus ring (light). Use as a spread-only BoxShadow halo so focus
  /// never shifts layout.
  static const List<BoxShadow> focus = [
    BoxShadow(color: Color(0x290A0A0A), blurRadius: 0, spreadRadius: 3),
  ];

  static const List<BoxShadow> focusDanger = [
    BoxShadow(color: Color(0x2EDC2626), blurRadius: 0, spreadRadius: 3),
  ];

  /// A crisp 1px edge drawn as a shadow (no layout border).
  static const List<BoxShadow> hairline = [
    BoxShadow(color: Color(0x100A0A0A), blurRadius: 0, spreadRadius: 1),
  ];

  // ─── Brightness-aware intents ───
  // Light mode floats surfaces with shadow; dark mode carries elevation via
  // the lighter surface fills (bgSurface -> bgElevated), so shadows are off.
  static List<BoxShadow> card(bool isDark) => isDark ? const [] : sm;
  static List<BoxShadow> menu(bool isDark) => isDark ? const [] : lg;
  static List<BoxShadow> dialog(bool isDark) => isDark ? const [] : xl;
  static List<BoxShadow> popover(bool isDark) => isDark ? const [] : md;
}
