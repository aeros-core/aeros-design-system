import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Collapsible price-breakdown card.
///
/// Header row shows the total. Tapping expands the per-modifier contribution
/// list. The discountable / non-discountable subtotal split is rendered with
/// the [AerosPriceTone] colour tokens so buyers can see at a glance which
/// pieces respond to bulk discounts and which (setup fees, shipping) don't.
class AerosPriceBreakdown extends StatefulWidget {
  const AerosPriceBreakdown({
    super.key,
    required this.data,
    this.title = 'Price breakdown',
    this.initiallyExpanded = false,
    this.dense = false,
  });

  final AerosPriceBreakdownData data;
  final String title;
  final bool initiallyExpanded;
  final bool dense;

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

  String _money(num n) {
    final negative = n < 0;
    final abs = n.abs();
    final formatted = abs.toStringAsFixed(2);
    return '${negative ? '−' : ''}${widget.data.currencySymbol}$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final d = widget.data;

    return Container(
      decoration: BoxDecoration(
        color: a.bgSurface,
        borderRadius: AerosRadii.brLg,
        border: Border.all(color: a.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AerosSpacing.s4,
                widget.dense ? AerosSpacing.s3 : AerosSpacing.s4,
                AerosSpacing.s3,
                widget.dense ? AerosSpacing.s3 : AerosSpacing.s4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AerosTypography.caption(color: a.fgMuted)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _money(d.total),
                          style: AerosTypography.h3(color: a.fgPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: a.fgMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) Divider(height: 1, color: a.borderDefault),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AerosSpacing.s4,
                AerosSpacing.s3,
                AerosSpacing.s4,
                AerosSpacing.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final step in d.steps) _StepRow(step: step, money: _money),
                  const SizedBox(height: AerosSpacing.s2),
                  Divider(height: 1, color: a.borderDefault),
                  const SizedBox(height: AerosSpacing.s2),
                  _SubtotalRow(
                    label: 'Discountable subtotal',
                    amount: _money(d.discountableSubtotal),
                    tone: AerosPriceTone.discountable,
                  ),
                  if (d.nonDiscountableSubtotal != 0) ...[
                    const SizedBox(height: 4),
                    _SubtotalRow(
                      label: 'Fixed (setup / shipping)',
                      amount: _money(d.nonDiscountableSubtotal),
                      tone: AerosPriceTone.nonDiscountable,
                    ),
                  ],
                  const SizedBox(height: AerosSpacing.s2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AerosSpacing.s3,
                      vertical: AerosSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: a.bgSubtle,
                      borderRadius: AerosRadii.brSm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: AerosTypography.bodyMd(color: a.fgPrimary)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          _money(d.total),
                          style: AerosTypography.monoMd(color: a.fgPrimary)
                              .copyWith(fontWeight: FontWeight.w700),
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
    final tone = _tone();
    final palette = AerosPricePalette.resolve(tone, a);
    final amountText = step.perUnit
        ? '${money(step.amount)} /u'
        : money(step.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                    Flexible(
                      child: Text(
                        step.name,
                        style: AerosTypography.bodySm(color: a.fgPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (palette.label != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: a.bgSubtle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          palette.label!,
                          style: AerosTypography.caption(color: a.fgMuted)
                              .copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (step.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      step.note!,
                      style: AerosTypography.caption(color: a.fgMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AerosSpacing.s3),
          Text(
            amountText,
            style: AerosTypography.monoSm(color: palette.foreground)
                .copyWith(fontWeight: FontWeight.w600),
          ),
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
    final a = context.aerosColors;
    final palette = AerosPricePalette.resolve(tone, a);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AerosTypography.bodySm(color: palette.foreground),
          ),
        ),
        Text(
          amount,
          style: AerosTypography.monoSm(color: palette.foreground)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
