import 'package:flutter/widgets.dart';
import 'aeros_tokens.g.dart';

class AerosMotion {
  AerosMotion._();

  static const Duration quick = AerosTokens.durationQuick;
  static const Duration fast = AerosTokens.durationFast;
  static const Duration base = AerosTokens.durationBase;
  static const Duration slow = AerosTokens.durationSlow;

  static const Curve standard = AerosTokens.easeStandard;
  /// Overlays entering: a quick settle.
  static const Curve enter = AerosTokens.easeEnter;

  /// Overlays leaving: accelerate out.
  static const Curve exit = AerosTokens.easeExit;

  /// Honors the platform "reduce motion" setting (WCAG 2.3.3): returns
  /// [Duration.zero] when animations are disabled, else [duration].
  /// Use for every AnimatedContainer/AnimatedSwitcher duration.
  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ? Duration.zero : duration;
}
