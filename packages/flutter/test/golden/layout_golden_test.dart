import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

Widget _tile(BuildContext context, String label) {
  final a = context.aerosColors;
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: a.bgSubtle,
      borderRadius: AerosRadii.brMd,
      border: Border.all(color: a.borderDefault),
    ),
    child: Text(label, style: AerosTypography.labelSm(color: a.fgPrimary)),
  );
}

Widget _layout(BuildContext context) => SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: GoldenColumn(
        children: [
          GoldenSection(
            'AerosResponsiveGrid crossAxisCount xs 2, md 4',
            child: AerosResponsiveGrid(
              crossAxisCount: const AerosResponsiveValue(xs: 2, md: 4),
              aspectRatio: const AerosResponsiveValue.all(2.5),
              children: [for (var i = 1; i <= 6; i++) _tile(context, 'Tile $i')],
            ),
          ),
          GoldenSection(
            'AerosResponsiveGrid tileMinWidth 160',
            child: AerosResponsiveGrid(
              tileMinWidth: 160,
              aspectRatio: const AerosResponsiveValue.all(2.5),
              children: [for (var i = 1; i <= 5; i++) _tile(context, 'Tile $i')],
            ),
          ),
          GoldenSection(
            'AerosTwoColumn',
            child: AerosTwoColumn(
              primary: SizedBox(height: 80, child: _tile(context, 'primary')),
              aside: SizedBox(height: 80, child: _tile(context, 'aside')),
            ),
          ),
          GoldenSection(
            'AerosTwoColumn asideFirst',
            child: AerosTwoColumn(
              asideFirst: true,
              primary: SizedBox(height: 80, child: _tile(context, 'primary')),
              aside: SizedBox(height: 80, child: _tile(context, 'aside')),
            ),
          ),
        ],
      ),
    );

Widget _hoverable(BuildContext context) => AerosHoverable(
      key: const Key('target'),
      onTap: () {},
      builder: (context, hovered) {
        final a = context.aerosColors;
        return Container(
          width: 200,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered ? a.bgSubtle : a.bgSurface,
            borderRadius: AerosRadii.brMd,
            border: Border.all(color: a.borderDefault),
          ),
          child: Text(hovered ? 'hovered' : 'resting', style: AerosTypography.labelSm(color: a.fgPrimary)),
        );
      },
    );

void main() {
  // The same scene above and below the md breakpoint.
  goldenMatrix('layout_wide', _layout, size: const Size(1100, 760));
  goldenMatrix('layout_narrow', _layout, size: const Size(390, 1100));

  // AerosViewportScope overrides the width the breakpoints read: a 390 wide
  // surface told it is 1280 wide lays out as desktop.
  goldenMatrix(
    'layout_viewport_scope',
    size: const Size(390, 200),
    (context) => SizedBox(
      width: 358,
      child: AerosViewportScope(
        width: 1280,
        child: Builder(
          builder: (context) => AerosTwoColumn(
            primary: SizedBox(height: 80, child: _tile(context, 'primary')),
            aside: SizedBox(height: 80, child: _tile(context, 'aside')),
          ),
        ),
      ),
    ),
  );

  goldenMatrix('layout_hoverable', _hoverable, size: const Size(240, 100));
  goldenMatrix(
    'layout_hoverable_hovered',
    _hoverable,
    size: const Size(240, 100),
    act: (t) => hover(t, find.byKey(const Key('target'))),
  );
}
