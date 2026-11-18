import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/aeros_surface.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';

/// The side of the anchor a popover opens on. It flips to the other side when
/// the preferred one has no room.
enum AerosPopoverSide { below, above }

/// How a popover lines up with its anchor along the other axis. `start` and
/// `end` follow the text direction.
enum AerosPopoverAlign { start, center, end }

/// Opens and closes an [AerosPopover] (or an `AerosMenu`) from its trigger.
class AerosPopoverController extends ChangeNotifier {
  VoidCallback? _open;
  VoidCallback? _close;
  bool _isOpen = false;

  /// Whether the popover is showing.
  bool get isOpen => _isOpen;

  void open() => _open?.call();

  void close() => _close?.call();

  void toggle() => _isOpen ? close() : open();

  void _setOpen(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}

/// A floating surface anchored to a trigger: `bgElevated`, the overlay
/// elevation, [AerosShapeTokens.surface] corners, any content.
///
/// It opens below the anchor (or above, with [side]), flips when there is no
/// room and is clamped to the screen. Escape and a tap outside close it, and
/// focus returns to the trigger. `AerosMenu` and `AerosSelect` are built on
/// it.
///
/// ```dart
/// AerosPopover(
///   trigger: (context, popover) => AerosButton.secondary(label: 'Filters', onPressed: popover.toggle),
///   content: (context) => const FilterForm(),
/// )
/// ```
///
/// With no widget to wrap, open one from any context with [AerosPopover.show].
class AerosPopover extends StatefulWidget {
  const AerosPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.controller,
    this.side = AerosPopoverSide.below,
    this.align = AerosPopoverAlign.start,
    this.matchAnchorWidth = false,
    this.padding = const EdgeInsets.all(AerosSpacing.s3),
    this.constraints,
    this.semanticLabel,
    this.onOpenChanged,
  });

  /// Builds the widget the popover is anchored to. Call `controller.toggle`
  /// from it.
  final Widget Function(BuildContext context, AerosPopoverController controller) trigger;

  /// Builds what the popover shows. Pop the route to close it:
  /// `Navigator.of(context).pop()`.
  final WidgetBuilder content;

  /// Supply one to open or close the popover from outside the trigger.
  final AerosPopoverController? controller;
  final AerosPopoverSide side;
  final AerosPopoverAlign align;

  /// Makes the popover at least as wide as its anchor.
  final bool matchAnchorWidth;

  /// Inside the surface.
  final EdgeInsetsGeometry padding;

  /// Extra limits on the surface (it is always kept inside the screen).
  final BoxConstraints? constraints;

  /// Announced when the popover opens.
  final String? semanticLabel;
  final ValueChanged<bool>? onOpenChanged;

  /// The gap between the anchor and the popover.
  static const double gap = AerosSpacing.s1;

  /// The closest a popover gets to the edge of the screen.
  static const double screenMargin = AerosSpacing.s2;

  /// The rectangle of [context]'s render box in the coordinates of the
  /// navigator a popover opened from it is pushed on.
  static Rect anchorRectOf(BuildContext context, {bool useRootNavigator = false}) {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context, rootNavigator: useRootNavigator).overlay!.context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  }

  /// Opens a popover anchored to [context]'s render box (or to [anchorRect],
  /// in the navigator's coordinates) and completes with the value the route
  /// was popped with.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    Rect? anchorRect,
    AerosPopoverSide side = AerosPopoverSide.below,
    AerosPopoverAlign align = AerosPopoverAlign.start,
    bool matchAnchorWidth = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AerosSpacing.s3),
    BoxConstraints? constraints,
    String? semanticLabel,
    bool useRootNavigator = false,
  }) {
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final rect = anchorRect ?? anchorRectOf(context, useRootNavigator: useRootNavigator);
    // Focus goes back to wherever it was when the route closes, so put it on
    // the trigger first.
    _focusTargetWithin(context)?.requestFocus();
    return navigator.push<T>(
      _AerosPopoverRoute<T>(
        builder: builder,
        anchorRect: rect,
        side: side,
        align: align,
        matchAnchorWidth: matchAnchorWidth,
        padding: padding,
        constraints: constraints,
        semanticLabel: semanticLabel,
        textDirection: Directionality.of(context),
        density: context.getInheritedWidgetOfExactType<AerosDensityScope>()?.density,
        themes: InheritedTheme.capture(from: context, to: navigator.context),
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        enter: AerosMotion.resolve(context, AerosMotion.fast),
        exit: AerosMotion.resolve(context, AerosMotion.quick),
      ),
    );
  }

  /// The focusable inside (or right around) [context] — the trigger.
  static FocusNode? _focusTargetWithin(BuildContext context) {
    final scope = FocusScope.of(context, createDependency: false);
    for (final node in scope.traversalDescendants) {
      final nodeContext = node.context;
      if (nodeContext == null) continue;
      var inside = nodeContext == context;
      if (!inside) {
        nodeContext.visitAncestorElements((element) {
          if (element == context) inside = true;
          return !inside;
        });
      }
      if (inside) return node;
    }
    return Focus.maybeOf(context, createDependency: false);
  }

  @override
  State<AerosPopover> createState() => _AerosPopoverState();
}

