import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosTagTone { blue, grey, dark }

class AerosTag extends StatelessWidget {
  const AerosTag({super.key, required this.label, this.tone = AerosTagTone.grey});

  final String label;
  final AerosTagTone tone;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    Color bg, fg;
    Color? border;
    switch (tone) {
      case AerosTagTone.blue:
        bg = a.brandPrimaryMuted;
        fg = a.fgPrimary;
        break;
      case AerosTagTone.grey:
        bg = a.bgSubtle;
        fg = a.fgSecondary;
        border = a.borderDefault;
        break;
      case AerosTagTone.dark:
        bg = a.bgInverse;
        fg = a.fgInverse;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AerosRadii.brMd,
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(label, style: AerosTypography.caption(color: fg).copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
