import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Compound that wraps any input widget with a consistent
/// label / required-marker / helper-text / error-text layout.
///
/// Use it for inputs that don't already include their own label rendering
/// (e.g. [AerosCheckbox], [AerosRadio], [AerosSwitch], date pickers,
/// composite controls). [AerosTextField], [AerosSelect] and
/// [AerosDropdownSearch] take `label` / `helperText` / `errorText` / `required`
/// themselves (and draw them with this widget); passing them through it as
/// well will double up — pass them directly instead.
class AerosFormField extends StatelessWidget {
  const AerosFormField({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
    this.required = false,
    this.trailing,
    this.labelGap = AerosSpacing.s2,
    this.expand = true,
  });

  final Widget child;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool required;

  /// Optional widget rendered to the right of the label (e.g. info icon, badge).
  final Widget? trailing;

  /// Space between the label and [child]. Field-like inputs use
  /// [AerosSpacing.s1_5], the gap [AerosTextField] has.
  final double labelGap;

  /// True (the default) fills the width given, [child] included. False hugs
  /// the content, start-aligned — for a group that is as wide as what it
  /// holds (a row of chips), and the only form that works where the width is
  /// unbounded.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final semantic = context.aerosSemantic;
    final hasLabel = label != null;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasHelper = !hasError && helperText != null && helperText!.isNotEmpty;

    return Column(
      crossAxisAlignment: expand ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel) ...[
          Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Flexible(
                fit: expand ? FlexFit.tight : FlexFit.loose,
                child: RichText(
                  text: TextSpan(
                    text: label!,
                    style: AerosTypography.labelSm(color: a.fgSecondary),
                    children: [
                      if (required)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: semantic.danger),
                        ),
                    ],
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: labelGap),
        ],
        child,
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            errorText!,
            style: AerosTypography.caption(color: semantic.dangerText),
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
