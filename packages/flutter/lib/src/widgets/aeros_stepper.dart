import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_progress.dart';

/// Horizontal step indicator. Shows the current step out of `total` steps with
/// a thin progress bar and an optional label like `Step 2 of 5 — Tax details`.
///
/// The bar is the same 4px pill track as [AerosProgress] and is announced as
/// a progress bar named by the step line.
class AerosStepper extends StatelessWidget {
  const AerosStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
    this.color,
  })  : assert(currentStep >= 0),
        assert(totalSteps >= 1);

  final int currentStep;
  final int totalSteps;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final clampedStep = currentStep.clamp(0, totalSteps);
    final progress = clampedStep / totalSteps;
    final line = 'Step $clampedStep of $totalSteps${label != null ? ' — $label' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The bar announces the step line and the value.
        ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AerosTypography.labelSm(color: a.fgSecondary),
                ),
              ),
              const SizedBox(width: AerosSpacing.s2),
              Text('${(progress * 100).round()}%', style: AerosTypography.monoSm(color: a.fgMuted)),
            ],
          ),
        ),
        const SizedBox(height: AerosSpacing.s1_5),
        LinearProgressIndicator(
          value: progress,
          minHeight: AerosProgress.trackHeight,
          borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
          backgroundColor: a.borderDefault,
          valueColor: AlwaysStoppedAnimation(color ?? a.brandPrimary),
          semanticsLabel: line,
        ),
      ],
    );
  }
}
