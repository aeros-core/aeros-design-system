import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosTagTone { blue, grey, slate }

class AerosTag extends StatelessWidget {
  const AerosTag({super.key, required this.label, this.tone = AerosTagTone.grey});

  final String label;
  final AerosTagTone tone;

  @override
  Widget build(BuildContext context) {
    Color bg, fg; Color? border;
    switch (tone) {
      case AerosTagTone.blue:
        bg = AerosColors.royal50; fg = AerosColors.royal800; break;
      case AerosTagTone.grey:
        bg = AerosColors.ink50; fg = AerosColors.ink600; border = AerosColors.ink100; break;
      case AerosTagTone.slate:
        bg = AerosColors.slate800; fg = AerosColors.slate200; break;
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
