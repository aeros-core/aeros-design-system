import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A progress bar: a 4px pill track with a `brandPrimary` fill, and an
/// optional label row above it.
///
/// With a [value] it is announced as a progress bar with a numeric value
/// (0–100) and the [label]; without one it is an indeterminate, looping bar.
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

  /// Track height: the 4px spacing step.
  static const double trackHeight = AerosSpacing.s1;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final fill = color ?? a.brandPrimary;
    final clamped = value?.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          // The bar itself announces the label and the value.
          ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AerosTypography.labelSm(color: a.fgSecondary),
                  ),
                ),
                if (clamped != null) ...[
                  const SizedBox(width: AerosSpacing.s2),
                  Text('${(clamped * 100).round()}%', style: AerosTypography.monoSm(color: a.fgMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s1_5),
        ],
        // No `semanticsValue`: the indicator then reports the rounded
        // percentage as a bare number between its min (0) and max (100),
        // which is what a progress bar's semantics must be. A string like
        // "35%" there fails Flutter's semantics check in debug builds.
        LinearProgressIndicator(
          value: clamped,
          minHeight: trackHeight,
          borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
          backgroundColor: a.borderDefault,
          valueColor: AlwaysStoppedAnimation(fill),
          semanticsLabel: label,
        ),
      ],
    );
  }
}
