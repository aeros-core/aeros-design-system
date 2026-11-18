import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({super.key});

  static const _columns = AerosResponsiveValue<int>(xs: 2, md: 3, lg: 4);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final breakpoint = AerosBreakpoints.of(context);
    final width = MediaQuery.sizeOf(context).width.round();

    Widget tile(String label) => AerosSurface(
          child: Center(child: Text(label, style: AerosTypography.labelSm(color: a.fgSecondary))),
        );

    return GalleryPage(
      title: 'Responsive',
      summary: 'One breakpoint scale, shared with the web: 640, 768, 1024, 1280, 1536. Resize the window.',
      children: [
        Section(
          'Breakpoint',
          note: 'AerosBreakpoints.of(context) — what the layout below is reacting to.',
          child: Examples(
            spacing: AerosSpacing.s2,
            children: [
              AerosBadge(label: 'Window $width px', showDot: false),
              for (final bp in AerosBreakpoint.values)
                AerosBadge(
                  label: bp.name,
                  tone: bp == breakpoint ? AerosBadgeTone.inverse : AerosBadgeTone.neutral,
                  showDot: false,
                ),
            ],
          ),
        ),
        Section(
          'Responsive value',
          note: 'AerosResponsiveValue<T> — a value per breakpoint, falling back to the next smaller one.',
          child: Text(
            'AerosResponsiveValue<int>(xs: 2, md: 3, lg: 4) resolves to ${_columns.resolve(context)} here.',
            style: AerosTypography.bodyMd(color: a.fgPrimary),
          ),
        ),
        Section(
          'Responsive grid',
          note: 'Tiles of one shape. Give it a column count per breakpoint, or a minimum tile width.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosResponsiveGrid(
                crossAxisCount: _columns,
                aspectRatio: const AerosResponsiveValue.all(2.4),
                children: [for (var i = 1; i <= 8; i++) tile('Tile $i')],
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosResponsiveGrid(
                tileMinWidth: 160,
                aspectRatio: const AerosResponsiveValue.all(1.6),
                children: [for (var i = 1; i <= 6; i++) tile('≥ 160')],
              ),
            ],
          ),
        ),
        Section(
          'Two columns',
          note: 'A main column and an aside from md up; stacked below it.',
          child: AerosTwoColumn(
            primary: AerosCard(
              title: 'Order details',
              child: Text(
                'The primary column takes two thirds of the row.',
                style: AerosTypography.bodySm(color: a.fgSecondary),
              ),
            ),
            aside: AerosCard(
              title: 'Summary',
              child: Text('The aside takes one third.', style: AerosTypography.bodySm(color: a.fgSecondary)),
            ),
          ),
        ),
        Section(
          'Viewport scope',
          note: 'AerosViewportScope overrides the width breakpoints are read from. '
              'Each box below is told a different width, so the same widget lays out differently.',
          child: Tiles(
            minWidth: 300,
            children: [
              for (final (label, scopeWidth) in const [('Told 390 (xs)', 390.0), ('Told 1280 (xl)', 1280.0)])
                AerosCard(
                  title: label,
                  child: AerosViewportScope(
                    width: scopeWidth,
                    child: AerosTwoColumn(
                      gap: AerosSpacing.s2,
                      primary: SizedBox(height: AerosSpacing.s12, child: tile('primary')),
                      aside: SizedBox(height: AerosSpacing.s12, child: tile('aside')),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
