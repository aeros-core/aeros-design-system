import 'package:flutter/widgets.dart';

/// Wraps a builder with `MouseRegion` and a hover-state flag so cards
/// and list rows can render desktop-only hover affordances without
/// boilerplate at every call-site.
///
/// ```dart
/// AerosHoverable(
///   onTap: () => navigate(),
///   builder: (context, hovered) => AnimatedContainer(
///     duration: AerosMotion.fast,
///     decoration: BoxDecoration(
///       color: hovered ? aeros.bgSubtle : aeros.bgSurface,
///       border: Border.all(color: aeros.borderDefault),
///       borderRadius: AerosRadii.brMd,
///     ),
///     child: ...,
///   ),
/// )
/// ```
class AerosHoverable extends StatefulWidget {
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
  State<AerosHoverable> createState() => _AerosHoverableState();
}

class _AerosHoverableState extends State<AerosHoverable> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _hovered);
    final cursor = widget.cursor ??
        (widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic);
    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: widget.onTap != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: child,
            )
          : child,
    );
  }
}
