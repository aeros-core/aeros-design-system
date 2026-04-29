import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Chip group for an ENUM-source attribute. Single-select.
///
/// Use this for short option lists (2–6 items) and where labels are short
/// enough to fit a chip. Picks up [AerosAttributeOption.swatchColor] to render
/// a colour swatch in front of each chip — used for colour pickers.
class AerosEnumChips extends StatelessWidget {
  const AerosEnumChips({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.label,
    this.required = false,
    this.requiredButMissing = false,
    this.unitSuffix,
    this.errorText,
  });

  final List<AerosAttributeOption> options;
  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  final String? label;
  final bool required;

  /// When `true`, the chip group renders with the
  /// [AerosSelectionState.requiredButMissing] tone until the buyer picks an
  /// option. Used by [AerosAttributeSelector] when surfacing validation.
  final bool requiredButMissing;

  /// Optional suffix appended to each option label (e.g. `ml`, `gsm`). Use
  /// for MEASUREMENT + ENUM combos where the option is a numeric chip.
  final String? unitSuffix;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;

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
        Wrap(
          spacing: AerosSpacing.s2,
          runSpacing: AerosSpacing.s2,
          children: [
            for (final o in options)
              _Chip(
                option: o,
                selected: o.id == selectedId,
                requiredButMissing: requiredButMissing && selectedId == null,
                unitSuffix: unitSuffix,
                onTap: o.disabled || onChanged == null
                    ? null
                    : () => onChanged!(o.id == selectedId ? null : o.id),
              ),
          ],
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.option,
    required this.selected,
    required this.requiredButMissing,
    required this.unitSuffix,
    required this.onTap,
  });

  final AerosAttributeOption option;
  final bool selected;
  final bool requiredButMissing;
  final String? unitSuffix;
  final VoidCallback? onTap;

  AerosSelectionState _state() {
    if (selected) return AerosSelectionState.selected;
    if (option.disabled) return AerosSelectionState.disabled;
    if (requiredButMissing) return AerosSelectionState.requiredButMissing;
    return AerosSelectionState.unselected;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final palette = AerosSelectionPalette.resolve(_state(), a);
    final labelText =
        unitSuffix == null ? option.label : '${option.label} $unitSuffix';

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AerosSpacing.s3,
        vertical: AerosSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AerosRadii.brMd,
        border: Border.all(color: palette.border, width: palette.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.swatchColor != null) ...[
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Color(option.swatchColor!),
                shape: BoxShape.circle,
                border: Border.all(color: a.borderDefault),
              ),
            ),
            const SizedBox(width: AerosSpacing.s2),
          ],
          Text(
            labelText,
            style: AerosTypography.bodySm(color: palette.foreground)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          if (selected) ...[
            const SizedBox(width: AerosSpacing.s2),
            Icon(Icons.check_rounded, size: 14, color: palette.foreground),
          ],
        ],
      ),
    );

    return Tooltip(
      message: option.disabled && option.disabledReason != null
          ? option.disabledReason!
          : '',
      triggerMode: option.disabled && option.disabledReason != null
          ? TooltipTriggerMode.tap
          : TooltipTriggerMode.manual,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AerosRadii.brMd,
          child: chip,
        ),
      ),
    );
  }
}
