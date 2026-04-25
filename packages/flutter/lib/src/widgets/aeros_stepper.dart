import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Horizontal step indicator. Shows the current step out of `total` steps with
/// a thin progress bar and an optional label like `Step 2 of 5 — Tax details`.
class AerosStepper extends StatelessWidget {
  const AerosStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
    this.color = AerosColors.ink900,
  })  : assert(currentStep >= 0),
        assert(totalSteps >= 1);

  final int currentStep;
  final int totalSteps;
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final clampedStep = currentStep.clamp(0, totalSteps);
    final progress = clampedStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $clampedStep of $totalSteps${label != null ? ' — $label' : ''}',
              style: AerosTypography.caption(color: a.fgSecondary).copyWith(fontWeight: FontWeight.w600),
            ),
            Text('${(progress * 100).round()}%', style: AerosTypography.monoSm(color: a.fgMuted)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AerosColors.ink100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
