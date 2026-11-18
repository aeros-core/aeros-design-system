import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_field_frame.dart';
import '../foundation/aeros_pressable.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/motion.dart';

/// A compact search input for lists and toolbars.
///
/// A single control that retires the two hand-rolled search boxes (notes list,
/// graph top bar). It sits in the same frame as every other field
/// ([AerosFieldFrame]) — a leading search glyph, an animated clear affix that
/// appears once there's a query, and, crucially,
/// [autocorrect] / [enableSuggestions] **off by default** so a search box never
/// "corrects" jargon (`pgvector` → `of vector`) and the iOS suggestion strip
/// never swallows taps on the results beneath it.
///
/// It adopts a caller-provided [controller] / [focusNode] or manages its own.
class AerosSearchField extends StatefulWidget {
  const AerosSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.size = AerosControlSize.md,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction = TextInputAction.search,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear affix wipes the field (in addition to
  /// `onChanged('')`), so callers can also reset their query state.
  final VoidCallback? onClear;

  final AerosControlSize size;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final bool enabled;

  @override
  State<AerosSearchField> createState() => _AerosSearchFieldState();
}

class _AerosSearchFieldState extends State<AerosSearchField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocus;
  bool _hasText = false;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant AerosSearchField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      // The previously-active controller may be the internal one (null → non-null
      // swap) — detach from whichever actually held the listener.
      (old.controller ?? _internalController)?.removeListener(_onText);
      _controller.addListener(_onText);
      _onText();
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _internalFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
      _onFocus();
    }
  }

  @override
  void dispose() {
    (widget.controller ?? _internalController)?.removeListener(_onText);
    (widget.focusNode ?? _internalFocus)?.removeListener(_onFocus);
    _internalController?.dispose();
    _internalFocus?.dispose();
    super.dispose();
  }

  void _onText() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _onFocus() {
    if (_focus.hasFocus != _focused) setState(() => _focused = _focus.hasFocus);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final s = widget.size;
    // The clear affix is as wide as the field is tall and fills its height
    // inside the hairline, so it is a full-size target at the field's edge.
    final height = s.resolveHeight(context);
    final affixHeight = height - 2 * AerosMetricTokens.borderHairline;

    return AerosFieldFrame(
      size: s,
      focused: _focused,
      enabled: widget.enabled,
      padding: EdgeInsetsDirectional.only(start: s.padH),
      onTap: _focus.requestFocus,
      child: Row(
        children: [
          Icon(Icons.search, size: s.iconSize, color: a.fgMuted),
          SizedBox(width: s.gap),
          Expanded(
            child: CallbackShortcuts(
              // Escape clears the query — expected desktop-search behavior.
              // With nothing to clear the key is left alone, so it still
              // closes the dialog or menu the field sits in.
              bindings: {
                if (_hasText) const SingleActivator(LogicalKeyboardKey.escape): _clear,
              },
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                autocorrect: widget.autocorrect,
                enableSuggestions: widget.enableSuggestions,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                style: s.valueStyle(color: a.fgPrimary),
                cursorColor: a.fgPrimary,
                decoration: AerosFieldFrame.bareDecoration(
                  hintText: widget.hint,
                  hintStyle: s.valueStyle(color: a.fgMuted),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AerosMotion.resolve(context, AerosMotion.fast),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
            child: _hasText && widget.enabled
                ? AerosPressable(
                    key: const ValueKey('clear'),
                    onPressed: _clear,
                    semanticLabel: 'Clear search',
                    excludeSemantics: true,
                    // Inside the field: the field's own height is the target.
                    expandHitTarget: false,
                    builder: (context, state) => SizedBox(
                      width: height,
                      height: affixHeight,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: s.iconSize,
                          color: state.hovered || state.pressed || state.focused ? a.fgPrimary : a.fgMuted,
                        ),
                      ),
                    ),
                  )
                : SizedBox(key: const ValueKey('empty'), width: s.padH, height: affixHeight),
          ),
        ],
      ),
    );
  }
}
