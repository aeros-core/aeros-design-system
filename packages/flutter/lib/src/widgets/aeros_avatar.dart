import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AerosAvatarSize { xs, sm, md, lg, xl }
enum AerosAvatarTone { royal, dark, green, amber }

class AerosAvatar extends StatelessWidget {
  const AerosAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = AerosAvatarSize.md,
    this.tone = AerosAvatarTone.royal,
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

  ({Color bg, Color fg, Color border}) _palette() {
    switch (tone) {
      case AerosAvatarTone.royal: return (bg: AerosColors.royal50, fg: AerosColors.royal800, border: AerosColors.royal100);
      case AerosAvatarTone.dark:  return (bg: AerosColors.slate800, fg: AerosColors.slate200, border: AerosColors.slate800);
      case AerosAvatarTone.green: return (bg: AerosColors.successBg, fg: AerosColors.successText, border: AerosColors.successBorder);
      case AerosAvatarTone.amber: return (bg: AerosColors.warningBg, fg: AerosColors.warningText, border: AerosColors.warningBorder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette();
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
          ? Text(initials!, style: AerosTypography.bodyMd(color: p.fg).copyWith(fontSize: _font, fontWeight: FontWeight.w700))
          : null,
    );
  }
}
