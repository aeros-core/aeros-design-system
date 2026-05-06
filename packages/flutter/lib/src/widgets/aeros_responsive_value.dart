import 'package:flutter/widgets.dart';
import '../tokens/breakpoints.dart';

/// Per-breakpoint value with cascading fallback.
///
/// Use to declare a single property's value across breakpoints inline:
///
/// ```dart
/// AerosResponsiveValue<int>(xs: 1, sm: 2, md: 3, lg: 4).resolve(context)
/// ```
///
/// `xs` is required; the rest fall back to the closest defined value
/// below them, so `AerosResponsiveValue<int>(xs: 1, md: 4)` resolves to
/// `1` at sm and `4` at md/lg/xl.
@immutable
class AerosResponsiveValue<T> {
  const AerosResponsiveValue({
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
  });

  /// Same value at every breakpoint.
  const AerosResponsiveValue.all(T value)
      : xs = value,
        sm = value,
        md = value,
        lg = value,
        xl = value;

  final T xs;
  final T? sm;
  final T? md;
  final T? lg;
  final T? xl;

  T resolve(BuildContext context) => resolveFor(AerosBreakpoints.of(context));

  T resolveFor(AerosBreakpoint bp) {
    switch (bp) {
      case AerosBreakpoint.xl:
        return xl ?? lg ?? md ?? sm ?? xs;
      case AerosBreakpoint.lg:
        return lg ?? md ?? sm ?? xs;
      case AerosBreakpoint.md:
        return md ?? sm ?? xs;
      case AerosBreakpoint.sm:
        return sm ?? xs;
      case AerosBreakpoint.xs:
        return xs;
    }
  }
}
