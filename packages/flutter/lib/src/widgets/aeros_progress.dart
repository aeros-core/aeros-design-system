import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/typography.dart';

class AerosProgress extends StatelessWidget {
  const AerosProgress({
    super.key,
    this.value,
    this.label,
    this.color,
  });

  /// 0..1, or `null` for an indeterminate bar.
  final double? value;
  final String? label;

  /// Fill colour. Defaults to the theme brand colour so it inverts in dark mode.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final fill = color ?? a.brandPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AerosTypography.caption(color: a.fgSecondary).copyWith(fontWeight: FontWeight.w600)),
              if (value != null)
                Text('${(value! * 100).round()}%', style: AerosTypography.monoSm(color: a.fgMuted)),
            ],
          ),
          const SizedBox(height: 7),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value?.clamp(0, 1),
            minHeight: 6,
            backgroundColor: a.borderDefault,
            valueColor: AlwaysStoppedAnimation(fill),
            semanticsLabel: label,
            semanticsValue: value != null ? '${(value! * 100).round()}%' : null,
          ),
        ),
      ],
    );
  }
}
