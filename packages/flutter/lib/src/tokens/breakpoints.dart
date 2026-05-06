import 'package:flutter/widgets.dart';

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

  /// Resolves the current breakpoint from `MediaQuery.of(context).size.width`.
  ///
  /// Inside the Aeros web shell's content panel the published width is
  /// clamped (so `ScreenUtil` keeps phone scaling); screens that have
  /// opted out via `AerosDesktopWrap` / `WebDesktopScope` see the real
  /// viewport width and resolve to the right breakpoint here.
  static AerosBreakpoint of(BuildContext context) {
    return forWidth(MediaQuery.of(context).size.width);
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
