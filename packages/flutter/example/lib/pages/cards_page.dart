import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  String _intent = 'buy';
  int _opened = 0;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    Text body(String text) => Text(text, style: AerosTypography.bodySm(color: a.fgSecondary));

    return GalleryPage(
      title: 'Cards',
      summary: 'A flat surface with a hairline. Group what belongs together; do not nest them.',
      children: [
        Section(
          'Card',
          note: 'Header, body and footer are optional blocks divided by hairlines.',
          child: Tiles(
            minWidth: 300,
            equalHeights: true,
            children: [
              AerosCard(child: body('The plainest card: a padded surface.')),
              AerosCard(
                title: 'Delivery address',
                subtitle: 'Used for this order only',
                trailing: AerosButton.ghost(label: 'Edit', size: AerosControlSize.sm, onPressed: () {}),
                child: body('Plot 14, GIDC Estate\nAhmedabad 382445'),
              ),
              AerosCard(
                title: 'Invoice #4821',
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AerosButton.secondary(label: 'Download', size: AerosControlSize.sm, onPressed: () {}),
                    const SizedBox(width: AerosSpacing.s2),
                    AerosButton(label: 'Pay', size: AerosControlSize.sm, onPressed: () {}),
                  ],
                ),
                child: body('₹ 48,200 due on 30 November.'),
              ),
              AerosCard(
                semanticLabel: 'Open order 4821',
                onTap: () => setState(() => _opened++),
                child: body('A card with onTap is one target: it tints under the pointer. Opened $_opened×.'),
              ),
            ],
          ),
        ),
        const Section(
          'Stat card',
          note: 'One number and how it moved. Mono for amounts.',
          child: Tiles(
            minWidth: 200,
            equalHeights: true,
            children: [
              AerosStatCard(label: 'Orders', value: '128', delta: '12% vs last month', deltaDirection: AerosDelta.up),
              AerosStatCard(
                label: 'Revenue',
                value: '₹ 4,82,000',
                mono: true,
                delta: '3% vs last month',
                deltaDirection: AerosDelta.down,
              ),
              AerosStatCard(label: 'Open quotes', value: '7', delta: 'No change'),
              AerosStatCard(label: 'Average lead time', value: '5.2 days'),
            ],
          ),
        ),
        Section(
          'Intent card',
          note: 'A choice between ways forward. One can be selected.',
          child: Tiles(
            minWidth: 280,
            equalHeights: true,
            children: [
              for (final (id, icon, title, subtitle, badge) in const [
                ('buy', Icons.shopping_bag_outlined, 'Buy from the catalogue', 'Standard sizes, ships in days', null),
                ('custom', Icons.design_services_outlined, 'Make to order', 'Your size, board and print', 'Popular'),
                ('quote', Icons.request_quote_outlined, 'Request a quote', 'For 100k units and above', null),
              ])
                AerosIntentCard(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  badge: badge,
                  selected: _intent == id,
                  onTap: () => setState(() => _intent = id),
                ),
            ],
          ),
        ),
        Section(
          'Empty state',
          note: 'What goes where the content will be: what is missing, and the way to add it.',
          child: Tiles(
            minWidth: 300,
            equalHeights: true,
            children: [
              AerosCard(
                child: AerosEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  description: 'Orders you place or receive show up here.',
                  action: AerosButton(label: 'Create order', leading: const Icon(Icons.add), onPressed: () {}),
                ),
              ),
              const AerosCard(
                child: AerosEmptyState(
                  icon: Icons.search_off,
                  title: 'Nothing matches',
                  description: 'Try a shorter search or clear the filters.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
