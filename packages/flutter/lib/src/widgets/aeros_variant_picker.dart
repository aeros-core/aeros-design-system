import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Single-select variant picker (size, colour, fabric, …).
///
/// Renders one [AerosVariantOption] per chip / swatch with an in-stock badge
/// derived from [AerosVariantOption.stockQty]. Tap selects; tapping the
/// selected variant again is a no-op.
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
    final a = context.aerosColors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: label,
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
        Wrap(
          spacing: AerosSpacing.s2,
          runSpacing: AerosSpacing.s2,
          children: [
            for (final v in variants)
              _VariantTile(
                variant: v,
                style: style,
                showStockBadge: showStockBadge,
                selected: v.id == selectedVariantId,
                onTap: v.disabled || !v.inStock || onChanged == null
                    ? null
                    : () => onChanged!(v.id),
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

  AerosSelectionState _state() {
    if (variant.disabled) return AerosSelectionState.disabled;
    if (!variant.inStock) return AerosSelectionState.disabled;
    if (selected) return AerosSelectionState.selected;
    return AerosSelectionState.unselected;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final palette = AerosSelectionPalette.resolve(_state(), a);

    Widget tile = switch (style) {
      AerosVariantPickerStyle.chip => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AerosSpacing.s3,
            vertical: AerosSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: AerosRadii.brMd,
            border: Border.all(
              color: palette.border,
              width: palette.borderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (variant.swatchColor != null) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Color(variant.swatchColor!),
                    shape: BoxShape.circle,
                    border: Border.all(color: a.borderDefault),
                  ),
                ),
                const SizedBox(width: AerosSpacing.s2),
              ],
              Text(
                variant.label,
                style: AerosTypography.bodySm(color: palette.foreground)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              if (showStockBadge && !variant.inStock) ...[
                const SizedBox(width: AerosSpacing.s2),
                _Badge(label: 'Out of stock', tone: _BadgeTone.muted),
              ] else if (showStockBadge &&
                  variant.stockQty != null &&
                  variant.stockQty! > 0 &&
                  variant.stockQty! < 10) ...[
                const SizedBox(width: AerosSpacing.s2),
                _Badge(label: '${variant.stockQty} left', tone: _BadgeTone.amber),
              ],
            ],
          ),
        ),
      AerosVariantPickerStyle.swatch => SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: variant.swatchColor != null
                      ? Color(variant.swatchColor!)
                      : palette.background,
                  borderRadius: AerosRadii.brMd,
                  border: Border.all(
                    color: palette.border,
                    width: palette.borderWidth,
                  ),
                ),
                alignment: Alignment.center,
                child: variant.swatchColor == null
                    ? Text(
                        variant.label.isEmpty ? '?' : variant.label[0],
                        style: AerosTypography.bodyMd(
                          color: palette.foreground,
                        ).copyWith(fontWeight: FontWeight.w800),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                variant.label,
                style: AerosTypography.caption(color: palette.foreground)
                    .copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              if (showStockBadge && !variant.inStock)
                Text(
                  'Out',
                  style: AerosTypography.caption(color: AerosColors.dangerText),
                ),
            ],
          ),
        ),
    };

    return Tooltip(
      message: variant.disabled && variant.disabledReason != null
          ? variant.disabledReason!
          : (!variant.inStock ? 'Out of stock' : ''),
      triggerMode: TooltipTriggerMode.tap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AerosRadii.brMd,
          child: tile,
        ),
      ),
    );
  }
}

enum _BadgeTone { muted, amber }

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.tone});
  final String label;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final (bg, fg) = switch (tone) {
      _BadgeTone.muted => (a.bgSubtle, a.fgMuted),
      _BadgeTone.amber => (AerosColors.warningBg, AerosColors.warningText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AerosTypography.caption(color: fg)
            .copyWith(fontSize: 10, fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}
