import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _progress = 0.6;
  bool _constraintShown = true;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Feedback',
      summary: 'Tell people what happened, what is happening, and what they can do about it.',
      children: [
        const Section(
          'Alert',
          note: 'A message that stays on the page. The tone says how much it matters.',
          child: Stacked(
            maxWidth: AerosMetricTokens.layoutDialogLg,
            spacing: AerosSpacing.s3,
            children: [
              AerosAlert(
                  tone: AerosAlertTone.info, title: 'Heads up', body: 'Prices are refreshed every morning at 6.'),
              AerosAlert(
                  tone: AerosAlertTone.success, title: 'Order placed', body: 'We have emailed the confirmation.'),
              AerosAlert(
                  tone: AerosAlertTone.warning, title: 'Low stock', body: 'Only 8 cartons of Kraft 250 ml left.'),
              AerosAlert(tone: AerosAlertTone.danger, title: 'Payment failed', body: 'Your bank declined the charge.'),
              AerosAlert(tone: AerosAlertTone.info, body: 'An alert needs no title.', icon: Icons.lightbulb_outline),
            ],
          ),
        ),
        Section(
          'Constraint alert',
          note: 'Why a combination is not allowed, in the buyer\'s language, with the way out.',
          child: Stacked(
            maxWidth: AerosMetricTokens.layoutDialogLg,
            spacing: AerosSpacing.s3,
            children: [
              if (_constraintShown)
                AerosConstraintErrorAlert(
                  locale: 'en',
                  messageByLocale: const {
                    'en': 'PE coating is not offered on 150 ml cups. Choose PLA or a larger size.',
                    'hi': '150 ml कप पर PE कोटिंग उपलब्ध नहीं है।',
                  },
                  resolveLabel: 'Switch to PLA',
                  onResolve: () => setState(() => _constraintShown = false),
                  onDismiss: () => setState(() => _constraintShown = false),
                )
              else
                AerosButton.secondary(
                  label: 'Show the constraint again',
                  onPressed: () => setState(() => _constraintShown = true),
                ),
              const AerosConstraintErrorAlert(
                locale: 'en',
                severity: AerosSeverity.warn,
                messageByLocale: {'en': 'Above 5,000 units this size ships in two lots.'},
              ),
              const AerosConstraintErrorAlert(
                locale: 'en',
                severity: AerosSeverity.info,
                title: 'Good to know',
                messageByLocale: {'en': 'Printed cups need artwork before production starts.'},
              ),
            ],
          ),
        ),
        Section(
          'Progress',
          note: 'A known fraction, or indeterminate when there is no way to know.',
          child: Stacked(
            children: [
              AerosProgress(value: _progress, label: 'Uploading artwork'),
              Examples(
                spacing: AerosSpacing.s2,
                children: [
                  AerosButton.secondary(
                    label: '−10%',
                    size: AerosControlSize.sm,
                    onPressed: () => setState(() => _progress = (_progress - 0.1).clamp(0, 1)),
                  ),
                  AerosButton.secondary(
                    label: '+10%',
                    size: AerosControlSize.sm,
                    onPressed: () => setState(() => _progress = (_progress + 0.1).clamp(0, 1)),
                  ),
                ],
              ),
              const AerosProgress(label: 'Checking stock'),
              AerosProgress(value: 0.92, label: 'Credit used', color: context.aerosSemantic.warning),
            ],
          ),
        ),
        const Section(
          'Thinking orb',
          note: 'A calm placeholder while something slow is worked out.',
          child: Examples(
            spacing: AerosSpacing.s8,
            children: [
              AerosThinkingOrb(size: 48),
              AerosThinkingOrb(size: 96, semanticLabel: 'Working out your price'),
            ],
          ),
        ),
        Section(
          'Snackbar',
          note: 'A brief confirmation that leaves by itself. Never the only place an error is shown.',
          child: Examples(
            children: [
              AerosButton.secondary(label: 'Neutral', onPressed: () => AerosSnackbar.show(context, 'Draft saved')),
              AerosButton.secondary(
                label: 'Success',
                onPressed: () => AerosSnackbar.show(
                  context,
                  'Order #4821 placed',
                  description: 'A confirmation is on its way to your inbox.',
                  tone: AerosSnackbarTone.success,
                ),
              ),
              AerosButton.secondary(
                label: 'Warning',
                onPressed: () => AerosSnackbar.show(
                  context,
                  'Saved without artwork',
                  tone: AerosSnackbarTone.warning,
                ),
              ),
              AerosButton.secondary(
                label: 'Danger, with an action',
                onPressed: () => AerosSnackbar.show(
                  context,
                  'Could not delete the order',
                  description: 'It has an invoice attached.',
                  tone: AerosSnackbarTone.danger,
                  actionLabel: 'Retry',
                  onAction: () => AerosSnackbar.show(context, 'Retrying…'),
                ),
              ),
            ],
          ),
        ),
        Section(
          'Tooltip',
          note: 'Names an icon-only control. Hover with a mouse, long-press with a finger.',
          child: Examples(
            children: [
              AerosTooltip(
                message: 'Download invoice',
                child: AerosButton.icon(
                  icon: const Icon(Icons.download_outlined),
                  semanticLabel: 'Download invoice',
                  variant: AerosButtonVariant.secondary,
                  onPressed: () {},
                ),
              ),
              AerosTooltip(
                message: 'Shown above',
                preferBelow: false,
                child: AerosButton.secondary(label: 'Tooltip above', onPressed: () {}),
              ),
              const AerosTooltip(message: 'Stock is counted at 6 am', child: AerosBadge(label: '8 left')),
            ],
          ),
        ),
      ],
    );
  }
}
