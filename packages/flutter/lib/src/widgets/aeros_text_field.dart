import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

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
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AerosTypography.bodySm(color: a.fgSecondary).copyWith(fontWeight: FontWeight.w600),
              children: [
                if (required)
                  const TextSpan(text: ' *', style: TextStyle(color: AerosColors.danger)),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AerosTypography.bodyMd(color: a.fgPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            errorText: errorText,
            helperText: helperText,
          ),
        ),
      ],
    );
  }
}
