import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import 'harness.dart';

/// A shrink-wrapped row with 12px gaps.
class _Inline extends StatelessWidget {
  const _Inline({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(width: 12),
            child,
          ],
        ],
      );
}

void main() {
  goldenMatrix(
    'badges',
    size: const Size(720, 900),
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
          // In a Row, not a Wrap: the badge fills whatever width it is
          // offered, and only shrinks to a pill where width is unbounded.
          child: _Inline(
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
          child: _Inline(
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
}
