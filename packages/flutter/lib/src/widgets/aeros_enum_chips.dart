import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Chip group for an ENUM-source attribute. Single-select.
///
/// Each chip is a small control ([AerosControlSize.sm] high for the density,
/// [AerosShapeTokens.control] corners) with a 1px hairline that stays 1px:
/// the selected chip takes the selected tint, an `fgPrimary` hairline and a
/// check. Hover and press change the fill only; keyboard focus draws the
/// focus ring.
///
/// Disabled ([enabled] false or a null [onChanged]) the whole group is dimmed
/// to [AerosMetricTokens.opacityDisabled]; its chips do not answer the
/// pointer, take no keyboard focus and are announced as disabled. The chosen
/// chip keeps its check, so a locked value still reads. One option can be
/// disabled on its own with [AerosAttributeOption.disabled].
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
    this.enabled = true,
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

  /// False disables every chip, like a null [onChanged].
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final active = enabled && onChanged != null;

    Widget chips = Wrap(
      spacing: AerosSpacing.s2,
      runSpacing: AerosSpacing.s2,
      children: [
        for (final o in options)
          _Chip(
            option: o,
            selected: o.id == selectedId,
            requiredButMissing: requiredButMissing && selectedId == null,
            unitSuffix: unitSuffix,
            onTap: o.disabled || !active ? null : () => onChanged!(o.id == selectedId ? null : o.id),
          ),
      ],
    );
    if (!active) chips = Opacity(opacity: AerosMetricTokens.opacityDisabled, child: chips);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AerosTypography.labelSm(color: a.fgSecondary),
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: context.aerosSemantic.danger),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s2),
        ],
        chips,
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            errorText!,
            style: AerosTypography.caption(color: context.aerosSemantic.dangerText),
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

  static const AerosControlSize _size = AerosControlSize.sm;

  AerosSelectionState _state() {
    if (selected) return AerosSelectionState.selected;
    if (option.disabled) return AerosSelectionState.disabled;
    if (requiredButMissing) return AerosSelectionState.requiredButMissing;
    return AerosSelectionState.unselected;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final palette = AerosSelectionPalette.of(context, _state());
    final labelText =
        unitSuffix == null ? option.label : '${option.label} $unitSuffix';

    final chip = AerosPressable(
      onPressed: onTap,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        radius: _size.radius,
        child: AerosStateFill(
          color: AerosStateLayer.resolve(
            a,
            palette.background,
            hovered: state.hovered,
            pressed: state.pressed,
          ),
          borderColor: palette.border,
          radius: _size.radius,
          constraints: BoxConstraints.tightFor(height: _size.resolveHeight(context)),
          padding: EdgeInsets.symmetric(horizontal: _size.padH - AerosMetricTokens.borderHairline),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.swatchColor != null) ...[
                Container(
                  width: _size.iconSize,
                  height: _size.iconSize,
                  decoration: BoxDecoration(
                    color: Color(option.swatchColor!),
                    shape: BoxShape.circle,
                    // borderStrong, so a dark sample still has an edge in dark mode.
                    border: Border.all(color: a.borderStrong, width: AerosMetricTokens.borderHairline),
                  ),
                ),
                SizedBox(width: _size.gap),
              ],
              Text(
                labelText,
                maxLines: 1,
                softWrap: false,
                style: _size.labelStyle(color: palette.foreground),
              ),
              if (selected) ...[
                SizedBox(width: _size.gap),
                Icon(Icons.check_rounded, size: _size.iconSize, color: palette.foreground),
              ],
            ],
          ),
        ),
      ),
    );

    final reason = option.disabled ? option.disabledReason : null;
    if (reason == null || reason.isEmpty) return chip;
    return Tooltip(message: reason, triggerMode: TooltipTriggerMode.tap, child: chip);
  }
}
