import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AerosAvatarSize { xs, sm, md, lg, xl }
enum AerosAvatarTone { ink, dark, royal, green, amber }

class AerosAvatar extends StatelessWidget {
  const AerosAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = AerosAvatarSize.md,
    this.tone = AerosAvatarTone.ink,
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

  // Neutral tones (ink/dark/royal) resolve from the theme; green/amber stay
  // fixed semantics.
  ({Color bg, Color fg, Color border}) _palette(AerosAliasColors a) {
    switch (tone) {
      case AerosAvatarTone.ink:   return (bg: a.bgSubtle,          fg: a.fgPrimary,            border: a.borderDefault);
      case AerosAvatarTone.dark:  return (bg: a.brandPrimary,      fg: a.fgInverse,            border: a.brandPrimary);
      case AerosAvatarTone.royal: return (bg: a.brandPrimaryMuted, fg: a.fgPrimary,            border: a.borderDefault);
      case AerosAvatarTone.green: return (bg: AerosColors.successBg, fg: AerosColors.successText, border: AerosColors.successBorder);
      case AerosAvatarTone.amber: return (bg: AerosColors.warningBg, fg: AerosColors.warningText, border: AerosColors.warningBorder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context.aerosColors);
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
