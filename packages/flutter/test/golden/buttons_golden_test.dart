import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  goldenMatrix(
    'buttons',
    size: const Size(640, 1090),
    (context) => GoldenColumn(
      children: [
        // Every variant at every size.
        for (final variant in AerosButtonVariant.values)
          GoldenSection(
            variant.name,
            child: GoldenRow(
              children: [
                for (final size in AerosControlSize.values)
                  AerosButton(label: 'Button ${size.name}', onPressed: () {}, variant: variant, size: size),
              ],
            ),
          ),
        GoldenSection(
          'disabled',
          child: GoldenRow(
            children: [
              for (final variant in AerosButtonVariant.values)
                AerosButton(label: 'Disabled', onPressed: null, variant: variant),
            ],
          ),
        ),
        GoldenSection(
          'with icons',
          child: GoldenRow(
            children: [
              AerosButton(label: 'Add item', onPressed: () {}, leading: const Icon(Icons.add)),
              AerosButton(
                label: 'Next',
                onPressed: () {},
                variant: AerosButtonVariant.secondary,
                trailing: const Icon(Icons.arrow_forward),
              ),
              AerosButton(
                label: 'Export',
                onPressed: () {},
                variant: AerosButtonVariant.ghost,
                leading: const Icon(Icons.download),
                trailing: const Icon(Icons.expand_more),
              ),
              AerosButton(
                label: 'Delete',
                onPressed: () {},
                variant: AerosButtonVariant.danger,
                size: AerosControlSize.lg,
                leading: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        GoldenSection(
          'icon only, every size (ghost)',
          child: GoldenRow(
            children: [
              for (final size in AerosControlSize.values)
                AerosButton.icon(
                  icon: const Icon(Icons.more_horiz),
                  semanticLabel: 'More, ${size.name}',
                  onPressed: () {},
                  size: size,
                ),
            ],
          ),
        ),
        GoldenSection(
          'icon only, every variant, then disabled and loading',
          child: GoldenRow(
            children: [
              for (final variant in AerosButtonVariant.values)
                AerosButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  semanticLabel: 'Delete, ${variant.name}',
                  onPressed: () {},
                  variant: variant,
                ),
              const AerosButton.icon(icon: Icon(Icons.delete_outline), semanticLabel: 'Delete, disabled', onPressed: null),
              AerosButton.icon(
                icon: const Icon(Icons.add),
                semanticLabel: 'Add, secondary disabled',
                onPressed: null,
                variant: AerosButtonVariant.secondary,
              ),
            ],
          ),
        ),
        GoldenSection(
          'named constructors',
          child: GoldenRow(
            children: [
              AerosButton.primary(label: 'Primary', onPressed: () {}),
              AerosButton.secondary(label: 'Secondary', onPressed: () {}),
              AerosButton.ghost(label: 'Ghost', onPressed: () {}),
              AerosButton.danger(label: 'Danger', onPressed: () {}),
            ],
          ),
        ),
        GoldenSection(
          'full width',
          child: SizedBox(
            width: 360,
            child: AerosButton(label: 'Continue', onPressed: () {}, fullWidth: true),
          ),
        ),
      ],
    ),
  );

  // The spinner never stops, so this scene is caught at a fixed frame.
  goldenMatrix(
    'buttons_loading',
    size: const Size(700, 100),
    settle: GoldenSettle.bounded,
    (context) => GoldenRow(
      children: [
        for (final variant in AerosButtonVariant.values)
          AerosButton(label: 'Saving', onPressed: () {}, variant: variant, loading: true),
      ],
    ),
  );

  for (final variant in [
    AerosButtonVariant.primary,
    AerosButtonVariant.secondary,
    AerosButtonVariant.ghost,
    AerosButtonVariant.danger,
    AerosButtonVariant.dangerSubtle,
  ]) {
    Widget scene(BuildContext context) => GoldenRow(
          children: [
            AerosButton(key: const Key('target'), label: 'Target', onPressed: () {}, variant: variant),
            AerosButton(label: 'Resting', onPressed: () {}, variant: variant),
          ],
        );
    const size = Size(280, 80);
    goldenMatrix('buttons_${variant.name}_hovered', scene, size: size, act: (t) => hover(t, find.byKey(const Key('target'))));
    goldenMatrix('buttons_${variant.name}_focused', scene, size: size, act: (t) => focus(t, find.byKey(const Key('target'))));
    goldenMatrix('buttons_${variant.name}_pressed', scene, size: size, act: (t) => press(t, find.byKey(const Key('target'))));
  }

  // The icon-only button: hover, keyboard focus, press.
  Widget iconScene(BuildContext context) => GoldenRow(
        children: [
          AerosButton.icon(
            key: const Key('target'),
            icon: const Icon(Icons.more_horiz),
            semanticLabel: 'More',
            onPressed: () {},
          ),
          AerosButton.icon(icon: const Icon(Icons.more_horiz), semanticLabel: 'More, resting', onPressed: () {}),
          AerosButton.icon(
            icon: const Icon(Icons.add),
            semanticLabel: 'Add',
            onPressed: () {},
            variant: AerosButtonVariant.secondary,
          ),
        ],
      );
  const iconSize = Size(200, 80);
  goldenMatrix('buttons_icon_hovered', iconScene, size: iconSize, act: (t) => hover(t, find.byKey(const Key('target'))));
  goldenMatrix('buttons_icon_focused', iconScene, size: iconSize, act: (t) => focus(t, find.byKey(const Key('target'))));
  goldenMatrix('buttons_icon_pressed', iconScene, size: iconSize, act: (t) => press(t, find.byKey(const Key('target'))));
}
