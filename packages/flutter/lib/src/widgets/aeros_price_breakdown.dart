import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_amount_format.dart';
import 'aeros_attribute_models.dart';

/// Collapsible price-breakdown card.
///
/// A flat surface. Amounts are set in mono at the two bundled weights (400
/// and 500); the total stands out by size and colour, not by a bold face.
///
/// Header row shows the total. Tapping expands the per-modifier contribution
/// list. The discountable / non-discountable subtotal split is rendered with
/// the [AerosPriceTone] colour tokens so buyers can see at a glance which
/// pieces respond to bulk discounts and which (setup fees, shipping) don't.
///
/// Amounts are grouped and carry two decimals: Indian grouping for the rupee
/// (`₹12,34,567.00`), thousands otherwise (`$1,234,567.00`), chosen from
/// [AerosPriceBreakdownData.currencySymbol] (see [AerosAmountFormat.money]).
/// Pass [formatAmount] to print them your own way — a locale-aware `intl`
/// format, no decimals, the currency after the number.
class AerosPriceBreakdown extends StatefulWidget {
  const AerosPriceBreakdown({
    super.key,
    required this.data,
    this.title = 'Price breakdown',
    this.initiallyExpanded = false,
    this.dense = false,
    this.formatAmount,
  });

  final AerosPriceBreakdownData data;
  final String title;
  final bool initiallyExpanded;
  final bool dense;

  /// Turns an amount into the text shown, sign and currency included. Null
  /// uses [AerosAmountFormat.money] with the data's currency symbol.
  final AerosAmountFormatter? formatAmount;

  @override
  State<AerosPriceBreakdown> createState() => _AerosPriceBreakdownState();
}

class _AerosPriceBreakdownState extends State<AerosPriceBreakdown> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  String _money(num n) =>
      widget.formatAmount?.call(n) ?? AerosAmountFormat.money(n, currencySymbol: widget.data.currencySymbol);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final d = widget.data;
    final rule = BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline);
    final vertical = widget.dense ? AerosSpacing.s3 : AerosSpacing.s4;

    return AerosSurface(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AerosPressable(
            onPressed: () => setState(() => _expanded = !_expanded),
            // The header is a full-width row, well over the minimum target.
            expandHitTarget: false,
            builder: (context, state) => AerosFocusRing(
              focused: state.focused,
              placement: AerosFocusRingPlacement.inset,
              radius: const BorderRadius.all(Radius.circular(AerosShapeTokens.surface)),
              child: AnimatedContainer(
                duration: AerosStateLayer.duration(context),
                curve: AerosStateLayer.curve,
                color: AerosStateLayer.resolve(a, a.bgSurface, hovered: state.hovered, pressed: state.pressed),
                padding: EdgeInsetsDirectional.fromSTEB(AerosSpacing.s4, vertical, AerosSpacing.s3, vertical),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title, style: AerosTypography.labelXs(color: a.fgMuted)),
                          const SizedBox(height: AerosSpacing.s0_5),
                          // The total stands out by size: mono ships at 400
                          // and 500 only, so there is no bold to reach for.
                          Text(
                            _money(d.total),
                            style: AerosTypography.monoLg(color: a.fgPrimary, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: AerosSizeTokens.iconLg,
                      color: a.fgMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(border: Border(top: rule)),
              padding: const EdgeInsets.fromLTRB(AerosSpacing.s4, AerosSpacing.s2, AerosSpacing.s4, AerosSpacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final step in d.steps) _StepRow(step: step, money: _money),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: AerosSpacing.s2),
                    height: AerosMetricTokens.borderHairline,
                    color: a.borderSubtle,
                  ),
                  _SubtotalRow(
                    label: 'Discountable subtotal',
                    amount: _money(d.discountableSubtotal),
                    tone: AerosPriceTone.discountable,
                  ),
                  if (d.nonDiscountableSubtotal != 0) ...[
                    const SizedBox(height: AerosSpacing.s1),
                    _SubtotalRow(
                      label: 'Fixed (setup / shipping)',
                      amount: _money(d.nonDiscountableSubtotal),
                      tone: AerosPriceTone.nonDiscountable,
                    ),
                  ],
                  // The total: a hairline above, no fill.
                  Container(
                    margin: const EdgeInsets.only(top: AerosSpacing.s2),
                    padding: const EdgeInsets.only(top: AerosSpacing.s2),
                    decoration: BoxDecoration(border: Border(top: rule)),
                    child: Row(
                      children: [
                        Expanded(child: Text('Total', style: AerosTypography.labelMd(color: a.fgPrimary))),
                        Text(
                          _money(d.total),
                          style: AerosTypography.monoMd(color: a.fgPrimary, weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.money});

  final AerosBreakdownStep step;
  final String Function(num) money;

  AerosPriceTone _tone() {
    if (step.amount < 0) return AerosPriceTone.discount;
    if (!step.discountable) return AerosPriceTone.nonDiscountable;
    return AerosPriceTone.discountable;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final palette = AerosPricePalette.of(context, _tone());
    final amountText = step.perUnit ? '${money(step.amount)} /u' : money(step.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AerosSpacing.s1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(step.name, style: AerosTypography.bodySm(color: a.fgPrimary))),
                    if (palette.label != null) ...[
                      const SizedBox(width: AerosSpacing.s1_5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1_5),
                        decoration: BoxDecoration(
                          color: a.bgSubtle,
                          borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
                        ),
                        child: Text(palette.label!, style: AerosTypography.labelXs(color: a.fgMuted)),
                      ),
                    ],
                  ],
                ),
                if (step.note != null) Text(step.note!, style: AerosTypography.caption(color: a.fgMuted)),
              ],
            ),
          ),
          const SizedBox(width: AerosSpacing.s3),
          Text(amountText, style: AerosTypography.monoSm(color: palette.foreground)),
        ],
      ),
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  const _SubtotalRow({
    required this.label,
    required this.amount,
    required this.tone,
  });

  final String label;
  final String amount;
  final AerosPriceTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = AerosPricePalette.of(context, tone);
    return Row(
      children: [
        Expanded(child: Text(label, style: AerosTypography.bodySm(color: palette.foreground))),
        Text(amount, style: AerosTypography.monoSm(color: palette.foreground)),
      ],
    );
  }
}
