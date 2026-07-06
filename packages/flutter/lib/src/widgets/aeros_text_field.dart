import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'aeros_field_size.dart';

class AerosTextField extends StatelessWidget {
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
    this.size = AerosFieldSize.md,
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

  /// Inline leading widget (usually an [Icon]). Rendered snug against the text —
  /// NOT boxed to Material's 48px `prefixIcon` slot.
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

  /// Control size — snaps the field onto the [AerosButton] height/radius ladder.
  final AerosFieldSize size;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    // A snug affix box: kill Material's 48px prefix/suffix slot so an icon sits
    // tight against the text and no longer inflates the field height.
    final affixConstraints = BoxConstraints(
      minWidth: size.padH + size.iconSize + 8,
      minHeight: 0,
    );

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: size.radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AerosTypography.labelSm(color: a.fgSecondary),
              children: [
                if (required)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AerosColors.danger)),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: size.valueStyle(color: a.fgPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? a.bgSurface : a.bgSubtle,
            hintText: hint,
            hintStyle: size.valueStyle(color: a.fgMuted),
            contentPadding:
                EdgeInsets.symmetric(horizontal: size.padH, vertical: size.padV),
            prefixIcon: prefix,
            suffixIcon: suffix,
            prefixIconConstraints: affixConstraints,
            suffixIconConstraints: affixConstraints,
            errorText: errorText,
            helperText: helperText,
            hintMaxLines: 1,
            border: border(a.borderDefault),
            enabledBorder: border(a.borderDefault),
            focusedBorder: border(a.brandPrimary, width: 1.5),
            disabledBorder: border(a.borderSubtle),
            errorBorder: border(AerosColors.danger),
            focusedErrorBorder: border(AerosColors.danger, width: 1.5),
          ),
        ),
      ],
    );
  }
}
