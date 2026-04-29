import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Number-with-unit input for a MEASUREMENT attribute.
///
/// Renders a numeric text field on the left and a unit dropdown on the
/// right, joined visually as a single control. Use this when the buyer
/// needs free-form numeric entry inside an allowed range. For discrete
/// values, prefer [AerosEnumChips]; for continuous selection along a track,
/// prefer [AerosRangeSlider].
class AerosMeasurementInput extends StatefulWidget {
  const AerosMeasurementInput({
    super.key,
    required this.units,
    required this.numericValue,
    required this.unitCode,
    required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.range,
    this.errorText,
  });

  final List<AerosMeasurementUnit> units;
  final num? numericValue;
  final String? unitCode;
  final void Function(num? value, String? unitCode) onChanged;

  final String? label;
  final String? hint;
  final String? helperText;
  final bool required;
  final bool enabled;
  final AerosNumericRange? range;
  final String? errorText;

  @override
  State<AerosMeasurementInput> createState() => _AerosMeasurementInputState();
}

class _AerosMeasurementInputState extends State<AerosMeasurementInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.numericValue?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant AerosMeasurementInput old) {
    super.didUpdateWidget(old);
    final newText = widget.numericValue?.toString() ?? '';
    if (_controller.text != newText &&
        widget.numericValue != _parse(_controller.text)) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  num? _parse(String raw) {
    if (raw.trim().isEmpty) return null;
    return num.tryParse(raw.trim());
  }

  void _emit(String raw) {
    widget.onChanged(_parse(raw), widget.unitCode);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError ? AerosColors.danger : a.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: AerosTypography.bodySm(color: a.fgSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
              children: [
                if (widget.required)
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
            color: widget.enabled ? a.bgSurface : a.bgSubtle,
            borderRadius: AerosRadii.brMd,
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: _emit,
                  style: AerosTypography.bodyMd(color: a.fgPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AerosTypography.bodyMd(color: a.fgMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AerosSpacing.s3,
                    ),
                  ),
                ),
              ),
              if (widget.units.isNotEmpty) ...[
                Container(
                  width: 1,
                  height: 24,
                  color: a.borderDefault,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AerosSpacing.s2,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.unitCode,
                    onChanged: widget.enabled
                        ? (code) =>
                            widget.onChanged(widget.numericValue, code)
                        : null,
                    icon: Icon(Icons.keyboard_arrow_down,
                        size: 18, color: a.fgMuted),
                    style: AerosTypography.bodyMd(color: a.fgPrimary),
                    dropdownColor: a.bgSurface,
                    borderRadius: AerosRadii.brMd,
                    items: [
                      for (final u in widget.units)
                        DropdownMenuItem(
                          value: u.code,
                          child: Text(u.label),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            widget.errorText!,
            style: AerosTypography.caption(color: AerosColors.dangerText),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            widget.helperText!,
            style: AerosTypography.caption(color: a.fgMuted),
          ),
        ] else if (widget.range != null) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            'Allowed: ${widget.range!.min}–${widget.range!.max}'
            '${widget.unitCode != null ? ' ${widget.unitCode}' : ''}',
            style: AerosTypography.caption(color: a.fgMuted),
          ),
        ],
      ],
    );
  }
}
