import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import 'colors.dart';

/// Semantic state tokens for configurable-MTO surfaces.
///
/// These extend [AerosAliasColors] / [AerosSemanticColors] with intent-named
/// colours for the states introduced by attribute / variant pickers and
/// pricing surfaces.
///
/// Every palette resolves from the theme: pass the build context (`of`), or
/// the theme's alias and status colour sets (`resolve`). None of them falls
/// back to the light set.

// ─── Severity ────────────────────────────────────────────────────────────

/// Severity scale used by constraint messages and routing-signal badges.
/// Maps to the status ramps in [AerosSemanticColors].
enum AerosSeverity { info, warn, error }

/// Background / foreground / border colour set for a [AerosSeverity].
@immutable
class AerosSeverityPalette {
  const AerosSeverityPalette({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;

  /// The palette for [severity] in the theme of [context].
  static AerosSeverityPalette of(BuildContext context, AerosSeverity severity) =>
      resolve(severity, context.aerosSemantic);

  /// The palette for [severity] from an explicit status colour set
  /// (`context.aerosSemantic`, or `AerosSemanticColors.light` / `.dark`).
  static AerosSeverityPalette resolve(AerosSeverity severity, AerosSemanticColors s) {
    switch (severity) {
      case AerosSeverity.info:
        return AerosSeverityPalette(
          background: s.infoBg,
          foreground: s.infoText,
          border: s.infoBorder,
          icon: Icons.info_outline,
        );
      case AerosSeverity.warn:
        return AerosSeverityPalette(
          background: s.warningBg,
          foreground: s.warningText,
          border: s.warningBorder,
          icon: Icons.warning_amber_outlined,
        );
      case AerosSeverity.error:
        return AerosSeverityPalette(
          background: s.dangerBg,
          foreground: s.dangerText,
          border: s.dangerBorder,
          icon: Icons.error_outline,
        );
    }
  }
}

// ─── Selection states ────────────────────────────────────────────────────

/// State of a selectable item (variant swatch, enum chip, attribute row).
enum AerosSelectionState {
  unselected,
  selected,
  disabled,
  lockedByAdmin,
  requiredButMissing,
}

/// Theme-aware colour set for a [AerosSelectionState].
///
/// Resolved from the current [AerosAliasColors] so the same call works in
/// light and dark themes.
@immutable
class AerosSelectionPalette {
  const AerosSelectionPalette({
    required this.background,
    required this.foreground,
    required this.border,
    this.borderWidth = 1.0,
    this.iconOverlay,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final double borderWidth;

  /// Optional overlay icon (lock for `lockedByAdmin`, asterisk for
  /// `requiredButMissing`).
  final IconData? iconOverlay;

  /// The palette for [state] in the theme of [context].
  static AerosSelectionPalette of(BuildContext context, AerosSelectionState state) =>
      resolve(state, context.aerosColors, context.aerosSemantic);

  /// The palette for [state] from explicit alias and status colour sets.
  static AerosSelectionPalette resolve(
    AerosSelectionState state,
    AerosAliasColors a,
    AerosSemanticColors s,
  ) {
    switch (state) {
      case AerosSelectionState.unselected:
        return AerosSelectionPalette(
          background: a.bgSurface,
          foreground: a.fgPrimary,
          border: a.borderDefault,
        );
      case AerosSelectionState.selected:
        return AerosSelectionPalette(
          background: a.brandPrimaryMuted,
          foreground: a.fgPrimary,
          border: a.fgPrimary,
          borderWidth: 2.0,
        );
      case AerosSelectionState.disabled:
        return AerosSelectionPalette(
          background: a.bgSubtle,
          foreground: a.fgMuted,
          border: a.borderDefault,
        );
      case AerosSelectionState.lockedByAdmin:
        return AerosSelectionPalette(
          background: a.bgSubtle,
          foreground: a.fgSecondary,
          border: a.borderStrong,
          iconOverlay: Icons.lock_outline,
        );
      case AerosSelectionState.requiredButMissing:
        return AerosSelectionPalette(
          background: s.dangerBg,
          foreground: s.dangerText,
          border: s.dangerBorder,
        );
    }
  }
}

// ─── Price tones ─────────────────────────────────────────────────────────

/// Semantic tone for a price line in [AerosPriceBreakdown].
///
/// `discountable` is the regular foreground colour. `nonDiscountable` is a
/// muted slate so buyers can visually distinguish setup fees / shipping
/// from the pieces of their order that respond to bulk discounts.
enum AerosPriceTone { discountable, nonDiscountable, discount }

@immutable
class AerosPricePalette {
  const AerosPricePalette({required this.foreground, required this.label});

  final Color foreground;

  /// Inline label (e.g. "fixed", "discount") rendered alongside the amount.
  final String? label;

  /// The palette for [tone] in the theme of [context].
  static AerosPricePalette of(BuildContext context, AerosPriceTone tone) =>
      resolve(tone, context.aerosColors, context.aerosSemantic);

  /// The palette for [tone] from explicit alias and status colour sets.
  static AerosPricePalette resolve(
    AerosPriceTone tone,
    AerosAliasColors a,
    AerosSemanticColors s,
  ) {
    switch (tone) {
      case AerosPriceTone.discountable:
        return AerosPricePalette(foreground: a.fgPrimary, label: null);
      case AerosPriceTone.nonDiscountable:
        return AerosPricePalette(
          foreground: a.fgMuted,
          label: 'fixed',
        );
      case AerosPriceTone.discount:
        return AerosPricePalette(
          foreground: s.success,
          label: 'discount',
        );
    }
  }
}
