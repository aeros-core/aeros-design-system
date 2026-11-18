import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/typography.dart';

/// 3.0: the token ladder — 20 / 24 / 32 / 40 / 56 (was 24 / 30 / 38 / 48 / 60).
enum AerosAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl;

  /// Diameter, from the `avatar*` size tokens.
  double get dimension => switch (this) {
        AerosAvatarSize.xs => AerosSizeTokens.avatarXs,
        AerosAvatarSize.sm => AerosSizeTokens.avatarSm,
        AerosAvatarSize.md => AerosSizeTokens.avatarMd,
        AerosAvatarSize.lg => AerosSizeTokens.avatarLg,
        AerosAvatarSize.xl => AerosSizeTokens.avatarXl,
      };
}

/// 2.0: tones renamed to intent (was ink/dark/royal/green/amber).
enum AerosAvatarTone { neutral, inverse, info, success, warning }

/// A person or an organisation: a circle with initials, or an image over them.
///
/// The diameter comes from the avatar size tokens ([AerosAvatarSize.dimension])
/// and the border is a 1px hairline in the tone's border colour.
class AerosAvatar extends StatelessWidget {
  const AerosAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = AerosAvatarSize.md,
    this.tone = AerosAvatarTone.neutral,
    this.semanticLabel,
  });

  final String? initials;
  final String? imageUrl;
  final AerosAvatarSize size;
  final AerosAvatarTone tone;

  /// Announced instead of the initials — the person's name.
  final String? semanticLabel;

  TextStyle _initialsStyle(Color color) => switch (size) {
        AerosAvatarSize.xs || AerosAvatarSize.sm => AerosTypography.labelXs(color: color),
        AerosAvatarSize.md => AerosTypography.labelSm(color: color),
        AerosAvatarSize.lg => AerosTypography.labelMd(color: color),
        AerosAvatarSize.xl => AerosTypography.h2(color: color, weight: FontWeight.w500),
      };

  // Every tone resolves from the theme; status tints have true dark
  // counterparts via AerosSemanticColors.
  ({Color bg, Color fg, Color border}) _palette(AerosAliasColors a, AerosSemanticColors s) {
    return switch (tone) {
      AerosAvatarTone.neutral => (bg: a.bgSubtle, fg: a.fgPrimary, border: a.borderDefault),
      AerosAvatarTone.inverse => (bg: a.brandPrimary, fg: a.fgInverse, border: a.brandPrimary),
      AerosAvatarTone.info => (bg: s.infoBg, fg: s.infoText, border: s.infoBorder),
      AerosAvatarTone.success => (bg: s.successBg, fg: s.successText, border: s.successBorder),
      AerosAvatarTone.warning => (bg: s.warningBg, fg: s.warningText, border: s.warningBorder),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context.aerosColors, context.aerosSemantic);
    // The tinted circle + initials always render underneath; the network image
    // paints over them, so a broken URL degrades to the initials fallback
    // instead of throwing.
    final avatar = Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        color: p.bg,
        shape: BoxShape.circle,
        border: Border.all(color: p.border, width: AerosMetricTokens.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (initials != null)
            Center(
              child: Text(
                initials!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: _initialsStyle(p.fg),
              ),
            ),
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
    if (semanticLabel == null) return avatar;
    return Semantics(label: semanticLabel, image: true, excludeSemantics: true, child: avatar);
  }
}
