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
import 'aeros_badge.dart';
import 'aeros_form_field.dart';

/// Single-select variant picker (size, colour, fabric, …).
///
/// Renders one [AerosVariantOption] per chip / swatch with a stock badge
/// derived from [AerosVariantOption.stockQty]. A chip is the same control as
/// an [AerosEnumChips] chip; hover and press change the fill only, keyboard
/// focus draws the focus ring. Tap selects; tapping the
/// selected variant again is a no-op.
///
/// Every colour sample — the swatch tile and the dot inside a chip — has a
/// `borderStrong` hairline, so it keeps an edge on any surface in both themes.
///
/// Deep-linking is supported by the parent: pass the desired
/// [selectedVariantId] in via state and the picker reflects it.
class AerosVariantPicker extends StatelessWidget {
  const AerosVariantPicker({
    super.key,
    required this.variants,
    required this.selectedVariantId,
    required this.onChanged,
    this.label = 'Variant',
    this.style = AerosVariantPickerStyle.chip,
    this.showStockBadge = true,
    this.required = false,
    this.errorText,
  });

  final List<AerosVariantOption> variants;
  final String? selectedVariantId;
  final ValueChanged<String?>? onChanged;

  final String label;
  final AerosVariantPickerStyle style;
  final bool showStockBadge;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AerosFormField(
      label: label,
      required: required,
      errorText: errorText,
      child: Wrap(
        spacing: AerosSpacing.s2,
        runSpacing: AerosSpacing.s2,
        children: [
          for (final v in variants)
            _VariantTile(
              variant: v,
              style: style,
              showStockBadge: showStockBadge,
              selected: v.id == selectedVariantId,
              onTap: v.disabled || !v.inStock || onChanged == null ? null : () => onChanged!(v.id),
            ),
        ],
      ),
    );
  }
}

enum AerosVariantPickerStyle {
  /// Tag-style chip with the variant label inline.
  chip,

  /// Square swatch — tile shows colour swatch (if present) + label below.
  swatch,
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.variant,
    required this.style,
    required this.showStockBadge,
    required this.selected,
    required this.onTap,
  });

  final AerosVariantOption variant;
  final AerosVariantPickerStyle style;
  final bool showStockBadge;
  final bool selected;
  final VoidCallback? onTap;

  static const AerosControlSize _size = AerosControlSize.sm;

  // No swatch-size token: the largest avatar (56) is the tile, and the
  // column is one 2x step wider on each side.
  static const double _swatch = AerosSizeTokens.avatarXl;
  static const double _swatchColumn = _swatch + 2 * AerosSpacing.s2;

  bool get _unavailable => variant.disabled || !variant.inStock;

  AerosSelectionState _state() {
    if (_unavailable) return AerosSelectionState.disabled;
    if (selected) return AerosSelectionState.selected;
    return AerosSelectionState.unselected;
  }

  Widget? _stockBadge() {
    if (!showStockBadge) return null;
    if (!variant.inStock) return const AerosBadge(label: 'Out of stock', showDot: false);
    final qty = variant.stockQty;
    if (qty != null && qty > 0 && qty < 10) {
      return AerosBadge(label: '$qty left', tone: AerosBadgeTone.warning, showDot: false);
    }
    return null;
  }

  Widget _chip(BuildContext context, AerosInteraction state, AerosSelectionPalette palette) {
    final a = context.aerosColors;
    final badge = _stockBadge();
    return AerosStateFill(
      color: AerosStateLayer.resolve(a, palette.background, hovered: state.hovered, pressed: state.pressed),
      borderColor: palette.border,
      radius: _size.radius,
      constraints: BoxConstraints.tightFor(height: _size.resolveHeight(context)),
      padding: EdgeInsets.symmetric(horizontal: _size.padH - AerosMetricTokens.borderHairline),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (variant.swatchColor != null) ...[
            Container(
              width: _size.iconSize,
              height: _size.iconSize,
              decoration: BoxDecoration(
                color: Color(variant.swatchColor!),
                shape: BoxShape.circle,
                // borderStrong, so a dark sample still has an edge in dark mode.
                border: Border.all(color: a.borderStrong, width: AerosMetricTokens.borderHairline),
              ),
            ),
            SizedBox(width: _size.gap),
          ],
          Text(variant.label, maxLines: 1, softWrap: false, style: _size.labelStyle(color: palette.foreground)),
          if (badge != null) ...[
            SizedBox(width: _size.gap),
            badge,
          ] else if (selected) ...[
            SizedBox(width: _size.gap),
            Icon(Icons.check_rounded, size: _size.iconSize, color: palette.foreground),
          ],
        ],
      ),
    );
  }

  Widget _swatchTile(BuildContext context, AerosInteraction state, AerosSelectionPalette palette) {
    final a = context.aerosColors;
    final hasColor = variant.swatchColor != null;
    return SizedBox(
      width: _swatchColumn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AerosStateLayer.duration(context),
            curve: AerosStateLayer.curve,
            width: _swatch,
            height: _swatch,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hasColor
                  ? Color(variant.swatchColor!)
                  : AerosStateLayer.resolve(a, palette.background, hovered: state.hovered, pressed: state.pressed),
              borderRadius: _size.radius,
              // A swatch is a sample, not a control: the chosen one is marked
              // with the thick border so it reads over any colour. At rest the
              // hairline is borderStrong — borderDefault lets a dark sample
              // sink into a dark surface (and a white one into a light one).
              border: Border.all(
                color: selected
                    ? a.fgPrimary
                    : state.hovered || state.pressed
                        ? a.fgMuted
                        : a.borderStrong,
                width: selected ? AerosMetricTokens.borderThick : AerosMetricTokens.borderHairline,
              ),
            ),
            child: hasColor
                ? null
                : Text(
                    variant.label.isEmpty ? '?' : variant.label[0],
                    style: AerosTypography.labelMd(color: palette.foreground),
                  ),
          ),
          const SizedBox(height: AerosSpacing.s1),
          Text(
            variant.label,
            style: AerosTypography.caption(
              color: _unavailable ? a.fgMuted : a.fgPrimary,
              weight: selected ? FontWeight.w500 : null,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          if (showStockBadge && !variant.inStock)
            Text('Out', style: AerosTypography.caption(color: context.aerosSemantic.dangerText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AerosSelectionPalette.of(context, _state());
    final swatch = style == AerosVariantPickerStyle.swatch;

    final tile = AerosPressable(
      onPressed: onTap,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      // The swatch tile is larger than any minimum target already.
      expandHitTarget: !swatch,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        radius: _size.radius,
        child: swatch ? _swatchTile(context, state, palette) : _chip(context, state, palette),
      ),
    );

    final reason = variant.disabled && variant.disabledReason != null
        ? variant.disabledReason!
        : (!variant.inStock ? 'Out of stock' : '');
    if (reason.isEmpty) return tile;
    return Tooltip(message: reason, triggerMode: TooltipTriggerMode.tap, child: tile);
  }
}
