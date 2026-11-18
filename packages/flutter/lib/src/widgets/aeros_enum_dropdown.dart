import 'package:flutter/material.dart';
import 'aeros_attribute_models.dart';
import 'aeros_select.dart';

/// Single-select dropdown for an ENUM-source attribute.
///
/// An [AerosSelect] over the attribute's options: a disabled option shows its
/// `disabledReason` at the end of its row.
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

  @override
  Widget build(BuildContext context) {
    return AerosSelect<String>(
      label: label,
      placeholder: hint,
      required: required,
      enabled: enabled,
      error: errorText,
      value: selectedId,
      onChanged: onChanged,
      items: [
        for (final o in options)
          AerosSelectItem<String>(
            value: o.id,
            label: o.label,
            enabled: !o.disabled,
            detail: o.disabled ? o.disabledReason : null,
          ),
      ],
    );
  }
}
