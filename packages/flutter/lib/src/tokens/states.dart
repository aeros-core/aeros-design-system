import 'package:flutter/material.dart';
import 'colors.dart';

/// Semantic state tokens for configurable-MTO surfaces.
///
/// These extend the base [AerosColors] / [AerosAliasColors] with intent-named
/// colours for the new states introduced by attribute / variant pickers and
/// pricing surfaces. Keeping them in their own file avoids changing the
/// existing `AerosAliasColors` constructor (which would be a breaking API).
///
/// Tokens are theme-aware where they need to be (selection states), and use
/// fixed semantic ramps where intent is fixed (severity, price tones).

// ─── Severity ────────────────────────────────────────────────────────────

/// Severity scale used by constraint messages and routing-signal badges.
/// Maps to the existing semantic ramps in [AerosColors].
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

  static AerosSeverityPalette of(AerosSeverity severity) {
    switch (severity) {
      case AerosSeverity.info:
        return const AerosSeverityPalette(
          background: AerosColors.infoBg,
          foreground: AerosColors.infoText,
          border: AerosColors.infoBorder,
          icon: Icons.info_outline,
        );
      case AerosSeverity.warn:
        return const AerosSeverityPalette(
          background: AerosColors.warningBg,
          foreground: AerosColors.warningText,
          border: AerosColors.warningBorder,
          icon: Icons.warning_amber_outlined,
        );
      case AerosSeverity.error:
        return const AerosSeverityPalette(
          background: AerosColors.dangerBg,
          foreground: AerosColors.dangerText,
          border: AerosColors.dangerBorder,
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

  static AerosSelectionPalette resolve(
    AerosSelectionState state,
    AerosAliasColors a,
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
        return const AerosSelectionPalette(
          background: AerosColors.dangerBg,
          foreground: AerosColors.dangerText,
          border: AerosColors.dangerBorder,
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

  static AerosPricePalette resolve(
    AerosPriceTone tone,
    AerosAliasColors a,
  ) {
    switch (tone) {
      case AerosPriceTone.discountable:
        return AerosPricePalette(foreground: a.fgPrimary, label: null);
      case AerosPriceTone.nonDiscountable:
        return AerosPricePalette(
          foreground: AerosColors.slate600,
          label: 'fixed',
        );
      case AerosPriceTone.discount:
        return const AerosPricePalette(
          foreground: AerosColors.success,
          label: 'discount',
        );
    }
  }
}
