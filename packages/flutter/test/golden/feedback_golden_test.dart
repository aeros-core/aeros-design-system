import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _message = {
  'en': 'A 450 ml cup needs paper of 280 gsm or more.',
  'hi': '450 ml कप के लिए 280 gsm या अधिक का पेपर चाहिए।',
};

void main() {
  goldenMatrix(
    'feedback_alerts',
    size: const Size(520, 720),
    (context) => GoldenColumn(
      width: 480,
      children: [
        for (final tone in AerosAlertTone.values)
          GoldenSection(
            'AerosAlert ${tone.name}',
            child: AerosAlert(tone: tone, title: 'Payment ${tone.name}', body: 'Your last invoice was processed on 12 Nov.'),
          ),
        const GoldenSection(
          'AerosAlert body only',
          child: AerosAlert(tone: AerosAlertTone.info, body: 'Prices exclude GST and freight.'),
        ),
        const GoldenSection(
          'AerosAlert custom icon, long body',
          child: AerosAlert(
            tone: AerosAlertTone.warning,
            title: 'Stock is running low',
            body: 'Only 2 cartons are left at the Ahmedabad warehouse. Orders above that quantity ship in two parts, '
                'the second after the next production run.',
            icon: Icons.inventory_2_outlined,
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'feedback_constraint_errors',
    size: const Size(520, 660),
    (context) => GoldenColumn(
      width: 480,
      children: [
        for (final severity in AerosSeverity.values)
          GoldenSection(
            'AerosConstraintErrorAlert ${severity.name}',
            child: AerosConstraintErrorAlert(messageByLocale: _message, locale: 'en', severity: severity),
          ),
        GoldenSection(
          'AerosConstraintErrorAlert title, resolve and dismiss',
          child: AerosConstraintErrorAlert(
            messageByLocale: _message,
            locale: 'en',
            title: 'Paper is too thin',
            onResolve: () {},
            resolveLabel: 'Pick a thicker paper',
            onDismiss: () {},
          ),
        ),
        GoldenSection(
          'AerosConstraintErrorAlert falls back to en for an unknown locale',
          child: AerosConstraintErrorAlert(
            messageByLocale: _message,
            locale: 'fr',
            severity: AerosSeverity.warn,
            onDismiss: () {},
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'feedback_progress',
    size: const Size(420, 380),
    (context) => const GoldenColumn(
      width: 380,
      children: [
        GoldenSection('AerosProgress 0%', child: AerosProgress(value: 0, label: 'Uploading artwork')),
        GoldenSection('AerosProgress 35%', child: AerosProgress(value: 0.35, label: 'Uploading artwork')),
        GoldenSection('AerosProgress 100%', child: AerosProgress(value: 1, label: 'Uploading artwork')),
        GoldenSection('AerosProgress no label', child: AerosProgress(value: 0.6)),
        GoldenSection(
          'AerosProgress custom colour',
          child: AerosProgress(value: 0.8, label: 'Storage used', color: AerosColors.danger),
        ),
      ],
    ),
  );

  // The indeterminate bar never stops, so it is caught at a fixed frame.
  goldenMatrix(
    'feedback_progress_indeterminate',
    size: const Size(420, 80),
    settle: GoldenSettle.bounded,
    (context) => const SizedBox(width: 380, child: AerosProgress(label: 'Syncing')),
  );

  // The tooltip opens on hover after a delay; bounded pumps carry it past that.
  for (final below in [true, false]) {
    goldenMatrix(
      'feedback_tooltip_${below ? 'below' : 'above'}',
      size: const Size(320, 160),
      settle: GoldenSettle.bounded,
      (context) => Padding(
        padding: const EdgeInsets.fromLTRB(60, 40, 60, 40),
        child: AerosTooltip(
          message: 'Copy the order link',
          preferBelow: below,
          child: const Icon(Icons.link, key: Key('target')),
        ),
      ),
      act: (t) => hover(t, find.byKey(const Key('target'))),
    );
  }

  for (final tone in AerosSnackbarTone.values) {
    goldenMatrix(
      'feedback_snackbar_${tone.name}',
      size: const Size(480, 140),
      (context) => const SizedBox(key: Key('anchor'), width: 10, height: 10),
      act: (t) async {
        AerosSnackbar.show(t.element(find.byKey(const Key('anchor'))), 'Order #4821 ${tone.name}', tone: tone);
      },
    );
  }
  goldenMatrix(
    'feedback_snackbar_description',
    size: const Size(480, 160),
    (context) => const SizedBox(key: Key('anchor'), width: 10, height: 10),
    act: (t) async {
      AerosSnackbar.show(
        t.element(find.byKey(const Key('anchor'))),
        'Payment failed',
        description: 'The card was declined. Try another one.',
        tone: AerosSnackbarTone.danger,
        actionLabel: 'Retry',
        onAction: () {},
      );
    },
  );
  goldenMatrix(
    'feedback_snackbar_action',
    size: const Size(480, 140),
    (context) => const SizedBox(key: Key('anchor'), width: 10, height: 10),
    act: (t) async {
      AerosSnackbar.show(
        t.element(find.byKey(const Key('anchor'))),
        'Order archived',
        tone: AerosSnackbarTone.success,
        actionLabel: 'Undo',
        onAction: () {},
      );
    },
  );
}
