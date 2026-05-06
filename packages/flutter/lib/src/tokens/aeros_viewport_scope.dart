import 'package:flutter/widgets.dart';

/// Publishes a viewport width override to descendants.
///
/// Required when an ancestor (e.g. `AerosWebShell._ContentPanel`)
/// overrides `MediaQuery` to a clamped phone-sized width so that
/// `ScreenUtil` and percentage-based widgets size against a phone
/// viewport. In that subtree, `MediaQuery.of(context).size.width`
/// returns the clamped value, not the real browser width — and any
/// breakpoint resolution that consults `MediaQuery` would resolve
/// to the wrong breakpoint.
///
/// The shell wraps its content in `AerosViewportScope(width:
/// realViewportWidth, child: ...)` *above* the MediaQuery clamp.
/// `AerosBreakpoints.of(context)` consults this first, falling back
/// to `MediaQuery.of(context).size.width` when no scope is in the
/// tree (native mobile, tablet web outside the shell).
///
/// ### Usage by app shells
///
/// ```dart
/// AerosViewportScope(
///   width: MediaQuery.of(context).size.width, // real, pre-clamp width
///   child: _ContentPanel(
///     child: MediaQuery(
///       data: ...copyWith(size: Size(480, height)),  // ScreenUtil clamp
///       child: screen,
///     ),
///   ),
/// )
/// ```
class AerosViewportScope extends InheritedWidget {
  const AerosViewportScope({
    Key? key,
    required this.width,
    required Widget child,
  }) : super(key: key, child: child);

  /// The real (un-clamped) viewport width that breakpoint logic should
  /// consult. Use the actual browser width here, not the MediaQuery
  /// override that may have been applied below this scope.
  final double width;

  static AerosViewportScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AerosViewportScope>();
  }

  @override
  bool updateShouldNotify(AerosViewportScope oldWidget) =>
      oldWidget.width != width;
}
