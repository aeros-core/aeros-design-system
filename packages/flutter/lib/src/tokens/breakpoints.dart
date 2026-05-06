import 'package:flutter/widgets.dart';

import 'aeros_viewport_scope.dart';

/// Named viewport breakpoints for the Aeros DS.
///
/// `xs` is phone, `sm` is tablet portrait, `md` is the desktop sidebar
/// threshold (matches `AerosWebShell.desktopBreakpoint = 900`), `lg` is
/// the standard laptop, `xl` is wide monitors.
enum AerosBreakpoint { xs, sm, md, lg, xl }

class AerosBreakpoints {
  AerosBreakpoints._();

  static const double xs = 0;
  static const double sm = 600;
  static const double md = 900;
  static const double lg = 1200;
  static const double xl = 1600;

  /// Resolves the current breakpoint.
  ///
  /// Reads the real viewport width from the nearest [AerosViewportScope]
  /// ancestor — required when an app shell (e.g. `AerosWebShell`) clamps
  /// `MediaQuery.size` to a phone width for `ScreenUtil` compatibility,
  /// because `MediaQuery.of(context).size.width` then returns the clamped
  /// value, not the real browser width.
  ///
  /// Falls back to `MediaQuery.of(context).size.width` when no
  /// `AerosViewportScope` is in the tree (native mobile, tablet web
  /// outside any web shell).
  static AerosBreakpoint of(BuildContext context) {
    final scope = AerosViewportScope.of(context);
    final width = scope?.width ?? MediaQuery.of(context).size.width;
    return forWidth(width);
  }

  static AerosBreakpoint forWidth(double width) {
    if (width >= xl) return AerosBreakpoint.xl;
    if (width >= lg) return AerosBreakpoint.lg;
    if (width >= md) return AerosBreakpoint.md;
    if (width >= sm) return AerosBreakpoint.sm;
    return AerosBreakpoint.xs;
  }

  static bool isAtLeast(BuildContext context, AerosBreakpoint bp) {
    return of(context).index >= bp.index;
  }

  static bool isBelow(BuildContext context, AerosBreakpoint bp) {
    return of(context).index < bp.index;
  }
}