class _AerosPopoverState extends State<AerosPopover> {
  AerosPopoverController? _internal;
  Route<Object?>? _route;

  AerosPopoverController get _controller => widget.controller ?? (_internal ??= AerosPopoverController());

  @override
  void initState() {
    super.initState();
    _attach(_controller);
  }

  @override
  void didUpdateWidget(AerosPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller ?? _internal);
      _attach(_controller);
    }
  }

  @override
  void dispose() {
    _detach(widget.controller ?? _internal);
    _internal?.dispose();
    super.dispose();
  }

  void _attach(AerosPopoverController controller) {
    controller
      .._open = _open
      .._close = _close;
  }

  void _detach(AerosPopoverController? controller) {
    controller
      ?.._open = null
      .._close = null;
  }

  void _open() {
    if (_route != null || !mounted) return;
    final controller = _controller;
    final navigator = Navigator.of(context);
    controller._setOpen(true);
    widget.onOpenChanged?.call(true);
    AerosPopover.show<Object?>(
      context,
      builder: widget.content,
      side: widget.side,
      align: widget.align,
      matchAnchorWidth: widget.matchAnchorWidth,
      padding: widget.padding,
      constraints: widget.constraints,
      semanticLabel: widget.semanticLabel,
    ).whenComplete(() {
      _route = null;
      controller._setOpen(false);
      if (mounted) widget.onOpenChanged?.call(false);
    });
    // The route just pushed is the navigator's current one.
    navigator.popUntil((route) {
      _route = route;
      return true;
    });
  }

  void _close() {
    final route = _route;
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else {
      route.navigator?.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) => widget.trigger(context, _controller);
}

class _AerosPopoverRoute<T> extends PopupRoute<T> {
  _AerosPopoverRoute({
    required this.builder,
    required this.anchorRect,
    required this.side,
    required this.align,
    required this.matchAnchorWidth,
    required this.padding,
    required this.constraints,
    required this.semanticLabel,
    required this.textDirection,
    required this.density,
    required this.themes,
    required this.barrierLabel,
    required this.enter,
    required this.exit,
  });

  final WidgetBuilder builder;
  final Rect anchorRect;
  final AerosPopoverSide side;
  final AerosPopoverAlign align;
  final bool matchAnchorWidth;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final String? semanticLabel;
  final TextDirection textDirection;
  final AerosDensity? density;
  final CapturedThemes themes;
  final Duration enter;
  final Duration exit;

  /// How far the surface is scaled down when it starts to appear.
  static const double _enterScale = 0.97;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => enter;

