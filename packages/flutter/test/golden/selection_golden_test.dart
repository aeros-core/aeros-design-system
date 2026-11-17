import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _sizes = [
  AerosAttributeOption(id: '150', label: '150'),
  AerosAttributeOption(id: '250', label: '250'),
  AerosAttributeOption(id: '350', label: '350'),
  AerosAttributeOption(id: '450', label: '450', disabled: true, disabledReason: 'Out of range for this lid'),
];

const _colours = [
  AerosAttributeOption(id: 'ink', label: 'Ink', swatchColor: 0xFF1A1917),
  AerosAttributeOption(id: 'kraft', label: 'Kraft', swatchColor: 0xFFB08D57),
  AerosAttributeOption(id: 'white', label: 'White', swatchColor: 0xFFFFFFFF),
];

Widget _labelled(BuildContext context, String label, Widget child) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(width: 6),
        Text(label, style: AerosTypography.bodySm(color: context.aerosColors.fgSecondary)),
      ],
    );

void main() {
  goldenMatrix(
    'selection_toggles',
    size: const Size(620, 380),
    (context) => GoldenColumn(
      children: [
        GoldenSection(
          'AerosCheckbox',
          child: GoldenRow(
            children: [
              _labelled(context, 'on', AerosCheckbox(value: true, onChanged: (_) {})),
              _labelled(context, 'off', AerosCheckbox(value: false, onChanged: (_) {})),
              _labelled(context, 'mixed', AerosCheckbox(value: null, tristate: true, onChanged: (_) {})),
            ],
          ),
        ),
        GoldenSection(
          'AerosCheckbox compact',
          child: GoldenRow(
            children: [
              _labelled(context, 'on', AerosCheckbox(value: true, compact: true, onChanged: (_) {})),
              _labelled(context, 'off', AerosCheckbox(value: false, compact: true, onChanged: (_) {})),
              _labelled(context, 'mixed', AerosCheckbox(value: null, tristate: true, compact: true, onChanged: (_) {})),
            ],
          ),
        ),
        GoldenSection(
          'AerosRadio',
          child: GoldenRow(
            children: [
              _labelled(context, 'on', AerosRadio<int>(value: 1, groupValue: 1, onChanged: (_) {})),
              _labelled(context, 'off', AerosRadio<int>(value: 2, groupValue: 1, onChanged: (_) {})),
              _labelled(context, 'compact on', AerosRadio<int>(value: 1, groupValue: 1, compact: true, onChanged: (_) {})),
              _labelled(context, 'compact off', AerosRadio<int>(value: 2, groupValue: 1, compact: true, onChanged: (_) {})),
            ],
          ),
        ),
        GoldenSection(
          'AerosSwitch',
          child: GoldenRow(
            children: [
              _labelled(context, 'on', AerosSwitch(value: true, onChanged: (_) {})),
              _labelled(context, 'off', AerosSwitch(value: false, onChanged: (_) {})),
              _labelled(context, 'compact on', AerosSwitch(value: true, compact: true, onChanged: (_) {})),
              _labelled(context, 'compact off', AerosSwitch(value: false, compact: true, onChanged: (_) {})),
            ],
          ),
        ),
      ],
    ),
  );

  Widget toggles(BuildContext context) => GoldenRow(
        children: [
          AerosCheckbox(key: const Key('checkbox'), value: true, onChanged: (_) {}),
          AerosRadio<int>(key: const Key('radio'), value: 1, groupValue: 1, onChanged: (_) {}),
          AerosSwitch(key: const Key('switch'), value: true, onChanged: (_) {}),
        ],
      );
  for (final target in ['checkbox', 'radio', 'switch']) {
    goldenMatrix(
      'selection_${target}_hovered',
      toggles,
      size: const Size(240, 100),
      act: (t) => hover(t, find.byKey(Key(target))),
    );
    goldenMatrix(
      'selection_${target}_focused',
      toggles,
      size: const Size(240, 100),
      act: (t) => focus(t, find.byKey(Key(target))),
    );
  }

  goldenMatrix(
    'selection_chips',
    size: const Size(720, 810),
    (context) => GoldenColumn(
      width: 680,
      children: [
        GoldenSection(
          'AerosEnumChips',
          child: AerosEnumChips(
            label: 'Capacity',
            options: _sizes,
            selectedId: '250',
            onChanged: (_) {},
            unitSuffix: 'ml',
            required: true,
          ),
        ),
        GoldenSection(
          'AerosEnumChips with swatches, nothing selected',
          child: AerosEnumChips(label: 'Colour', options: _colours, selectedId: null, onChanged: (_) {}),
        ),
        GoldenSection(
          'AerosEnumChips required but missing, with error',
          child: AerosEnumChips(
            label: 'Capacity',
            options: _sizes,
            selectedId: null,
            onChanged: (_) {},
            required: true,
            requiredButMissing: true,
            errorText: 'Choose a capacity',
          ),
        ),
        const GoldenSection(
          'AerosEnumChips read-only',
          child: AerosEnumChips(label: 'Capacity', options: _sizes, selectedId: '350', onChanged: null),
        ),
        GoldenSection(
          'AerosFilterChip',
          child: GoldenRow(
            children: [
              AerosFilterChip(label: 'All', selected: true, onTap: () {}),
              AerosFilterChip(label: 'Unread', onTap: () {}),
              AerosFilterChip(label: 'Open', count: 12, onTap: () {}),
              AerosFilterChip(label: 'Open', count: 12, selected: true, onTap: () {}),
              AerosFilterChip(label: 'Archived', count: 99, countIsFloor: true, onTap: () {}),
              AerosFilterChip(label: 'Starred', leadingIcon: Icons.star_outline, onTap: () {}),
              AerosFilterChip(label: 'Status', dropdown: true, onTap: () {}),
              AerosFilterChip(label: 'Status: Paid', selected: true, onTap: () {}, onClear: () {}),
              const AerosFilterChip(label: 'No handler'),
            ],
          ),
        ),
        GoldenSection(
          'AerosFilterChip warning tone',
          child: GoldenRow(
            children: [
              AerosFilterChip(label: 'Needs attention', count: 3, tone: AerosFilterChipTone.warning, onTap: () {}),
              AerosFilterChip(
                label: 'Needs attention',
                count: 3,
                tone: AerosFilterChipTone.warning,
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        GoldenSection(
          'AerosFilterChip with its own density (pointer, then touch)',
          child: GoldenRow(
            children: [
              AerosFilterChip(label: 'Open', count: 4, density: AerosDensity.pointer, onTap: () {}),
              AerosFilterChip(label: 'Open', count: 4, density: AerosDensity.touch, onTap: () {}),
            ],
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'selection_filter_chip_hovered',
    (context) => GoldenRow(
      children: [
        AerosFilterChip(key: const Key('target'), label: 'Target', count: 4, onTap: () {}),
        AerosFilterChip(label: 'Resting', count: 4, onTap: () {}),
      ],
    ),
    size: const Size(280, 80),
    act: (t) => hover(t, find.byKey(const Key('target'))),
  );

  goldenMatrix(
    'selection_sliders',
    size: const Size(420, 990),
    (context) => GoldenColumn(
      width: 380,
      children: [
        GoldenSection(
          'AerosRangeSlider',
          child: AerosRangeSlider(
            label: 'Paper weight',
            unitLabel: 'gsm',
            range: const AerosNumericRange(min: 150, max: 350, step: 10),
            value: 250,
            onChanged: (_) {},
            required: true,
          ),
        ),
        GoldenSection(
          'AerosRangeSlider no value',
          child: AerosRangeSlider(
            label: 'Paper weight',
            unitLabel: 'gsm',
            range: const AerosNumericRange(min: 150, max: 350, step: 10),
            value: null,
            onChanged: (_) {},
          ),
        ),
        GoldenSection(
          'AerosRangeSlider error',
          child: AerosRangeSlider(
            label: 'Paper weight',
            unitLabel: 'gsm',
            range: const AerosNumericRange(min: 150, max: 350, step: 10),
            value: 150,
            onChanged: (_) {},
            errorText: 'Too thin for a 450 ml cup',
          ),
        ),
        const GoldenSection(
          'AerosRangeSlider disabled',
          child: AerosRangeSlider(
            label: 'Paper weight',
            unitLabel: 'gsm',
            range: AerosNumericRange(min: 150, max: 350, step: 10),
            value: 300,
            onChanged: null,
            enabled: false,
          ),
        ),
        GoldenSection(
          'AerosNumericRangeBand',
          child: AerosNumericRangeBand(
            label: 'Order quantity',
            unitLabel: 'pcs',
            range: const AerosNumericRange(min: 0, max: 10000, step: 500),
            values: const RangeValues(2000, 6500),
            onChanged: (_) {},
            required: true,
          ),
        ),
        GoldenSection(
          'AerosNumericRangeBand error',
          child: AerosNumericRangeBand(
            label: 'Order quantity',
            unitLabel: 'pcs',
            range: const AerosNumericRange(min: 0, max: 10000, step: 500),
            values: const RangeValues(0, 500),
            onChanged: (_) {},
            errorText: 'Minimum order is 1,000 pcs',
          ),
        ),
        const GoldenSection(
          'AerosNumericRangeBand disabled',
          child: AerosNumericRangeBand(
            label: 'Order quantity',
            unitLabel: 'pcs',
            range: AerosNumericRange(min: 0, max: 10000, step: 500),
            values: RangeValues(1000, 9000),
            onChanged: null,
            enabled: false,
          ),
        ),
      ],
    ),
  );
}
