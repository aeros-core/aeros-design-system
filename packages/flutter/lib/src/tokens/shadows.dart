import 'package:flutter/material.dart';

import 'aeros_theme_tokens.g.dart';

/// Soft layered shadows on neutral black. Every value aliases the generated
/// [AerosShadowTokens] (parsed from the `shadow` block in tokens.json by
/// `pnpm build:tokens`), so web and Flutter cannot drift.
///
/// 3.0: resting surfaces carry a hairline and no shadow; floating layers take
/// theirs from [AerosElevation] through `AerosSurface`. Nothing in the design
/// system reads this class any more.
@Deprecated('Use AerosElevation via context.aerosElevation')
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
}
