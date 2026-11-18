import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AerosTabVariant { underline, pill }

/// Tab strip.
///
/// - [AerosTabVariant.underline]: a 1px baseline hairline under the strip and
///   a 2px `fgPrimary` indicator under the active tab. Tabs are one list row
///   high ([AerosSizeTokens.row]). The strip fills the width it is given (the
///   baseline runs edge to edge); when the tabs do not fit they scroll
///   sideways, the clipped edge fades, and the active tab is brought into
///   view — on first build and whenever the selection changes.
/// - [AerosTabVariant.pill]: a compact segmented track, one control high
///   ([AerosControlSize.md]); the active segment is a `bgElevated` chip with the
///   faintest lift ([AerosElevation.raised]). The track hugs its segments;
///   when they do not fit, the segments share the width equally and their
///   labels truncate.
///
/// The active label is `fgPrimary` at w600, the others `fgSecondary` at w500;
/// hover changes colour only. Keyboard-operable: Tab reaches the strip, Enter /
/// Space activates the focused tab (which draws the focus ring), and ← / →
/// (mirrored in right-to-left), Home and End move the selection while any tab
/// has focus — and the focus moves with it, so the ring stays on the selected
/// tab.
class AerosTabs extends StatefulWidget {
  const AerosTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = AerosTabVariant.underline,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final AerosTabVariant variant;

  @override
  State<AerosTabs> createState() => _AerosTabsState();
}

class _AerosTabsState extends State<AerosTabs> {
  static const BorderRadius _item = BorderRadius.all(Radius.circular(AerosShapeTokens.item));
  static const BorderRadius _control = BorderRadius.all(Radius.circular(AerosShapeTokens.control));

  /// Width of the fade over a clipped edge of the underline strip.
  static const double _fade = AerosSpacing.s6;

  final ScrollController _scroll = ScrollController();

  // Keeps the scroll view (and its offset) when the fade is wrapped around it.
  final GlobalKey _stripKey = GlobalKey(debugLabel: 'AerosTabs strip');
  List<FocusNode> _nodes = const [];
  List<GlobalKey> _keys = const [];

  // Whether tabs are scrolled out of view past the start / the end.
  bool _clippedStart = false;
  bool _clippedEnd = false;

  @override
  void initState() {
    super.initState();
    _syncTabs();
    _revealSelected(animate: false);
  }

  @override
  void didUpdateWidget(AerosTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) _syncTabs();
    if (oldWidget.selectedIndex != widget.selectedIndex || oldWidget.tabs.length != widget.tabs.length) {
      _revealSelected(animate: true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncTabs() {
    final count = widget.tabs.length;
    for (final node in _nodes.skip(count)) {
      node.dispose();
    }
    _nodes = [
      for (var i = 0; i < count; i++) i < _nodes.length ? _nodes[i] : FocusNode(debugLabel: 'AerosTabs tab $i'),
    ];
    _keys = [
      for (var i = 0; i < count; i++) i < _keys.length ? _keys[i] : GlobalKey(debugLabel: 'AerosTabs tab $i'),
    ];
  }

  /// Scrolls the underline strip so the selected tab is in view.
  void _revealSelected({required bool animate}) {
    if (widget.variant != AerosTabVariant.underline) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = widget.selectedIndex;
      if (index < 0 || index >= _keys.length) return;
      final target = _keys[index].currentContext;
      if (target == null || !_scroll.hasClients) return;
      final box = target.findRenderObject();
      if (box == null) return;
      final position = _scroll.position;
      // Leave the faded edge clear of the tab, where there is more to scroll to.
      final viewport = RenderAbstractViewport.of(box);
      final atStart = (viewport.getOffsetToReveal(box, 0).offset - _fade).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      final atEnd = (viewport.getOffsetToReveal(box, 1).offset + _fade).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      final double to;
      if (position.pixels > atStart) {
        to = atStart;
      } else if (position.pixels < atEnd) {
        to = atEnd;
      } else {
        return;
      }
      final duration = animate ? AerosMotion.resolve(context, AerosMotion.base) : Duration.zero;
      if (duration == Duration.zero) {
        position.jumpTo(to);
      } else {
        position.animateTo(to, duration: duration, curve: AerosMotion.standard);
      }
    });
  }

