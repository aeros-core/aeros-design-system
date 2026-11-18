import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';
import 'aeros_form_field.dart';
import 'aeros_slider_theme.dart';

/// Single-value slider for a MEASUREMENT attribute backed by a continuous
/// RANGE option-source. Renders the current value above the track with the
/// unit appended (e.g. "250 gsm").
///
/// A Material [Slider] in the design system's slider look: a 2px track, a 14px
/// thumb with a hairline, no halo, and the focus ring on keyboard focus.
///
/// Disabled ([enabled] false or a null [onChanged]), the track, the thumb and
/// the value readout are all dimmed to [AerosMetricTokens.opacityDisabled].
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
    final divisions = ((range.max - range.min) / range.step).round();
    final current = (value ?? range.min).clamp(range.min, range.max).toDouble();
    final active = enabled && onChanged != null;

    return AerosFormField(
      label: label,
      required: required,
      errorText: errorText,
      labelGap: AerosSpacing.s1,
      // Mono ships at 400 and 500 only: the value is the medium face.
      trailing: AerosSliderValue(
        enabled: active,
        child: Text(_format(value), style: AerosTypography.monoMd(color: a.fgPrimary, weight: FontWeight.w500)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AerosSliderTheme(
            enabled: active,
            child: Slider(
              value: current,
              min: range.min.toDouble(),
              max: range.max.toDouble(),
              divisions: divisions > 0 ? divisions : null,
              onChanged: active
                  ? (v) {
                      final stepped = (v / range.step).round() * range.step;
                      onChanged!(stepped);
                    }
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(range.min), style: AerosTypography.caption(color: a.fgMuted)),
              Text(_format(range.max), style: AerosTypography.caption(color: a.fgMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