  @override
  Duration get reverseTransitionDuration => exit;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final media = MediaQuery.of(context);
    Widget surface = Semantics(
      scopesRoute: true,
      namesRoute: semanticLabel != null,
      label: semanticLabel,
      explicitChildNodes: true,
      child: AerosSurface(
        level: AerosSurfaceLevel.overlay,
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: padding, child: Builder(builder: builder)),
        ),
      ),
    );
    if (constraints != null) surface = ConstrainedBox(constraints: constraints!, child: surface);
    if (density != null) surface = AerosDensityScope(density: density!, child: surface);

    return themes.wrap(
      Directionality(
        textDirection: textDirection,
        child: CustomSingleChildLayout(
          delegate: _PopoverLayout(
            anchor: anchorRect,
            side: side,
            align: align,
            matchAnchorWidth: matchAnchorWidth,
            textDirection: textDirection,
            // Keep clear of the status bar, the home indicator and the keyboard.
            insets: media.padding + media.viewInsets,
          ),
          child: surface,
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AerosMotion.enter, reverseCurve: AerosMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: Tween<double>(begin: _enterScale, end: 1).animate(curved), child: child),
    );
  }
}

/// Places the popover against its anchor: on the preferred side when it fits,
/// otherwise on the side with more room, and always inside the screen.
class _PopoverLayout extends SingleChildLayoutDelegate {
  const _PopoverLayout({
    required this.anchor,
    required this.side,
    required this.align,
    required this.matchAnchorWidth,
    required this.textDirection,
    required this.insets,
  });

  final Rect anchor;
  final AerosPopoverSide side;
  final AerosPopoverAlign align;
  final bool matchAnchorWidth;
  final TextDirection textDirection;
  final EdgeInsets insets;

  static const double _margin = AerosPopover.screenMargin;
  static const double _gap = AerosPopover.gap;

  double _spaceBelow(Size size) => size.height - insets.bottom - _margin - (anchor.bottom + _gap);
  double _spaceAbove(Size size) => anchor.top - _gap - insets.top - _margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final size = constraints.biggest;
    final maxWidth = math.max(0.0, size.width - insets.horizontal - 2 * _margin);
    final maxHeight = math.max(0.0, math.max(_spaceBelow(size), _spaceAbove(size)));
    return BoxConstraints(
      minWidth: matchAnchorWidth ? math.min(anchor.width, maxWidth) : 0,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = _spaceBelow(size);
    final above = _spaceAbove(size);
    final fitsBelow = childSize.height <= below;
    final fitsAbove = childSize.height <= above;
    final placeBelow = switch (side) {
      AerosPopoverSide.below => fitsBelow || (!fitsAbove && below >= above),
      AerosPopoverSide.above => !(fitsAbove || (!fitsBelow && above >= below)),
    };
    final y = placeBelow ? anchor.bottom + _gap : anchor.top - _gap - childSize.height;

    final toLeftEdge = switch (align) {
      AerosPopoverAlign.start => textDirection == TextDirection.ltr,
      AerosPopoverAlign.end => textDirection == TextDirection.rtl,
      AerosPopoverAlign.center => null,
    };
    final x = switch (toLeftEdge) {
      true => anchor.left,
      false => anchor.right - childSize.width,
      null => anchor.center.dx - childSize.width / 2,
    };

    final minX = insets.left + _margin;
    final maxX = size.width - insets.right - _margin - childSize.width;
    final minY = insets.top + _margin;
    final maxY = size.height - insets.bottom - _margin - childSize.height;
    return Offset(
      maxX < minX ? minX : x.clamp(minX, maxX),
      maxY < minY ? minY : y.clamp(minY, maxY),
    );
  }

  @override
  bool shouldRelayout(_PopoverLayout old) =>
      old.anchor != anchor ||
      old.side != side ||
      old.align != align ||
      old.matchAnchorWidth != matchAnchorWidth ||
      old.textDirection != textDirection ||
      old.insets != insets;
}
