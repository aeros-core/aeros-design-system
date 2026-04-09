import 'package:flutter/animation.dart';

class AerosMotion {
  AerosMotion._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve emphasized = Cubic(0.3, 0, 0, 1);
  static const Curve decelerate = Cubic(0, 0, 0, 1);
}
