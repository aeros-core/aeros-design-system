import 'package:flutter/material.dart';
import 'aeros_tokens.g.dart';

// The theme-aware colour sets are generated whole from tokens.json, so a new
// alias or status colour appears here without a hand edit.
export 'aeros_theme_tokens.g.dart' show AerosAliasColors, AerosSemanticColors;

/// Aeros color ramps and semantic colors.
/// Every value aliases the generated [AerosTokens] constants (emitted from
/// `packages/tokens/src/tokens.json` by `pnpm build:tokens`) — the hand-drift
/// this file used to accumulate is structurally impossible now. CI rebuilds
/// tokens and fails if `aeros_tokens.g.dart` is stale.
class AerosColors {
  AerosColors._();

  // ─── Ink (cool neutral — the only ramp) ───
  static const Color ink0   = AerosTokens.ink0;
  static const Color ink50  = AerosTokens.ink50;
  static const Color ink100 = AerosTokens.ink100;
  static const Color ink200 = AerosTokens.ink200;
  static const Color ink300 = AerosTokens.ink300;
  static const Color ink400 = AerosTokens.ink400;
  static const Color ink500 = AerosTokens.ink500;
  static const Color ink600 = AerosTokens.ink600;
  static const Color ink700 = AerosTokens.ink700;
  static const Color ink800 = AerosTokens.ink800;
  static const Color ink850 = AerosTokens.ink850;
  static const Color ink900 = AerosTokens.ink900;
  static const Color ink950 = AerosTokens.ink950;

  // ─── Semantic (light values — prefer AerosSemanticColors for theme-aware use) ───
  static const Color success       = AerosTokens.success;
  static const Color successBg     = AerosTokens.successBg;
  static const Color successText   = AerosTokens.successText;
  static const Color successBorder = AerosTokens.successBorder;

  static const Color warning       = AerosTokens.warning;
  static const Color warningBg     = AerosTokens.warningBg;
  static const Color warningText   = AerosTokens.warningText;
  static const Color warningBorder = AerosTokens.warningBorder;

  static const Color danger        = AerosTokens.danger;
  static const Color dangerBg      = AerosTokens.dangerBg;
  static const Color dangerText    = AerosTokens.dangerText;
  static const Color dangerBorder  = AerosTokens.dangerBorder;

  static const Color info          = AerosTokens.info;
  static const Color infoBg        = AerosTokens.infoBg;
  static const Color infoText      = AerosTokens.infoText;
  static const Color infoBorder    = AerosTokens.infoBorder;
}
