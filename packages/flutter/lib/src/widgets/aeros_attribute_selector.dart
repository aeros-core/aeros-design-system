import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';
import 'aeros_enum_chips.dart';
import 'aeros_enum_dropdown.dart';
import 'aeros_file_upload_button.dart';
import 'aeros_measurement_input.dart';
import 'aeros_range_slider.dart';
import 'aeros_switch.dart';

/// Composite that renders the right input for one configurable attribute.
///
/// Routing matrix (datatype × optionSource):
/// - ENUM        + enumOptions → [AerosEnumDropdown] (>6 options) or
///                                [AerosEnumChips] (≤6 options).
/// - MEASUREMENT + enumOptions → [AerosEnumChips] with `unitSuffix`.
/// - MEASUREMENT + range       → [AerosRangeSlider] when the spec sets
///                                discrete `step`s, otherwise
///                                [AerosMeasurementInput].
/// - BOOLEAN     + enumOptions → [AerosSwitch] in a row with the label.
/// - any         + file        → [AerosFileUploadButton].
///
/// Consumers normally hand the spec straight from the backend
/// `/products/:id` response and let this widget decide. Override [chipThreshold]
/// or pass [forceVariant] for unusual cases.
enum AerosAttributeInputVariant {
  auto,
  dropdown,
  chips,
  slider,
  measurement,
  switchRow,
  file,
}

class AerosAttributeSelector extends StatelessWidget {
  const AerosAttributeSelector({
    super.key,
    required this.spec,
    required this.value,
    required this.onChanged,
    this.chipThreshold = 6,
    this.forceVariant = AerosAttributeInputVariant.auto,
    this.errorText,
    this.requiredButMissing = false,
  });

  final AerosAttributeSpec spec;
  final AerosAttributeValue value;
  final ValueChanged<AerosAttributeValue> onChanged;

  /// ENUM lists with ≤ this many options render as chips; longer lists
  /// render as a dropdown. Override per-call when needed.
  final int chipThreshold;

  final AerosAttributeInputVariant forceVariant;

  /// External validation message (e.g. from a constraint failure). Rendered
  /// below the input.
  final String? errorText;

  /// When `true`, the underlying chip group renders with the
  /// [requiredButMissing] tone until a value is set. Set this from the
  /// parent form when surfacing missing required fields after a submit.
  final bool requiredButMissing;

  AerosAttributeInputVariant _resolvedVariant() {
    if (forceVariant != AerosAttributeInputVariant.auto) return forceVariant;
    switch (spec.datatype) {
      case AerosAttributeDatatype.boolean:
        return AerosAttributeInputVariant.switchRow;
      case AerosAttributeDatatype.enumValue:
        if (spec.optionSource == AerosAttributeOptionSource.file) {
          return AerosAttributeInputVariant.file;
        }
        return spec.options.length > chipThreshold
            ? AerosAttributeInputVariant.dropdown
            : AerosAttributeInputVariant.chips;
      case AerosAttributeDatatype.measurement:
        switch (spec.optionSource) {
          case AerosAttributeOptionSource.enumOptions:
            return AerosAttributeInputVariant.chips;
          case AerosAttributeOptionSource.range:
            return AerosAttributeInputVariant.slider;
          case AerosAttributeOptionSource.file:
            return AerosAttributeInputVariant.file;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final variant = _resolvedVariant();
    final disabled = spec.lockedByAdmin;

    final input = switch (variant) {
      AerosAttributeInputVariant.dropdown => AerosEnumDropdown(
          label: spec.label,
          required: spec.required,
          enabled: !disabled,
          options: spec.options,
          selectedId: value.enumValueId,
          errorText: errorText,
          onChanged: disabled
              ? null
              : (id) => onChanged(AerosAttributeValue(enumValueId: id)),
        ),
      AerosAttributeInputVariant.chips => AerosEnumChips(
          label: spec.label,
          required: spec.required,
          options: spec.options,
          selectedId: value.enumValueId,
          unitSuffix: spec.datatype == AerosAttributeDatatype.measurement
              ? spec.defaultUnit
              : null,
          requiredButMissing: requiredButMissing,
          errorText: errorText,
          onChanged: disabled
              ? null
              : (id) => onChanged(
                    AerosAttributeValue(
                      enumValueId: id,
                      unitCode: spec.defaultUnit,
                    ),
                  ),
        ),
      AerosAttributeInputVariant.slider => AerosRangeSlider(
          label: spec.label,
          required: spec.required,
          enabled: !disabled,
          range: spec.range ?? const AerosNumericRange(min: 0, max: 100),
          unitLabel: spec.defaultUnit,
          value: value.numericValue,
          errorText: errorText,
          onChanged: disabled
              ? null
              : (v) => onChanged(
                    AerosAttributeValue(
                      numericValue: v,
                      unitCode: spec.defaultUnit,
                    ),
                  ),
        ),
      AerosAttributeInputVariant.measurement => AerosMeasurementInput(
          label: spec.label,
          required: spec.required,
          enabled: !disabled,
          units: spec.units,
          range: spec.range,
          numericValue: value.numericValue,
          unitCode: value.unitCode ?? spec.defaultUnit,
          errorText: errorText,
          onChanged: disabled
              ? (_, __) {}
              : (v, code) => onChanged(
                    AerosAttributeValue(numericValue: v, unitCode: code),
                  ),
        ),
      AerosAttributeInputVariant.switchRow => _SwitchRow(
          spec: spec,
          value: value.boolValue ?? false,
          enabled: !disabled,
          errorText: errorText,
          onChanged: disabled
              ? null
              : (v) => onChanged(AerosAttributeValue(boolValue: v)),
        ),
      AerosAttributeInputVariant.file => AerosFileUploadButton(
          label: spec.label,
          required: spec.required,
          enabled: !disabled,
          value: value.fileRef,
          errorText: errorText,
          onPickFile: () async => null,
          onRemove: disabled
              ? null
              : () => onChanged(const AerosAttributeValue()),
        ),
      AerosAttributeInputVariant.auto => const SizedBox.shrink(),
    };

    if (!disabled && spec.helperText == null) return input;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        input,
        if (disabled) ...[
          const SizedBox(height: AerosSpacing.s1),
          _LockedHint(),
        ] else if (spec.helperText != null) ...[
          const SizedBox(height: AerosSpacing.s1),
          _Helper(text: spec.helperText!),
        ],
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.spec,
    required this.value,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  final AerosAttributeSpec spec;
  final bool value;
  final bool enabled;
  final String? errorText;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: spec.label,
                  style: AerosTypography.bodyMd(color: a.fgPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                  children: [
                    if (spec.required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: AerosColors.danger),
                      ),
                  ],
                ),
              ),
            ),
            AerosSwitch(
              value: value,
              onChanged: enabled && onChanged != null
                  ? (v) => onChanged!(v)
                  : (_) {},
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

class _LockedHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 14, color: a.fgMuted),
        const SizedBox(width: 6),
        Text(
          'Locked by seller',
          style: AerosTypography.caption(color: a.fgMuted),
        ),
      ],
    );
  }
}

class _Helper extends StatelessWidget {
  const _Helper({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Text(text, style: AerosTypography.caption(color: a.fgMuted));
  }
}
