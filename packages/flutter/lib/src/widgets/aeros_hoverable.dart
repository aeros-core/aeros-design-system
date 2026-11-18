import 'package:flutter/widgets.dart';

import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';

/// Reports whether a mouse pointer is over it, so cards and list rows can
/// render desktop-only hover affordances without boilerplate at every
/// call-site.
///
/// A thin wrapper over [AerosPressable]: with [onTap] the whole area is a
/// button (hand cursor, Enter / Space, announced to screen readers, the focus
/// ring on keyboard focus). Without one it only tracks the pointer. For
/// pressed and focus states as well, use [AerosPressable] directly.
///
/// ```dart
/// AerosHoverable(
///   onTap: () => navigate(),
///   builder: (context, hovered) => AerosSurface(
///     color: AerosStateLayer.resolve(context.aerosColors, context.aerosColors.bgSurface, hovered: hovered),
///     child: ...,
///   ),
/// )
/// ```
class AerosHoverable extends StatelessWidget {
  const AerosHoverable({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor,
  });

  final Widget Function(BuildContext context, bool isHovered) builder;
  final VoidCallback? onTap;

  /// Defaults to `SystemMouseCursors.click` when [onTap] is set, else
  /// `SystemMouseCursors.basic`.
  final MouseCursor? cursor;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    if (onTap == null) {
      return AerosPressable.hover(
        cursor: cursor ?? SystemMouseCursors.basic,
        builder: (context, state) => builder(context, state.hovered),
      );
    }
    return AerosPressable(
      onPressed: onTap,
      cursor: cursor,
      // The builder decides the size; nothing is added around it.
      expandHitTarget: false,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        child: builder(context, state.hovered),
      ),
    );
  }
}
