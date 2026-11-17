import 'package:flutter/material.dart';

import 'aeros_theme_tokens.g.dart';

/// Soft layered shadows on neutral black. Every value aliases the generated
/// [AerosShadowTokens] (parsed from the `shadow` block in tokens.json by
/// `pnpm build:tokens`), so web and Flutter cannot drift.
///
/// Light-mode values; in dark mode elevation is carried by the lighter surface
/// fills (bgSurface → bgElevated), not shadow — see the intents below.
class AerosShadows {
  AerosShadows._();

  static const List<BoxShadow> xs = AerosShadowTokens.xs;
  static const List<BoxShadow> sm = AerosShadowTokens.sm;
  static const List<BoxShadow> md = AerosShadowTokens.md;
  static const List<BoxShadow> lg = AerosShadowTokens.lg;
  static const List<BoxShadow> xl = AerosShadowTokens.xl;

  /// Soft focus ring (light). Use as a spread-only BoxShadow halo so focus
  /// never shifts layout.
  static const List<BoxShadow> focus = AerosShadowTokens.focus;
  static const List<BoxShadow> focusDanger = AerosShadowTokens.focusDanger;
  static const List<BoxShadow> focusSuccess = AerosShadowTokens.focusSuccess;

  /// A crisp 1px edge drawn as a shadow (no layout border).
  static const List<BoxShadow> hairline = AerosShadowTokens.hairline;

  // ─── Brightness-aware intents ───
  // Light mode floats surfaces with shadow; dark mode carries elevation via
  // the lighter surface fills (bgSurface -> bgElevated), so shadows are off.
  static List<BoxShadow> card(bool isDark) => isDark ? const [] : sm;
  static List<BoxShadow> menu(bool isDark) => isDark ? const [] : lg;
  static List<BoxShadow> dialog(bool isDark) => isDark ? const [] : xl;
  static List<BoxShadow> popover(bool isDark) => isDark ? const [] : md;
}