  bool _onMetrics(ScrollMetrics metrics) {
    final start = metrics.extentBefore > 0.5;
    final end = metrics.extentAfter > 0.5;
    if (start != _clippedStart || end != _clippedEnd) {
      // Reported during layout: rebuild after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _clippedStart = start;
          _clippedEnd = end;
        });
      });
    }
    return false;
  }

  void _select(int next) {
    if (widget.tabs.isEmpty) return;
    final index = next.clamp(0, widget.tabs.length - 1);
    if (index != widget.selectedIndex) widget.onChanged(index);
    // Roving focus: the ring follows the selection.
    _nodes[index].requestFocus();
  }

  void _step(int delta) => _select(widget.selectedIndex + delta);

  TextStyle _label(AerosAliasColors a, {required bool active, required AerosInteraction state}) =>
      AerosTypography.labelSm(
        color: active || state.hovered || state.pressed ? a.fgPrimary : a.fgSecondary,
        weight: active ? FontWeight.w600 : FontWeight.w500,
      );

  Widget _pressable({
    required int index,
    required AerosPressableBuilder builder,
  }) =>
      AerosPressable(
        key: _keys[index],
        focusNode: _nodes[index],
        onPressed: () => widget.onChanged(index),
        selected: index == widget.selectedIndex,
        inMutuallyExclusiveGroup: true,
        // The tab is already a full row (or the full track) high.
        expandHitTarget: false,
        builder: builder,
      );

  Widget _underline(BuildContext context) {
    final a = context.aerosColors;
    final height = AerosDensity.of(context).sizes.row;
    final tabs = widget.tabs;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    Widget strip = NotificationListener<ScrollMetricsNotification>(
      key: _stripKey,
      onNotification: (notification) => _onMetrics(notification.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) => _onMetrics(notification.metrics),
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _pressable(
                  index: i,
                  builder: (context, state) {
                    final active = i == widget.selectedIndex;
                    return AerosFocusRing(
                      focused: state.focused,
                      radius: _item,
                      placement: AerosFocusRingPlacement.inset,
                      child: SizedBox(
                        height: height,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
                              child: Text(
                                tabs[i],
                                maxLines: 1,
                                softWrap: false,
                                style: _label(a, active: active, state: state),
                              ),
                            ),
                            if (active)
                              PositionedDirectional(
                                start: 0,
                                end: 0,
                                bottom: 0,
                                height: AerosMetricTokens.borderThick,
                                child: ColoredBox(color: a.fgPrimary),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (_clippedStart || _clippedEnd) {
      // Fades the tabs themselves, so it works on any surface. The baseline
      // sits outside the mask and stays whole.
      final fadeLeft = rtl ? _clippedEnd : _clippedStart;
      final fadeRight = rtl ? _clippedStart : _clippedEnd;
      strip = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final stop = bounds.width <= 0 ? 0.0 : math.min(0.5, _fade / bounds.width);
          const opaque = Color(0xFFFFFFFF);
          const clear = Color(0x00FFFFFF);
          return LinearGradient(
            colors: [fadeLeft ? clear : opaque, opaque, opaque, fadeRight ? clear : opaque],
            stops: [0, stop, 1 - stop, 1],
          ).createShader(bounds);
        },
        child: strip,
      );
    }

    return Stack(
      children: [
        // The baseline: the active indicator is drawn over it.
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          height: AerosMetricTokens.borderHairline,
          child: ColoredBox(color: a.borderDefault),
        ),
        // Fills the width it is given (so the baseline runs edge to edge) and
        // hugs the tabs where the width is unbounded.
        Align(alignment: AlignmentDirectional.centerStart, heightFactor: 1, child: strip),
      ],
    );
  }

  Widget _segmented(BuildContext context) {
    final a = context.aerosColors;
    const gap = AerosSpacing.s0_5;
    final tabs = widget.tabs;
    // The track's hairline and inset, and the segment's own hairline, come
    // off the control height.
    final segment =
        AerosControlSize.md.resolveHeight(context) - (AerosMetricTokens.borderHairline * 2 + gap) * 2;
    return Container(
      padding: const EdgeInsets.all(gap),
      decoration: BoxDecoration(
        // A recessed track: darker than the page in dark mode, so the active
        // segment (bgElevated) reads as lifted in both themes.
        color: a.bgInset,
        border: Border.all(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
        borderRadius: _control,
      ),
      child: _Segments(
        gap: gap,
        textDirection: Directionality.of(context),
        children: [
          for (var i = 0; i < tabs.length; i++)
            _pressable(
              index: i,
              builder: (context, state) {
                final active = i == widget.selectedIndex;
                final label = SizedBox(
                  height: segment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        tabs[i],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: _label(a, active: active, state: state),
                      ),
                    ),
                  ),
                );
                return AerosFocusRing(
                  focused: state.focused,
                  radius: _item,
                  placement: AerosFocusRingPlacement.inset,
                  child: active
                      ? AerosSurface(
                          level: AerosSurfaceLevel.raised,
                          radius: _item,
                          color: a.bgElevated,
                          borderColor: a.borderDefault,
                          child: label,
                        )
                      : AerosStateFill(
                          color: AerosStateLayer.resolve(
                            a,
                            a.bgInset,
                            hovered: state.hovered,
                            pressed: state.pressed,
                          ),
                          radius: _item,
                          child: label,
                        ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // Arrow keys move the selection while focus is anywhere inside the strip.
    return FocusTraversalGroup(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(rtl ? 1 : -1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(rtl ? -1 : 1),
          const SingleActivator(LogicalKeyboardKey.home): () => _select(0),
          const SingleActivator(LogicalKeyboardKey.end): () => _select(widget.tabs.length - 1),
        },
        child: widget.variant == AerosTabVariant.underline ? _underline(context) : _segmented(context),
      ),
    );
  }
}

/// The segments of a pill track in a row: each at its own width while they
/// all fit, sharing the width equally when they do not.
class _Segments extends MultiChildRenderObjectWidget {
  const _Segments({required this.gap, required this.textDirection, required super.children});

  final double gap;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSegments(gap: gap, textDirection: textDirection);

  @override
  void updateRenderObject(BuildContext context, _RenderSegments renderObject) {
    renderObject
      ..gap = gap
      ..textDirection = textDirection;
  }
}

class _SegmentParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSegments extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SegmentParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SegmentParentData> {
  _RenderSegments({required double gap, required TextDirection textDirection})
      : _gap = gap,
        _textDirection = textDirection;

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SegmentParentData) child.parentData = _SegmentParentData();
  }

  double get _gaps => childCount > 1 ? _gap * (childCount - 1) : 0;

  /// Sizes every child; returns their sizes in order and the row's size.
  (List<Size>, Size) _compute(BoxConstraints constraints, Size Function(RenderBox, BoxConstraints) layout) {
    final heights = BoxConstraints(maxHeight: constraints.maxHeight);
    var sizes = <Size>[];
    var natural = _gaps;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final size = layout(child, heights);
      sizes.add(size);
      natural += size.width;
    }
    if (natural > constraints.maxWidth && childCount > 0) {
      // Do not fit: equal shares, and the labels truncate.
      final share = math.max(0.0, (constraints.maxWidth - _gaps) / childCount);
      final tight = BoxConstraints(minWidth: share, maxWidth: share, maxHeight: constraints.maxHeight);
      sizes = <Size>[];
      natural = _gaps;
      for (var child = firstChild; child != null; child = childAfter(child)) {
        final size = layout(child, tight);
        sizes.add(size);
        natural += size.width;
      }
    }
    final height = sizes.fold<double>(0, (h, s) => math.max(h, s.height));
    return (sizes, constraints.constrain(Size(natural, height)));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _compute(constraints, ChildLayoutHelper.dryLayoutChild).$2;

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = _gaps;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width += child.getMinIntrinsicWidth(height);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = _gaps;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width += child.getMaxIntrinsicWidth(height);
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) => computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      height = math.max(height, child.getMaxIntrinsicHeight(double.infinity));
    }
    return height;
  }

  @override
  void performLayout() {
    final (sizes, total) = _compute(constraints, ChildLayoutHelper.layoutChild);
    size = total;
    final rtl = _textDirection == TextDirection.rtl;
    var x = 0.0;
    var i = 0;
    for (var child = firstChild; child != null; child = childAfter(child), i++) {
      final childSize = sizes[i];
      (child.parentData! as _SegmentParentData).offset = Offset(
        rtl ? size.width - x - childSize.width : x,
        (size.height - childSize.height) / 2,
      );
      x += childSize.width + _gap;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
