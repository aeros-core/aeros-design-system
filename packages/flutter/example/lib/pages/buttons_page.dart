import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Buttons',
      summary: 'One primary action per view. Everything else is secondary or ghost.',
      children: [
        Section(
          'Variants',
          note: 'Primary for the main action, secondary beside it, ghost in toolbars, danger to destroy.',
          child: Examples(
            children: [
              for (final variant in AerosButtonVariant.values)
                AerosButton(label: _name(variant), variant: variant, onPressed: () {}),
            ],
          ),
        ),
        Section(
          'Sizes',
          note: 'The height follows the density in the top bar: 24–40 for a mouse, 32–48 for fingers.',
          child: Examples(
            children: [
              for (final size in AerosControlSize.values)
                AerosButton.secondary(label: size.name.toUpperCase(), size: size, onPressed: () {}),
            ],
          ),
        ),
        Section(
          'With icons',
          child: Examples(
            children: [
              AerosButton.primary(label: 'New order', leading: const Icon(Icons.add), onPressed: () {}),
              AerosButton.secondary(label: 'Export', leading: const Icon(Icons.download_outlined), onPressed: () {}),
              AerosButton.primary(label: 'Continue', trailing: const Icon(Icons.arrow_forward), onPressed: () {}),
              AerosButton.ghost(label: 'Filters', leading: const Icon(Icons.tune), onPressed: () {}),
              AerosButton.danger(label: 'Delete', leading: const Icon(Icons.delete_outline), onPressed: () {}),
              AerosButton.dangerSubtle(label: 'Remove', onPressed: () {}),
              AerosButton.link(label: 'Learn more', trailing: const Icon(Icons.open_in_new), onPressed: () {}),
            ],
          ),
        ),
        Section(
          'Icon-only',
          note: 'AerosButton.icon needs a semanticLabel — it is the button\'s name for a screen reader.',
          child: Examples(
            children: [
              AerosButton.icon(icon: const Icon(Icons.more_horiz), semanticLabel: 'More', onPressed: () {}),
              AerosButton.icon(
                icon: const Icon(Icons.edit_outlined),
                semanticLabel: 'Edit',
                variant: AerosButtonVariant.secondary,
                onPressed: () {},
              ),
              AerosButton.icon(
                icon: const Icon(Icons.add),
                semanticLabel: 'Add',
                variant: AerosButtonVariant.primary,
                onPressed: () {},
              ),
              AerosButton.icon(
                icon: const Icon(Icons.delete_outline),
                semanticLabel: 'Delete',
                variant: AerosButtonVariant.dangerSubtle,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Section(
          'States',
          note: 'Disabled is a null onPressed. Loading keeps the width and blocks a second press.',
          child: Examples(
            children: [
              const AerosButton(label: 'Disabled', onPressed: null),
              const AerosButton(label: 'Disabled', variant: AerosButtonVariant.secondary, onPressed: null),
              AerosButton(label: _saving ? 'Saving' : 'Save (tap me)', loading: _saving, onPressed: _save),
              AerosButton(label: 'Loading', variant: AerosButtonVariant.secondary, loading: true, onPressed: () {}),
            ],
          ),
        ),
        Section(
          'Full width',
          note: 'For the one action at the foot of a phone screen or a narrow card.',
          child: Stacked(
            spacing: AerosSpacing.s2,
            children: [
              AerosButton(label: 'Place order', fullWidth: true, size: AerosControlSize.lg, onPressed: () {}),
              AerosButton(
                label: 'Save as draft',
                fullWidth: true,
                size: AerosControlSize.lg,
                variant: AerosButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Section(
          'A size for a whole region',
          note: 'AerosControlSizeScope sets the default size for the controls below it.',
          child: AerosControlSizeScope(
            size: AerosControlSize.sm,
            child: Examples(
              spacing: AerosSpacing.s2,
              children: [
                AerosButton.secondary(label: 'Filter', leading: const Icon(Icons.filter_list), onPressed: () {}),
                AerosButton.secondary(label: 'Sort', leading: const Icon(Icons.sort), onPressed: () {}),
                AerosButton.icon(icon: const Icon(Icons.refresh), semanticLabel: 'Refresh', onPressed: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _name(AerosButtonVariant variant) => switch (variant) {
        AerosButtonVariant.primary => 'Primary',
        AerosButtonVariant.secondary => 'Secondary',
        AerosButtonVariant.ghost => 'Ghost',
        AerosButtonVariant.danger => 'Danger',
        AerosButtonVariant.dangerSubtle => 'Danger subtle',
        AerosButtonVariant.link => 'Link',
      };
}
