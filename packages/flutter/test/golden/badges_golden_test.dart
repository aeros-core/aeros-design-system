import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  goldenMatrix(
    'badges',
    size: const Size(720, 1180),
    (context) => GoldenColumn(
      width: 680,
      children: [
        GoldenSection(
          'AerosBadge with dot',
          child: GoldenRow(
            children: [
              for (final tone in AerosBadgeTone.values) AerosBadge(label: tone.name, tone: tone),
            ],
          ),
        ),
        GoldenSection(
          'AerosBadge without dot',
          child: GoldenRow(
            children: [
              for (final tone in AerosBadgeTone.values) AerosBadge(label: tone.name, tone: tone, showDot: false),
            ],
          ),
        ),
        GoldenSection(
          'AerosTag',
          child: GoldenRow(
            children: [
              for (final tone in AerosTagTone.values) AerosTag(label: tone.name, tone: tone),
            ],
          ),
        ),
        GoldenSection(
          'AerosTag removable',
          child: GoldenRow(
            children: [
              for (final tone in AerosTagTone.values) AerosTag(label: tone.name, tone: tone, onRemove: () {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosFilterChip (rest, count, selected, selected + clear, dropdown, warning)',
          child: GoldenRow(
            children: [
              AerosFilterChip(label: 'All', onTap: () {}),
              AerosFilterChip(label: 'Mine', count: 6, countIsFloor: true, onTap: () {}),
              AerosFilterChip(label: 'Unread', selected: true, count: 12, onTap: () {}),
              AerosFilterChip(label: 'Stage: Won', selected: true, dropdown: true, onTap: () {}, onClear: () {}),
              AerosFilterChip(label: 'Stage', dropdown: true, leadingIcon: Icons.flag_outlined, onTap: () {}),
              AerosFilterChip(label: 'Needs attention', tone: AerosFilterChipTone.warning, count: 3, onTap: () {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosEnumChips (selected, swatch, disabled) and required but missing',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AerosEnumChips(
                selectedId: 'm',
                onChanged: (_) {},
                options: const [
                  AerosAttributeOption(id: 's', label: '250', swatchColor: 0xFFB45309),
                  AerosAttributeOption(id: 'm', label: '350'),
                  AerosAttributeOption(id: 'l', label: '450', disabled: true),
                ],
                unitSuffix: 'ml',
              ),
              const SizedBox(height: 8),
              AerosEnumChips(
                selectedId: null,
                requiredButMissing: true,
                onChanged: (_) {},
                options: const [
                  AerosAttributeOption(id: 'a', label: 'Single wall'),
                  AerosAttributeOption(id: 'b', label: 'Double wall'),
                ],
                errorText: 'Pick a wall type',
              ),
            ],
          ),
        ),
        GoldenSection(
          'AerosTag pill',
          child: GoldenRow(
            children: [
              for (final tone in AerosTagTone.values) AerosTag(label: tone.name, tone: tone, pill: true),
              AerosTag(label: 'removable', pill: true, onRemove: () {}),
            ],
          ),
        ),
        const GoldenSection(
          'AerosCountBadge (1, 9, 42, 99, 120, floor, muted, zero)',
          child: GoldenRow(
            children: [
              AerosCountBadge(count: 1),
              AerosCountBadge(count: 9),
              AerosCountBadge(count: 42),
              AerosCountBadge(count: 99),
              AerosCountBadge(count: 120),
              AerosCountBadge(count: 50, floor: true),
              AerosCountBadge(count: 7, muted: true),
              AerosCountBadge(count: 0),
            ],
          ),
        ),
        const GoldenSection(
          'AerosCountBadge with its own density (pointer, then touch)',
          child: GoldenRow(
            children: [
              AerosCountBadge(count: 12, density: AerosDensity.pointer),
              AerosCountBadge(count: 12, density: AerosDensity.touch),
            ],
          ),
        ),
        GoldenSection(
          'AerosRoutingSignalBadge',
          child: GoldenRow(
            children: [
              const AerosRoutingSignalBadge(
                signal: AerosRoutingSignal(kind: 'IN_STOCK', label: 'Ships from stock'),
              ),
              const AerosRoutingSignalBadge(
                signal: AerosRoutingSignal(
                  kind: 'MTO',
                  label: 'Made to order · 12 days',
                  severity: AerosRoutingSeverity.warn,
                ),
              ),
              const AerosRoutingSignalBadge(
                signal: AerosRoutingSignal(
                  kind: 'BLOCKED',
                  label: 'Cannot be produced',
                  severity: AerosRoutingSeverity.error,
                ),
              ),
              AerosRoutingSignalBadge(
                signal: const AerosRoutingSignal(kind: 'RFQ', label: 'Quote required'),
                iconOverride: Icons.request_quote_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
        const GoldenSection(
          'AerosRoutingSignalBadge dense',
          child: GoldenRow(
            children: [
              AerosRoutingSignalBadge(
                dense: true,
                signal: AerosRoutingSignal(kind: 'IN_STOCK', label: 'Ships from stock'),
              ),
              AerosRoutingSignalBadge(
                dense: true,
                signal: AerosRoutingSignal(
                  kind: 'MTO',
                  label: 'Made to order · 12 days',
                  severity: AerosRoutingSeverity.warn,
                ),
              ),
              AerosRoutingSignalBadge(
                dense: true,
                signal: AerosRoutingSignal(
                  kind: 'BLOCKED',
                  label: 'Cannot be produced',
                  severity: AerosRoutingSeverity.error,
                ),
              ),
            ],
          ),
        ),
        GoldenSection(
          'AerosAvatar sizes',
          child: GoldenRow(
            children: [
              for (final size in AerosAvatarSize.values) AerosAvatar(initials: 'PP', size: size),
            ],
          ),
        ),
        GoldenSection(
          'AerosAvatar tones',
          child: GoldenRow(
            children: [
              for (final tone in AerosAvatarTone.values) AerosAvatar(initials: 'AE', tone: tone, size: AerosAvatarSize.lg),
            ],
          ),
        ),
        const GoldenSection(
          'AerosAvatar without initials',
          child: GoldenRow(children: [AerosAvatar(), AerosAvatar(size: AerosAvatarSize.xl)]),
        ),
      ],
    ),
  );

  // Hover and keyboard focus on the interactive members of the family.
  Widget chips(BuildContext context) => GoldenRow(
        children: [
          AerosFilterChip(key: const Key('chip'), label: 'Mine', count: 6, onTap: () {}),
          AerosTag(key: const Key('tag'), label: 'launch', onRemove: () {}),
          AerosRoutingSignalBadge(
            key: const Key('signal'),
            signal: const AerosRoutingSignal(kind: 'RFQ', label: 'Quote required'),
            onTap: () {},
          ),
        ],
      );
  for (final target in ['chip', 'tag', 'signal']) {
    goldenMatrix(
      'badges_${target}_hovered',
      chips,
      size: const Size(420, 90),
      act: (t) => hover(t, find.byKey(Key(target))),
    );
    goldenMatrix(
      'badges_${target}_focused',
      chips,
      size: const Size(420, 90),
      act: (t) => focus(t, find.byKey(Key(target))),
    );
  }
}
