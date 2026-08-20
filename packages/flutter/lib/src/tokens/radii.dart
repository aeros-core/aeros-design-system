import 'package:flutter/widgets.dart';
import 'aeros_tokens.g.dart';

/// Radii — alias the generated [AerosTokens] constants.
class AerosRadii {
  AerosRadii._();

  static const double none = AerosTokens.radiusNone;
  static const double xs = AerosTokens.radiusXs;
  static const double sm = AerosTokens.radiusSm;
  static const double md = AerosTokens.radiusMd;
  static const double lg = AerosTokens.radiusLg;
  static const double xl = AerosTokens.radiusXl;
  static const double xl2 = AerosTokens.radius2xl;
  static const double xl3 = AerosTokens.radius3xl;
  static const double xl4 = AerosTokens.radius4xl;
  static const double full = AerosTokens.radiusFull;

  static const BorderRadius brNone = BorderRadius.zero;
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXl2 = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius brXl3 = BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius brXl4 = BorderRadius.all(Radius.circular(xl4));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}
