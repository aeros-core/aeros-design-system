import 'package:flutter/animation.dart';

class AerosMotion {
  AerosMotion._();

  static const Duration quick = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve emphasized = Cubic(0.3, 0, 0, 1);
  static const Curve decelerate = Cubic(0, 0, 0, 1);
  // Snappy "settle" for overlays entering; gentle ~6% overshoot for dropdowns/dialogs.
  static const Curve entrance = Cubic(0.16, 1, 0.3, 1);
  static const Curve spring = Cubic(0.34, 1.4, 0.64, 1);
}
