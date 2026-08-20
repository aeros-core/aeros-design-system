import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_field_size.dart';
import 'aeros_tag.dart';

/// A cohesive tag editor: removable chips and an inline input inside one
/// bordered field surface (replacing an ad-hoc `Wrap` of loose chips + a bare
/// `TextField`). Type and press enter — or space / comma — to add a tag; tap a
/// chip (or its ✕) to remove it; backspace on an empty input removes the last.
///
/// Normalization (strip the leading [prefixSymbol], trim, length-cap, dedupe,
/// count-cap) lives here so callers stop re-implementing it. The cleaned list is
/// surfaced through [onChanged].
class AerosTagField extends StatefulWidget {
  const AerosTagField({
    super.key,
    required this.tags,
    required this.onChanged,
    this.label,
    this.hint = 'Add tag',
    this.prefixSymbol = '#',
    this.maxTags = 50,
    this.maxTagLength = 60,
    this.size = AerosFieldSize.md,
    this.enabled = true,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? label;
  final String hint;

  /// A symbol shown dimmed before the input and stripped from typed values so a
  /// user never has to type it (defaults to `#`).
  final String prefixSymbol;
  final int? maxTags;
  final int? maxTagLength;
  final AerosFieldSize size;
  final bool enabled;

  @override
  State<AerosTagField> createState() => _AerosTagFieldState();
}

class _AerosTagFieldState extends State<AerosTagField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus != _focused) setState(() => _focused = _focus.hasFocus);
  }

  void _add(String raw) {
    var tag = raw.trim();
    while (widget.prefixSymbol.isNotEmpty && tag.startsWith(widget.prefixSymbol)) {
      tag = tag.substring(widget.prefixSymbol.length).trim();
    }
    _controller.clear();
    if (tag.isEmpty) {
      _focus.requestFocus();
      return;
    }
    final maxLen = widget.maxTagLength;
    if (maxLen != null && tag.length > maxLen) tag = tag.substring(0, maxLen);
    final cap = widget.maxTags ?? (1 << 30);
    if (!widget.tags.contains(tag) && widget.tags.length < cap) {
      widget.onChanged([...widget.tags, tag]);
    }
    _focus.requestFocus();
  }

  void _remove(String tag) =>
      widget.onChanged([for (final t in widget.tags) if (t != tag) t]);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.tags.isNotEmpty) {
      _remove(widget.tags.last);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final s = widget.size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AerosTypography.labelSm(color: a.fgSecondary)),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: AerosMotion.resolve(context, AerosMotion.fast),
          curve: AerosMotion.standard,
          constraints: BoxConstraints(minHeight: s.height),
          padding: EdgeInsets.symmetric(
              horizontal: s.padH - 2, vertical: AerosSpacing.s2),
          decoration: BoxDecoration(
            color: widget.enabled ? a.bgSurface : a.bgSubtle,
            borderRadius: s.radius,
            border: Border.all(
              color: _focused ? a.brandPrimary : a.borderDefault,
            ),
            boxShadow: _focused
                ? [BoxShadow(color: a.focusRing.withValues(alpha: 0.14), spreadRadius: 3)]
                : null,
          ),
          child: Wrap(
            spacing: AerosSpacing.s2,
            runSpacing: AerosSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final t in widget.tags)
                AerosTag(
                  label: '${widget.prefixSymbol}$t',
                  tone: AerosTagTone.neutral,
                  pill: true,
                  onRemove: widget.enabled ? () => _remove(t) : null,
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 88),
                child: IntrinsicWidth(
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      enabled: widget.enabled,
                      textInputAction: TextInputAction.done,
                      style: s.valueStyle(color: a.fgPrimary),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        isDense: true,
                        border: InputBorder.none,
                        hintText:
                            '${widget.prefixSymbol.isNotEmpty ? '${widget.prefixSymbol} ' : ''}${widget.hint}',
                        hintStyle: s.valueStyle(color: a.fgMuted),
                        hintMaxLines: 1,
                      ),
                      onChanged: (v) {
                        if (v.endsWith(' ') || v.endsWith(',')) {
                          _add(v.substring(0, v.length - 1));
                        }
                      },
                      onSubmitted: _add,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
