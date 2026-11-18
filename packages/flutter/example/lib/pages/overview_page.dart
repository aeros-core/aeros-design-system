import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../destinations.dart';
import '../shell.dart';
import '../widgets/gallery_page.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const _principles = <(IconData, String, String)>[
    (
      Icons.border_style,
      'Hairlines at rest',
      'Resting surfaces are a fill and a 1px hairline. Only layers that float carry a shadow.'
    ),
    (
      Icons.contrast,
      'Monochrome',
      'Ink on white, white on ink. Colour is reserved for state: success, warning, danger, info.'
    ),
    (
      Icons.compress,
      'Compact, by pointer',
      'Controls are 32px for a mouse and 40px for fingers; hit targets never drop below the minimum.'
    ),
    (
      Icons.center_focus_strong,
      'One focus ring',
      'Hover and press change colour only. Keyboard focus draws one ring, outside the control.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final pages = destinations.where((d) => d.section != null).toList();
    return GalleryPage(
      title: 'Aeros Design System',
      summary: 'Theme, tokens and widgets for Flutter — 3.0, "Crisp precision".',
      actions: [
        AerosButton.secondary(label: 'Tokens', onPressed: () => GalleryNav.of(context).open('foundations')),
        AerosButton(
          label: 'Browse components',
          trailing: const Icon(Icons.arrow_forward),
          onPressed: () => GalleryNav.of(context).open('buttons'),
        ),
      ],
      children: [
        AerosCard(
          padding: const EdgeInsets.all(AerosSpacing.s6),
          child: AerosTwoColumn(
            primaryFlex: 3,
            asideFlex: 1,
            crossAxisAlignment: CrossAxisAlignment.center,
            primary: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AerosWordmark(size: 40),
                const SizedBox(height: AerosSpacing.s4),
                Text('Run everything.', style: AerosTypography.displayMd(color: a.fgPrimary)),
                const SizedBox(height: AerosSpacing.s2),
                Text(
                  'This gallery is built with the package it documents: the shell around this page is '
                  'AerosScaffold, AerosSidenav and AerosTopnav. Switch theme and density in the top bar — '
                  'every page follows.',
                  style: AerosTypography.bodyMd(color: a.fgSecondary),
                ),
              ],
            ),
            aside: const Center(child: AerosThinkingOrb(size: 96, semanticLabel: 'Aeros is thinking')),
          ),
        ),
        const SizedBox(height: AerosSpacing.s3),
        AerosResponsiveGrid.auto(
          tileMinWidth: 200,
          equalHeights: true,
          children: [
            AerosStatCard(label: 'Pages in this gallery', value: '${destinations.length}'),
            const AerosStatCard(label: 'Exported widgets', value: '70+', delta: 'all on one foundation'),
            const AerosStatCard(label: 'Control height', value: '32 / 40', mono: true, delta: 'pointer / touch'),
            const AerosStatCard(label: 'Runtime dependencies', value: '0', mono: true, delta: 'besides Flutter'),
          ],
        ),
        const SizedBox(height: AerosSpacing.s10),
        Section(
          'Principles',
          child: AerosResponsiveGrid.auto(
            tileMinWidth: 280,
            equalHeights: true,
            children: [
              for (final (icon, title, body) in _principles)
                AerosCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: AerosSizeTokens.iconLg, color: a.fgPrimary),
                      const SizedBox(width: AerosSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AerosTypography.h4(color: a.fgPrimary)),
                            const SizedBox(height: AerosSpacing.s1),
                            Text(body, style: AerosTypography.bodySm(color: a.fgSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Section(
          'Browse',
          note: 'One page per family, then two patterns that put the families together.',
          child: AerosResponsiveGrid.auto(
            tileMinWidth: 280,
            equalHeights: true,
            children: [
              for (final page in pages)
                AerosIntentCard(
                  title: page.label,
                  subtitle: page.summary,
                  icon: page.icon,
                  badge: page.section == 'Patterns' ? 'Pattern' : null,
                  onTap: () => GalleryNav.of(context).open(page.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
