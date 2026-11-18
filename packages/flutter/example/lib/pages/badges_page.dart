import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  List<String> _tags = ['Wholesale', 'Priority', 'Export'];

  static const _signals = [
    AerosRoutingSignal(kind: 'in_stock', label: 'Ships in 3 days'),
    AerosRoutingSignal(
      kind: 'requires_rfq',
      label: 'Above 100k units — request a quote',
      severity: AerosRoutingSeverity.warn,
      detail: 'A sales manager replies within one working day.',
    ),
    AerosRoutingSignal(
      kind: 'requires_credit_check',
      label: 'Credit check needed',
      severity: AerosRoutingSeverity.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Badges & avatars',
      summary: 'Small, quiet labels. Colour here always means state.',
      children: [
        const Section(
          'Badge',
          note: 'The status of a record. One word, with a dot that carries the tone.',
          child: Examples(
            spacing: AerosSpacing.s2,
            children: [
              AerosBadge(label: 'Paid', tone: AerosBadgeTone.success),
              AerosBadge(label: 'Pending', tone: AerosBadgeTone.warning),
              AerosBadge(label: 'Overdue', tone: AerosBadgeTone.danger),
              AerosBadge(label: 'Synced', tone: AerosBadgeTone.info),
              AerosBadge(label: 'Draft'),
              AerosBadge(label: 'New', tone: AerosBadgeTone.inverse),
              AerosBadge(label: 'No dot', showDot: false),
            ],
          ),
        ),
        const Section(
          'Count badge',
          note: 'How many are waiting. Above 99 it reads 99+; muted when nothing needs attention.',
          child: Examples(
            children: [
              AerosCountBadge(count: 3),
              AerosCountBadge(count: 42),
              AerosCountBadge(count: 128),
              AerosCountBadge(count: 20, floor: true),
              AerosCountBadge(count: 7, muted: true),
            ],
          ),
        ),
        Section(
          'Tag',
          note: 'A label a person attached. Removable when it has an onRemove.',
          child: Examples(
            spacing: AerosSpacing.s2,
            children: [
              for (final tag in _tags)
                AerosTag(
                  label: tag,
                  removeSemanticLabel: 'Remove $tag',
                  onRemove: () => setState(() => _tags = _tags.where((t) => t != tag).toList()),
                ),
              const AerosTag(label: 'Read only'),
              const AerosTag(label: 'Info', tone: AerosTagTone.info),
              const AerosTag(label: 'Inverse', tone: AerosTagTone.inverse),
              const AerosTag(label: 'Pill', pill: true),
              if (_tags.length < 3)
                AerosButton.ghost(
                  label: 'Reset',
                  size: AerosControlSize.xs,
                  onPressed: () => setState(() => _tags = ['Wholesale', 'Priority', 'Export']),
                ),
            ],
          ),
        ),
        Section(
          'Routing signal',
          note: 'What will happen to this order next — shipping, a quote, a check.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Examples(
                spacing: AerosSpacing.s2,
                children: [
                  for (final signal in _signals)
                    AerosRoutingSignalBadge(
                      signal: signal,
                      onTap: signal.detail == null
                          ? null
                          : () => AerosSnackbar.show(context, signal.label, description: signal.detail),
                    ),
                ],
              ),
              const SizedBox(height: AerosSpacing.s3),
              Examples(
                spacing: AerosSpacing.s2,
                children: [for (final signal in _signals) AerosRoutingSignalBadge(signal: signal, dense: true)],
              ),
            ],
          ),
        ),
        Section(
          'Avatar',
          note: 'A person or a company. Initials unless there is a picture.',
          child: Examples(
            children: [
              for (final size in AerosAvatarSize.values)
                AerosAvatar(initials: 'PP', size: size, semanticLabel: 'Parth Panchal'),
            ],
          ),
        ),
        const Section(
          'Avatar tones',
          child: Examples(
            children: [
              AerosAvatar(initials: 'BM'),
              AerosAvatar(initials: 'LF', tone: AerosAvatarTone.inverse),
              AerosAvatar(initials: 'KT', tone: AerosAvatarTone.info),
              AerosAvatar(initials: 'SP', tone: AerosAvatarTone.success),
              AerosAvatar(initials: 'NT', tone: AerosAvatarTone.warning),
            ],
          ),
        ),
      ],
    );
  }
}
