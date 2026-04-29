import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Single-value slider for a MEASUREMENT attribute backed by a continuous
/// RANGE option-source. Renders the current value above the track with the
/// unit appended (e.g. "250 gsm").
///
/// For discrete numeric chips, use [AerosEnumChips] with `unitSuffix` instead.
class AerosRangeSlider extends StatelessWidget {
  const AerosRangeSlider({
    super.key,
    required this.range,
    required this.value,
    required this.onChanged,
    this.label,
    this.unitLabel,
    this.required = false,
    this.enabled = true,
    this.errorText,
    this.formatValue,
  });

  final AerosNumericRange range;

  /// Current value. `null` ⇒ slider sits at [AerosNumericRange.min] but the
  /// value-readout above renders as "—" so the buyer sees the field is empty.
  final num? value;
  final ValueChanged<num>? onChanged;

  final String? label;
  final String? unitLabel;
  final bool required;
  final bool enabled;
  final String? errorText;

  /// Optional formatter for the value-readout. Defaults to integer or 1-dp
  /// based on whether [AerosNumericRange.step] is whole.
  final String Function(num value)? formatValue;

  String _format(num? v) {
    if (v == null) return '—';
    if (formatValue != null) return formatValue!(v);
    final isWhole = range.step % 1 == 0;
    final text = isWhole ? v.toInt().toString() : v.toStringAsFixed(1);
    return unitLabel == null ? text : '$text $unitLabel';
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final divisions = ((range.max - range.min) / range.step).round();
    final current = (value ?? range.min).clamp(range.min, range.max).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Row(
            children: [
              Expanded(
                child: RichText(
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
              ),
              Text(
                _format(value),
                style: AerosTypography.monoMd(color: a.fgPrimary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: a.brandPrimary,
            inactiveTrackColor: a.borderDefault,
            thumbColor: a.brandPrimary,
            overlayColor: a.brandPrimary.withAlpha(40),
            trackHeight: 3,
          ),
          child: Slider(
            value: current,
            min: range.min.toDouble(),
            max: range.max.toDouble(),
            divisions: divisions > 0 ? divisions : null,
            onChanged: enabled && onChanged != null
                ? (v) {
                    final stepped = (v / range.step).round() * range.step;
                    onChanged!(stepped);
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(range.min),
                  style: AerosTypography.caption(color: a.fgMuted)),
              Text(_format(range.max),
                  style: AerosTypography.caption(color: a.fgMuted)),
            ],
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
