import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_field_frame.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A text input in the shared field frame ([AerosFieldFrame]): `bgSurface`
/// fill, a 1px `borderStrong` hairline that stays 1px, the control radius and
/// the focus ring. An error turns the border, the ring and the message to the
/// theme's danger colours; a disabled field dims as a whole.
class AerosTextField extends StatefulWidget {
  const AerosTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.keyboardType,
    this.required = false,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.size = AerosControlSize.md,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  /// Inline leading widget (usually an [Icon]). Rendered snug against the text.
  final Widget? prefix;

  /// Inline trailing widget (usually an [Icon] or a small button).
  final Widget? suffix;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool required;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Control size — the same ladder, and so the same height, as [AerosButton].
  final AerosControlSize size;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AerosTextField> createState() => _AerosTextFieldState();
}

class _AerosTextFieldState extends State<AerosTextField> {
  FocusNode? _internalFocus;
  bool _focused = false;

  FocusNode get _focus => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant AerosTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _internalFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
      _onFocus();
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocus)?.removeListener(_onFocus);
    _internalFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus != _focused) setState(() => _focused = _focus.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final semantic = context.aerosSemantic;
    final size = widget.size;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasHelper = !hasError && widget.helperText != null && widget.helperText!.isNotEmpty;
    final multiline = !widget.obscureText && ((widget.maxLines ?? 2) > 1 || (widget.minLines ?? 1) > 1);

    Widget affix(Widget child) => IconTheme.merge(
          data: IconThemeData(color: a.fgMuted, size: size.iconSize),
          child: child,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: AerosTypography.labelSm(color: a.fgSecondary),
              children: [
                if (widget.required) TextSpan(text: ' *', style: TextStyle(color: semantic.danger)),
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s1_5),
        ],
        AerosFieldFrame(
          size: size,
          focused: _focused,
          hasError: hasError,
          enabled: widget.enabled,
          // A multi-line field needs its own breathing room; a single line is
          // centred in the control height.
          padding: EdgeInsets.symmetric(
            horizontal: size.padH,
            vertical: multiline ? AerosSpacing.s2 : AerosSpacing.s0,
          ),
          onTap: _focus.requestFocus,
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                affix(widget.prefix!),
                SizedBox(width: size.gap),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  minLines: widget.minLines,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  textInputAction: widget.textInputAction,
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.enableSuggestions,
                  textCapitalization: widget.textCapitalization,
                  inputFormatters: widget.inputFormatters,
                  style: size.valueStyle(color: a.fgPrimary),
                  cursorColor: a.fgPrimary,
                  decoration: AerosFieldFrame.bareDecoration(
                    hintText: widget.hint,
                    hintStyle: size.valueStyle(color: a.fgMuted),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                SizedBox(width: size.gap),
                affix(widget.suffix!),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(widget.errorText!, style: AerosTypography.caption(color: semantic.dangerText)),
        ] else if (hasHelper) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(widget.helperText!, style: AerosTypography.caption(color: a.fgMuted)),
        ],
      ],
    );
  }
}
