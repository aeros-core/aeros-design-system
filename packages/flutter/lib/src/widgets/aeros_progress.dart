import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class AerosProgress extends StatelessWidget {
  const AerosProgress({
    super.key,
    required this.value,
    this.label,
    this.color = AerosColors.royal600,
  });

  final double value; // 0..1
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AerosTypography.caption(color: a.fgSecondary).copyWith(fontWeight: FontWeight.w600)),
              Text('${(value * 100).round()}%', style: AerosTypography.monoSm(color: a.fgMuted)),
            ],
          ),
          const SizedBox(height: 7),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 6,
            backgroundColor: AerosColors.slate100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
