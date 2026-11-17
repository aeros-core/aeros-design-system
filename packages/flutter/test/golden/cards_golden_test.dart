import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

Widget _body(BuildContext context) => Text(
      'Paper cups, 250 ml, single wall. 1,000 pieces per carton.',
      style: AerosTypography.bodyMd(color: context.aerosColors.fgSecondary),
    );

void main() {
  goldenMatrix(
    'cards',
    size: const Size(760, 640),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection('AerosCard flat', child: AerosCard(child: _body(context))),
            GoldenSection(
              'AerosCard flat, title, subtitle, trailing, footer',
              child: AerosCard(
                title: 'Order #4821',
                subtitle: 'Placed 12 Nov 2026',
                trailing: const AerosBadge(label: 'Paid', tone: AerosBadgeTone.success),
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AerosButton.secondary(label: 'Invoice', onPressed: () {}, size: AerosControlSize.sm),
                    const SizedBox(width: 8),
                    AerosButton.primary(label: 'Track', onPressed: () {}, size: AerosControlSize.sm),
                  ],
                ),
                child: _body(context),
              ),
            ),
            GoldenSection(
              'AerosCard custom header widget',
              child: AerosCard(
                header: Row(
                  children: [
                    const AerosAvatar(initials: 'BM', size: AerosAvatarSize.sm),
                    const SizedBox(width: 10),
                    Text('Boson Machines', style: AerosTypography.labelMd(color: context.aerosColors.fgPrimary)),
                  ],
                ),
                child: _body(context),
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosCard raised',
              child: AerosCard(variant: AerosCardVariant.raised, child: _body(context)),
            ),
            GoldenSection(
              'AerosCard raised, title and footer',
              child: AerosCard(
                variant: AerosCardVariant.raised,
                title: 'Order #4821',
                subtitle: 'Placed 12 Nov 2026',
                footer: Text('Updated 2 hours ago', style: AerosTypography.caption(color: context.aerosColors.fgMuted)),
                child: _body(context),
              ),
            ),
            GoldenSection(
              'AerosCard tappable, no padding',
              child: AerosCard(
                onTap: () {},
                padding: EdgeInsets.zero,
                child: Padding(padding: const EdgeInsets.all(12), child: _body(context)),
              ),
            ),
            GoldenSection(
              'AerosCard custom colour',
              child: AerosCard(color: context.aerosColors.bgSubtle, child: _body(context)),
            ),
          ],
        ),
      ],
    ),
  );

  goldenMatrix(
    'cards_stat',
    size: const Size(760, 380),
    (context) => const GoldenColumn(
      width: 720,
      children: [
        GoldenSection(
          'AerosStatCard deltas',
          child: Row(
            children: [
              Expanded(
                child: AerosStatCard(label: 'Orders', value: '1,284', delta: '+12.4%', deltaDirection: AerosDelta.up),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AerosStatCard(label: 'Returns', value: '37', delta: '-3.1%', deltaDirection: AerosDelta.down),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AerosStatCard(label: 'Open RFQs', value: '18', delta: '0.0%', deltaDirection: AerosDelta.flat),
              ),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'Sellers', value: '212')),
            ],
          ),
        ),
        GoldenSection(
          'AerosStatCard mono',
          child: SizedBox(
            width: 240,
            child: AerosStatCard(
              label: 'Revenue',
              value: '12,40,000',
              mono: true,
              delta: '+4.2%',
              deltaDirection: AerosDelta.up,
            ),
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'cards_intent_empty',
    size: const Size(760, 740),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosIntentCard unselected',
              child: AerosIntentCard(
                title: 'Buy for my business',
                subtitle: 'Browse the catalogue and request quotes',
                icon: Icons.shopping_bag_outlined,
                onTap: () {},
              ),
            ),
            GoldenSection(
              'AerosIntentCard selected',
              child: AerosIntentCard(
                title: 'Sell on Aeros',
                subtitle: 'List products and receive orders',
                icon: Icons.storefront_outlined,
                selected: true,
                onTap: () {},
              ),
            ),
            GoldenSection(
              'AerosIntentCard with badge',
              child: AerosIntentCard(
                title: 'Run my factory',
                subtitle: 'Plan jobs and track the shop floor',
                icon: Icons.precision_manufacturing_outlined,
                badge: 'New',
                onTap: () {},
              ),
            ),
            GoldenSection(
              'AerosIntentCard no icon, selected, badge',
              child: AerosIntentCard(
                title: 'Both',
                subtitle: 'Buy and sell from one account',
                badge: 'Popular',
                selected: true,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosEmptyState',
              child: AerosEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No orders yet',
                description: 'Orders you place will show up here.',
                action: AerosButton.primary(label: 'Browse catalogue', onPressed: () {}),
              ),
            ),
            const GoldenSection(
              'AerosEmptyState title and description',
              child: AerosEmptyState(title: 'Nothing matches', description: 'Try a different search.'),
            ),
            const GoldenSection('AerosEmptyState title only', child: AerosEmptyState(title: 'No results')),
          ],
        ),
      ],
    ),
  );

  goldenMatrix(
    'cards_intent_hovered',
    (context) => GoldenColumn(
      width: 340,
      children: [
        AerosIntentCard(
          key: const Key('target'),
          title: 'Buy for my business',
          subtitle: 'Browse the catalogue and request quotes',
          icon: Icons.shopping_bag_outlined,
          onTap: () {},
        ),
      ],
    ),
    size: const Size(380, 170),
    act: (t) => hover(t, find.byKey(const Key('target'))),
  );
}
