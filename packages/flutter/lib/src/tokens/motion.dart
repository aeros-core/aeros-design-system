import 'package:flutter/widgets.dart';
import 'aeros_tokens.g.dart';

class AerosMotion {
  AerosMotion._();

  static const Duration quick = AerosTokens.durationQuick;
  static const Duration fast = AerosTokens.durationFast;
  static const Duration base = AerosTokens.durationBase;
  static const Duration slow = AerosTokens.durationSlow;

  static const Curve standard = AerosTokens.easeStandard;
  static const Curve emphasized = AerosTokens.easeEmphasized;
  static const Curve decelerate = AerosTokens.easeDecelerate;
  // Snappy "settle" for overlays entering; gentle ~6% overshoot for dropdowns/dialogs.
  static const Curve entrance = AerosTokens.easeEntrance;
  static const Curve spring = AerosTokens.easeSpring;

  /// Honors the platform "reduce motion" setting (WCAG 2.3.3): returns
  /// [Duration.zero] when animations are disabled, else [duration].
  /// Use for every AnimatedContainer/AnimatedSwitcher duration.
  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ? Duration.zero : duration;
}
