import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Single-select dropdown for an ENUM-source attribute.
///
/// Use this when the option list is long (>6) or labels are wide. For 2–6
/// short options prefer [AerosEnumChips]. For very long async lists,
/// consumers can drop down to the lower-level [AerosDropdownSearch] directly.
class AerosEnumDropdown extends StatelessWidget {
  const AerosEnumDropdown({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.label,
    this.hint = 'Select…',
    this.required = false,
    this.enabled = true,
    this.errorText,
  });

  final List<AerosAttributeOption> options;
  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  final String? label;
  final String hint;
  final bool required;
  final bool enabled;
  final String? errorText;

  AerosAttributeOption? get _selected {
    if (selectedId == null) return null;
    for (final o in options) {
      if (o.id == selectedId) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final picked = _selected;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? AerosColors.danger : a.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AerosTypography.bodySm(color: a.fgSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
              children: [
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AerosColors.danger),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s2),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? a.bgSurface : a.bgSubtle,
            borderRadius: AerosRadii.brMd,
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: picked?.id,
              isExpanded: true,
              hint: Text(
                hint,
                style: AerosTypography.bodyMd(color: a.fgMuted),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: a.fgMuted),
              style: AerosTypography.bodyMd(color: a.fgPrimary),
              dropdownColor: a.bgSurface,
              borderRadius: AerosRadii.brMd,
              onChanged: enabled ? onChanged : null,
              items: [
                for (final o in options)
                  DropdownMenuItem<String?>(
                    value: o.id,
                    enabled: !o.disabled,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.label,
                            style: AerosTypography.bodyMd(
                              color: o.disabled ? a.fgMuted : a.fgPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (o.disabled && o.disabledReason != null)
                          Text(
                            o.disabledReason!,
                            style: AerosTypography.caption(color: a.fgMuted),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            errorText!,
            style: AerosTypography.caption(color: AerosColors.dangerText),
          ),
        ],
      ],
    );
  }
}
