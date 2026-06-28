import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Compound that wraps any input widget with a consistent
/// label / required-marker / helper-text / error-text layout.
///
/// Use it for inputs that don't already include their own label rendering
/// (e.g. [AerosCheckbox], [AerosRadio], [AerosSwitch], date pickers,
/// composite controls). [AerosTextField] and [AerosDropdownSearch] already
/// render their own labels; passing them through this widget will double
/// up — pass them directly instead.
class AerosFormField extends StatelessWidget {
  const AerosFormField({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
    this.required = false,
    this.trailing,
  });

  final Widget child;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool required;

  /// Optional widget rendered to the right of the label (e.g. info icon, badge).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasLabel = label != null;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasHelper = !hasError && helperText != null && helperText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel) ...[
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: label!,
                    style: AerosTypography.labelSm(color: a.fgSecondary),
                    children: [
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AerosColors.danger),
                        ),
                    ],
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AerosSpacing.s2),
        ],
        child,
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            errorText!,
            style: AerosTypography.caption(color: AerosColors.dangerText),
          ),
        ] else if (hasHelper) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            helperText!,
            style: AerosTypography.caption(color: a.fgMuted),
          ),
        ],
      ],
    );
  }
}
