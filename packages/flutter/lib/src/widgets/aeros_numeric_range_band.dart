import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Two-thumb band picker for a NUMERIC RANGE attribute. Renders both the
/// low and high values above the track with optional unit suffix. Snaps
/// each thumb to [AerosNumericRange.step] boundaries on change.
///
/// Naming: `AerosNumericRangeBand` (not `AerosRangeSlider`) — the existing
/// `AerosRangeSlider` is single-thumb (single-value MEASUREMENT input)
/// despite the name. This widget is the true two-thumb version. Use this
/// when the seller / buyer is selecting a band (e.g. "GSM offered:
/// 180–220" within an admin-curated range of 100–300).
///
/// State design: stateless — caller owns [values] (a [RangeValues] from
/// Material). [onChanged] fires on every drag with the snapped band; the
/// caller should rebuild with the new values.
///
/// Defensive clamping:
///   - [values] is clamped into [range] bounds on every build (handles
///     stale parent state after admin tightens an outer range)
///   - low ≤ high invariant is enforced — if the caller passes inverted
///     values, the lower one becomes start and the higher becomes end
///   - both thumbs snap to step boundaries on every change
///
/// For a single-thumb measurement input, use [AerosRangeSlider].
class AerosNumericRangeBand extends StatelessWidget {
  const AerosNumericRangeBand({
    super.key,
    required this.range,
    required this.values,
    required this.onChanged,
    this.label,
    this.unitLabel,
    this.required = false,
    this.enabled = true,
    this.errorText,
    this.formatValue,
  });

  /// Outer bounds (admin-defined). Both thumbs are clamped within these.
  final AerosNumericRange range;

  /// Current band — `null` ⇒ defaults to the full outer range
  /// (`RangeValues(range.min, range.max)`).
  final RangeValues? values;

  final ValueChanged<RangeValues>? onChanged;

  final String? label;
  final String? unitLabel;
  final bool required;
  final bool enabled;
  final String? errorText;

  /// Optional formatter for the value-readout. Defaults to integer or 1-dp
  /// based on whether [AerosNumericRange.step] is whole.
  final String Function(num value)? formatValue;

  String _format(num v) {
    if (formatValue != null) return formatValue!(v);
    final isWhole = range.step % 1 == 0;
    final text = isWhole ? v.toInt().toString() : v.toStringAsFixed(1);
    return unitLabel == null ? text : '$text $unitLabel';
  }

  /// Snap a continuous slider value to the nearest step boundary, then
  /// clamp into the outer range. Same logic the single-thumb
  /// [AerosRangeSlider] applies on its `onChanged`.
  double _snap(double v) {
    final stepped = (v / range.step).round() * range.step;
    return stepped.toDouble().clamp(
      range.min.toDouble(),
      range.max.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final divisions = ((range.max - range.min) / range.step).round();

    // Clamp + invariant-repair the incoming RangeValues so the widget
    // stays renderable when parent state is stale.
    final rawStart = (values?.start ?? range.min).clamp(range.min, range.max);
    final rawEnd = (values?.end ?? range.max).clamp(range.min, range.max);
    final start = rawStart.toDouble();
    final end = rawEnd.toDouble();
    final safeStart = start <= end ? start : end;
    final safeEnd = start <= end ? end : start;

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
                '${_format(safeStart)} – ${_format(safeEnd)}',
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
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: RangeSlider(
            values: RangeValues(safeStart, safeEnd),
            min: range.min.toDouble(),
            max: range.max.toDouble(),
            divisions: divisions > 0 ? divisions : null,
            onChanged: enabled && onChanged != null
                ? (v) {
                    final snappedStart = _snap(v.start);
                    final snappedEnd = _snap(v.end);
                    // Defensive: enforce low ≤ high after snapping in case
                    // step boundaries collapse the band.
                    final s = snappedStart <= snappedEnd
                        ? snappedStart
                        : snappedEnd;
                    final e = snappedStart <= snappedEnd
                        ? snappedEnd
                        : snappedStart;
                    onChanged!(RangeValues(s, e));
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
