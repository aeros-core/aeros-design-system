import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import 'harness.dart';

const _sample = 'Aeros moves goods 0123456789';

Widget _specimen(BuildContext context, String name, TextStyle style, {String text = _sample}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(name, style: AerosTypography.caption(color: context.aerosColors.fgMuted)),
          ),
          Expanded(child: Text(text, style: style, maxLines: 1, softWrap: false, overflow: TextOverflow.clip)),
        ],
      ),
    );

void main() {
  goldenMatrix(
    'type_roles',
    size: const Size(1000, 760),
    (context) {
      final fg = context.aerosColors.fgPrimary;
      return GoldenColumn(
        width: 960,
        children: [
          _specimen(context, 'displayXl', AerosTypography.displayXl(color: fg)),
          _specimen(context, 'displayLg', AerosTypography.displayLg(color: fg)),
          _specimen(context, 'displayMd', AerosTypography.displayMd(color: fg)),
          _specimen(context, 'h1', AerosTypography.h1(color: fg)),
          _specimen(context, 'h2', AerosTypography.h2(color: fg)),
          _specimen(context, 'h3', AerosTypography.h3(color: fg)),
          _specimen(context, 'h4', AerosTypography.h4(color: fg)),
          _specimen(context, 'titleLg', AerosTypography.titleLg(color: fg)),
          _specimen(context, 'bodyLg', AerosTypography.bodyLg(color: fg)),
          _specimen(context, 'bodyMd', AerosTypography.bodyMd(color: fg)),
          _specimen(context, 'bodySm', AerosTypography.bodySm(color: fg)),
          _specimen(context, 'labelMd', AerosTypography.labelMd(color: fg)),
          _specimen(context, 'labelSm', AerosTypography.labelSm(color: fg)),
          _specimen(context, 'labelXs', AerosTypography.labelXs(color: fg)),
          _specimen(context, 'caption', AerosTypography.caption(color: fg)),
          _specimen(context, 'overline', AerosTypography.overline(color: fg)),
          _specimen(context, 'monoLg', AerosTypography.monoLg(color: fg)),
          _specimen(context, 'monoMd', AerosTypography.monoMd(color: fg)),
          _specimen(context, 'monoSm', AerosTypography.monoSm(color: fg)),
          _specimen(context, 'monoXs', AerosTypography.monoXs(color: fg)),
        ],
      );
    },
  );

  // The Material text theme the Aeros theme installs, as widgets inherit it.
  goldenMatrix(
    'type_text_theme',
    size: const Size(1000, 600),
    (context) {
      final t = Theme.of(context).textTheme;
      final styles = <String, TextStyle?>{
        'displayLarge': t.displayLarge,
        'displayMedium': t.displayMedium,
        'displaySmall': t.displaySmall,
        'headlineLarge': t.headlineLarge,
        'headlineMedium': t.headlineMedium,
        'headlineSmall': t.headlineSmall,
        'titleLarge': t.titleLarge,
        'titleMedium': t.titleMedium,
        'titleSmall': t.titleSmall,
        'bodyLarge': t.bodyLarge,
        'bodyMedium': t.bodyMedium,
        'bodySmall': t.bodySmall,
        'labelLarge': t.labelLarge,
        'labelMedium': t.labelMedium,
        'labelSmall': t.labelSmall,
      };
      return GoldenColumn(
        width: 960,
        children: [
          for (final entry in styles.entries)
            if (entry.value != null) _specimen(context, entry.key, entry.value!),
        ],
      );
    },
  );

  // The density ramp is the one place type changes between pointer and touch.
  goldenMatrix(
    'type_density_ramp',
    size: const Size(640, 230),
    (context) {
      final fg = context.aerosColors.fgPrimary;
      final d = AerosDensity.of(context);
      return GoldenColumn(
        width: 600,
        children: [
          _specimen(context, 'titleStyle', d.titleStyle(color: fg)),
          _specimen(context, 'bodyStyle', d.bodyStyle(color: fg)),
          _specimen(context, 'secondaryStyle', d.secondaryStyle(color: fg)),
          _specimen(context, 'metaStyle', d.metaStyle(color: fg)),
          _specimen(context, 'labelStyle', d.labelStyle(color: fg)),
          _specimen(context, 'microStyle', d.microStyle(color: fg)),
        ],
      );
    },
  );

  goldenMatrix(
    'type_wordmark',
    size: const Size(520, 440),
    (context) => GoldenColumn(
      children: [
        for (final size in const [16.0, 24.0, 40.0, 72.0])
          GoldenSection('AerosWordmark ${size.round()}', child: AerosWordmark(size: size)),
        const GoldenSection(
          'AerosWordmark custom colour, centred in 300',
          child: SizedBox(
            width: 300,
            child: AerosWordmark(size: 32, color: AerosColors.ink500, textAlign: TextAlign.center),
          ),
        ),
      ],
    ),
  );

  // With "reduce motion" on, the orb paints one still frame and never ticks,
  // which is the frame captured here.
  goldenMatrix(
    'type_thinking_orb_still',
    size: const Size(520, 260),
    (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: const GoldenRow(
        children: [
          AerosThinkingOrb(size: 48),
          AerosThinkingOrb(),
          AerosThinkingOrb(size: 200),
          AerosThinkingOrb(size: 96, color: AerosColors.ink500),
        ],
      ),
    ),
  );

  // The running orb, one second into its loop (the test clock is fake, so the
  // frame is the same every run).
  goldenMatrix(
    'type_thinking_orb_running',
    size: const Size(260, 260),
    settle: GoldenSettle.bounded,
    (context) => const AerosThinkingOrb(size: 200),
  );
}
