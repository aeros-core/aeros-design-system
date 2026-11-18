import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../tokens/density.dart';

/// What the pointer and keyboard are doing to an [AerosPressable].
@immutable
class AerosInteraction {
  const AerosInteraction({
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.enabled = true,
  });

  /// A mouse pointer is over the control.
  final bool hovered;

  /// A pointer is down on the control.
  final bool pressed;

  /// The control has **keyboard** focus (the focus ring should show). False
  /// when focus arrived by tap or click.
  final bool focused;

  final bool enabled;

  bool get disabled => !enabled;

  @override
  bool operator ==(Object other) =>
      other is AerosInteraction &&
      other.hovered == hovered &&
      other.pressed == pressed &&
      other.focused == focused &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(hovered, pressed, focused, enabled);
}

typedef AerosPressableBuilder = Widget Function(BuildContext context, AerosInteraction state);

/// The one interaction primitive under every Aeros control.
///
/// It reports hover, press, keyboard focus and the disabled state to
/// [builder], sets the mouse cursor, activates on Enter and Space, and
/// announces itself to assistive technology. It paints nothing: no ink, no
/// ripple — the builder draws the state (see `AerosStateLayer` and
/// `AerosFocusRing`).
///
/// The tappable box is at least `AerosSizeTokens.minTarget` on each side for
/// the nearest [AerosDensityScope] (24 for a mouse, 44 for fingers). A smaller
/// visual is centred in that box at its own size; turn [expandHitTarget] off
/// for a control that sits inside another target (a clear button in a field).
class AerosPressable extends StatefulWidget {
  const AerosPressable({
    super.key,
    required this.builder,
    required this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.cursor,
    this.expandHitTarget = true,
    this.semanticLabel,
    this.excludeSemantics = false,
    this.button = true,
    this.checked,
    this.mixed,
    this.toggled,
    this.selected,
    this.inMutuallyExclusiveGroup,
  });

  final AerosPressableBuilder builder;

  /// Called on tap, click, Enter or Space. Null disables the control.
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  /// False disables the control even when [onPressed] is set.
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Defaults to a hand over an enabled control and the basic arrow otherwise.
  final MouseCursor? cursor;

  /// Grow the tappable box to the density's minimum target (default true).
  final bool expandHitTarget;

  /// Read in place of (with [excludeSemantics]) or along with the builder's own text.
  final String? semanticLabel;

  /// Drop the semantics of everything the builder returns.
  final bool excludeSemantics;

  // Roles and states announced to assistive technology.
  final bool button;
  final bool? checked;
  final bool? mixed;
  final bool? toggled;
  final bool? selected;
  final bool? inMutuallyExclusiveGroup;

  @override
  State<AerosPressable> createState() => _AerosPressableState();
}

class _AerosPressableState extends State<AerosPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _hasFocus = false;

  /// Focus counts as keyboard focus while the app is in the traditional
  /// (keyboard / mouse) highlight mode — the framework's rule for "show a
  /// focus ring". Tracked here, with hover, rather than through the
  /// detector's highlight callbacks: those miss a mode change that happens
  /// while the control is already hovered or focused.
  bool get _focused => _hasFocus && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  static const Map<ShortcutActivator, Intent> _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
    // The web maps Enter to this intent instead of ActivateIntent.
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _activate()),
  };

  void _activate() {
    if (_enabled) widget.onPressed!();
  }

  void _set({bool? hovered, bool? pressed, bool? hasFocus}) {
    final h = hovered ?? _hovered;
    final p = pressed ?? _pressed;
    final f = hasFocus ?? _hasFocus;
    if (h == _hovered && p == _pressed && f == _hasFocus) return;
    if (!mounted) return;
    setState(() {
      _hovered = h;
      _pressed = p;
      _hasFocus = f;
    });
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    if (mounted && _hasFocus) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(AerosPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A control disabled mid-press must not stay drawn as pressed.
    if (!_enabled && _pressed) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final state = AerosInteraction(
      hovered: enabled && _hovered,
      pressed: enabled && _pressed,
      focused: enabled && _focused,
      enabled: enabled,
    );

    Widget child = widget.builder(context, state);
    if (widget.expandHitTarget) {
      child = _MinHitTarget(minSize: AerosDensity.of(context).sizes.minTarget, child: child);
    }

    return MergeSemantics(
      child: Semantics(
        button: widget.button ? true : null,
        enabled: enabled,
        checked: widget.checked,
        mixed: widget.mixed,
        toggled: widget.toggled,
        selected: widget.selected,
        inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
        label: widget.semanticLabel,
        excludeSemantics: widget.excludeSemantics,
        onTap: enabled ? _activate : null,
        onLongPress: enabled ? widget.onLongPress : null,
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          mouseCursor: widget.cursor ?? (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
          shortcuts: _shortcuts,
          actions: _actions,
          onFocusChange: (value) => _set(hasFocus: value),
          child: MouseRegion(
            onEnter: (_) => _set(hovered: true),
            onExit: (_) => _set(hovered: false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: enabled ? (_) => _set(pressed: true) : null,
              onTapUp: enabled ? (_) => _set(pressed: false) : null,
              onTapCancel: enabled ? () => _set(pressed: false) : null,
              onTap: enabled ? _activate : null,
              onLongPress: enabled ? widget.onLongPress : null,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sizes itself to at least [minSize] on each side and centres its child,
/// which is laid out with the incoming constraints untouched — so the child
/// keeps its own size (or fills, under tight constraints) and only the box
/// around it grows.
class _MinHitTarget extends SingleChildRenderObjectWidget {
  const _MinHitTarget({required this.minSize, required super.child});

  final double minSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMinHitTarget(minSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMinHitTarget renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderMinHitTarget extends RenderShiftedBox {
  _RenderMinHitTarget(this._minSize) : super(null);

  double _minSize;
  double get minSize => _minSize;
  set minSize(double value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsLayout();
  }

  Size _sizeFor(BoxConstraints constraints, Size childSize) => constraints.constrain(
        Size(math.max(childSize.width, _minSize), math.max(childSize.height, _minSize)),
      );

  @override
  double computeMinIntrinsicWidth(double height) => math.max(super.computeMinIntrinsicWidth(height), _minSize);

  @override
  double computeMaxIntrinsicWidth(double height) => math.max(super.computeMaxIntrinsicWidth(height), _minSize);

  @override
  double computeMinIntrinsicHeight(double width) => math.max(super.computeMinIntrinsicHeight(width), _minSize);

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(super.computeMaxIntrinsicHeight(width), _minSize);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _sizeFor(constraints, child?.getDryLayout(constraints) ?? Size.zero);

  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) {
    final c = child;
    if (c == null) return null;
    final result = c.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = c.getDryLayout(constraints);
    return result + (_sizeFor(constraints, childSize).height - childSize.height) / 2;
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = _sizeFor(constraints, Size.zero);
      return;
    }
    c.layout(constraints, parentUsesSize: true);
    size = _sizeFor(constraints, c.size);
    (c.parentData! as BoxParentData).offset = Offset(
      (size.width - c.size.width) / 2,
      (size.height - c.size.height) / 2,
    );
  }
}
