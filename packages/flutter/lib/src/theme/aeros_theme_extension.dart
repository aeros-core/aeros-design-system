import 'package:flutter/material.dart';
import '../tokens/aeros_theme_tokens.g.dart';

/// Exposes the Aeros alias colours, status colours and elevation that don't
/// fit into Material's ColorScheme.
///
/// Usage:
/// ```dart
/// final ext = Theme.of(context).extension<AerosThemeExtension>()!;
/// Container(color: ext.aliases.bgSurface, ...);
/// ```
/// or, shorter, `context.aerosColors`, `context.aerosSemantic` and
/// `context.aerosElevation`.
@immutable
class AerosThemeExtension extends ThemeExtension<AerosThemeExtension> {
  /// [semantic] and [elevation] default to the set matching [isDark].
  const AerosThemeExtension({
    required this.aliases,
    required this.isDark,
    AerosSemanticColors? semantic,
    AerosElevation? elevation,
  })  : semantic = semantic ?? (isDark ? AerosSemanticColors.dark : AerosSemanticColors.light),
        elevation = elevation ?? (isDark ? AerosElevation.dark : AerosElevation.light);

  final AerosAliasColors aliases;

  /// Status colours (success / warning / danger / info) for this theme.
  final AerosSemanticColors semantic;

  /// Shadows for the surfaces that float (see `AerosSurface`).
  final AerosElevation elevation;
  final bool isDark;

  static const AerosThemeExtension light = AerosThemeExtension(
    aliases: AerosAliasColors.light,
    semantic: AerosSemanticColors.light,
    elevation: AerosElevation.light,
    isDark: false,
  );
  static const AerosThemeExtension dark = AerosThemeExtension(
    aliases: AerosAliasColors.dark,
    semantic: AerosSemanticColors.dark,
    elevation: AerosElevation.dark,
    isDark: true,
  );

  @override
  AerosThemeExtension copyWith({
    AerosAliasColors? aliases,
    AerosSemanticColors? semantic,
    AerosElevation? elevation,
    bool? isDark,
  }) {
    return AerosThemeExtension(
      aliases: aliases ?? this.aliases,
      semantic: semantic ?? this.semantic,
      elevation: elevation ?? this.elevation,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AerosThemeExtension lerp(ThemeExtension<AerosThemeExtension>? other, double t) {
    if (other is! AerosThemeExtension) return this;
    // Interpolate colours and shadows so a theme switch animates; brightness
    // itself is binary and flips at the midpoint.
    return AerosThemeExtension(
      aliases: AerosAliasColors.lerp(aliases, other.aliases, t),
      semantic: AerosSemanticColors.lerp(semantic, other.semantic, t),
      elevation: AerosElevation.lerp(elevation, other.elevation, t),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AerosThemeContext on BuildContext {
  AerosThemeExtension get aeros =>
      Theme.of(this).extension<AerosThemeExtension>() ?? AerosThemeExtension.light;
  AerosAliasColors get aerosColors => aeros.aliases;

  /// Theme-aware status colors (success/warning/danger/info sets).
  AerosSemanticColors get aerosSemantic => aeros.semantic;

  /// Shadows for floating surfaces (raised / overlay / modal).
  AerosElevation get aerosElevation => aeros.elevation;
}
