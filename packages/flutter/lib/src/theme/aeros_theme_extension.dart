import 'package:flutter/material.dart';
import '../tokens/colors.dart';

/// Exposes Aeros alias colors + ramps that don't fit into Material's ColorScheme.
///
/// Usage:
/// ```dart
/// final ext = Theme.of(context).extension<AerosThemeExtension>()!;
/// Container(color: ext.aliases.bgSurface, ...);
/// ```
@immutable
class AerosThemeExtension extends ThemeExtension<AerosThemeExtension> {
  const AerosThemeExtension({required this.aliases, required this.isDark});

  final AerosAliasColors aliases;
  final bool isDark;

  static const AerosThemeExtension light =
      AerosThemeExtension(aliases: AerosAliasColors.light, isDark: false);
  static const AerosThemeExtension dark =
      AerosThemeExtension(aliases: AerosAliasColors.dark, isDark: true);

  @override
  AerosThemeExtension copyWith({AerosAliasColors? aliases, bool? isDark}) {
    return AerosThemeExtension(
      aliases: aliases ?? this.aliases,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AerosThemeExtension lerp(ThemeExtension<AerosThemeExtension>? other, double t) {
    if (other is! AerosThemeExtension) return this;
    // Interpolate the colours so a theme switch animates; brightness itself is
    // binary and flips at the midpoint.
    return AerosThemeExtension(
      aliases: AerosAliasColors.lerp(aliases, other.aliases, t),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AerosThemeContext on BuildContext {
  AerosThemeExtension get aeros =>
      Theme.of(this).extension<AerosThemeExtension>() ?? AerosThemeExtension.light;
  AerosAliasColors get aerosColors => aeros.aliases;

  /// Theme-aware status colors (success/warning/danger/info sets).
  AerosSemanticColors get aerosSemantic => AerosSemanticColors.resolve(aeros.isDark);
}
