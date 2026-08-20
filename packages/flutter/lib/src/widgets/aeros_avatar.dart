import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AerosAvatarSize { xs, sm, md, lg, xl }

/// 2.0: tones renamed to intent (was ink/dark/royal/green/amber).
enum AerosAvatarTone { neutral, inverse, info, success, warning }

class AerosAvatar extends StatelessWidget {
  const AerosAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = AerosAvatarSize.md,
    this.tone = AerosAvatarTone.neutral,
  });

  final String? initials;
  final String? imageUrl;
  final AerosAvatarSize size;
  final AerosAvatarTone tone;

  double get _dim => switch (size) {
        AerosAvatarSize.xs => 24,
        AerosAvatarSize.sm => 30,
        AerosAvatarSize.md => 38,
        AerosAvatarSize.lg => 48,
        AerosAvatarSize.xl => 60,
      };

  double get _font => switch (size) {
        AerosAvatarSize.xs => 9,
        AerosAvatarSize.sm => 11,
        AerosAvatarSize.md => 13,
        AerosAvatarSize.lg => 16,
        AerosAvatarSize.xl => 20,
      };

  // Every tone resolves from the theme; status tints have true dark
  // counterparts via AerosSemanticColors.
  ({Color bg, Color fg, Color border}) _palette(AerosAliasColors a, AerosSemanticColors s) {
    switch (tone) {
      case AerosAvatarTone.neutral: return (bg: a.bgSubtle,          fg: a.fgPrimary, border: a.borderDefault);
      case AerosAvatarTone.inverse: return (bg: a.brandPrimary,      fg: a.fgInverse, border: a.brandPrimary);
      case AerosAvatarTone.info:    return (bg: a.brandPrimaryMuted, fg: a.fgPrimary, border: a.borderDefault);
      case AerosAvatarTone.success: return (bg: s.successBg, fg: s.successText, border: s.successBorder);
      case AerosAvatarTone.warning: return (bg: s.warningBg, fg: s.warningText, border: s.warningBorder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context.aerosColors, context.aerosSemantic);
    return Container(
      width: _dim,
      height: _dim,
      decoration: BoxDecoration(
        color: p.bg,
        shape: BoxShape.circle,
        border: Border.all(color: p.border, width: 1.5),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null && initials != null
          ? Text(initials!, style: AerosTypography.labelMd(color: p.fg).copyWith(fontSize: _font))
          : null,
    );
  }
}
