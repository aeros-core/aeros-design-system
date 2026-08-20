import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import 'aeros_field_size.dart';

/// A compact search input for lists and toolbars.
///
/// A single control that retires the two hand-rolled search boxes (notes list,
/// graph top bar). It reads as a calm, recessed pill — a leading search glyph,
/// an animated clear affix that appears once there's a query, and, crucially,
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
    this.size = AerosFieldSize.md,
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

  final AerosFieldSize size;
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

    return AnimatedContainer(
      duration: AerosMotion.fast,
      curve: AerosMotion.standard,
      height: s.height,
      padding: EdgeInsets.symmetric(horizontal: s.padH),
      decoration: BoxDecoration(
        color: _focused ? a.bgSurface : a.bgSubtle,
        borderRadius: AerosRadii.brLg,
        border: Border.all(
          color: _focused ? a.brandPrimary : Colors.transparent,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: a.focusRing.withValues(alpha: 0.14), spreadRadius: 3)]
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: s.iconSize, color: a.fgMuted),
          const SizedBox(width: AerosSpacing.s2),
          Expanded(
            child: CallbackShortcuts(
              // Escape clears the query — expected desktop-search behavior.
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  if (_hasText) _clear();
                },
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
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: s.valueStyle(color: a.fgMuted),
                  hintMaxLines: 1,
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AerosMotion.fast,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
            // Labeled button semantics + a full-height, ≥36dp-wide hit target
            // (the bare 18dp glyph was unlabeled and sub-target before).
            child: _hasText
                ? Semantics(
                    key: const ValueKey('clear'),
                    button: true,
                    label: 'Clear search',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _clear,
                      child: SizedBox(
                        width: 36,
                        height: double.infinity,
                        child: Center(
                          child: ExcludeSemantics(
                            child: Icon(Icons.close, size: s.iconSize, color: a.fgMuted),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
