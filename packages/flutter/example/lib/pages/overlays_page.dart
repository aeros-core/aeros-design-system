import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  bool _showGrid = true;
  String _sort = 'newest';
  String _last = 'Nothing chosen yet';
  int? _highlight = 1;

  void _report(String message) => setState(() => _last = message);

  Widget _form() => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AerosTextField(label: 'Street', hint: 'Plot 14, GIDC Estate'),
          SizedBox(height: AerosSpacing.s4),
          AerosTextField(label: 'City', hint: 'Ahmedabad'),
        ],
      );

  Future<void> _openDialog(AerosDialogSize size) async {
    final saved = await AerosDialog.show<bool>(
      context,
      builder: (context) => AerosDialog(
        size: size,
        title: 'Edit address',
        description: 'Shown on invoices and delivery notes.',
        content: _form(),
        actions: [
          AerosButton.secondary(label: 'Cancel', onPressed: () => Navigator.of(context).pop(false)),
          AerosButton(label: 'Save', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    _report('Dialog ${size.name}: ${saved == null ? 'dismissed' : saved ? 'saved' : 'cancelled'}');
  }

  Future<void> _openSheet(AerosSheetSide side) async {
    await AerosSheet.show<void>(
      context,
      side: side,
      size: AerosSheetSize.sm,
      builder: (context) => AerosSheet(
        title: 'Order #4821',
        description: 'Boson Machines · 12,000 cups',
        content: _form(),
        actions: [AerosButton(label: 'Done', onPressed: () => Navigator.of(context).pop())],
      ),
    );
    _report('Sheet from the ${side.name} closed');
  }

  Future<void> _confirm({required bool destructive}) async {
    final ok = await AerosConfirmDialog.show(
      context,
      title: destructive ? 'Delete order #4821?' : 'Send the quote?',
      body: destructive
          ? 'The order and its line items are removed. Invoices already issued are kept.'
          : 'Boson Machines gets an email with the quote and a link to accept it.',
      confirmLabel: destructive ? 'Delete' : 'Send',
      destructive: destructive,
    );
    _report(ok ? 'Confirmed' : 'Cancelled');
  }

  List<AerosMenuEntry> _menuItems() => [
        const AerosMenuLabel('Order'),
        AerosMenuItem<void>(
          label: 'Duplicate',
          leading: const Icon(Icons.copy_outlined),
          shortcut: '⌘D',
          onSelected: () => _report('Duplicate'),
        ),
        AerosMenuItem<void>(
          label: 'Export as PDF',
          leading: const Icon(Icons.picture_as_pdf_outlined),
          onSelected: () => _report('Export'),
        ),
        const AerosMenuItem<void>(label: 'Archive', leading: Icon(Icons.archive_outlined), enabled: false),
        const AerosMenuSeparator(),
        AerosMenuCheckboxItem(
          label: 'Show grid lines',
          checked: _showGrid,
          onChanged: (value) => setState(() => _showGrid = value),
        ),
        const AerosMenuSeparator(),
        const AerosMenuLabel('Sort by'),
        for (final (value, label) in const [('newest', 'Newest first'), ('total', 'Order total')])
          AerosMenuRadioItem<String>(
            label: label,
            value: value,
            groupValue: _sort,
            onChanged: (value) => setState(() => _sort = value),
          ),
        const AerosMenuSeparator(),
        AerosMenuItem<void>(
          label: 'Delete order',
          leading: const Icon(Icons.delete_outline),
          destructive: true,
          onSelected: () => _confirm(destructive: true),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return GalleryPage(
      title: 'Overlays',
      summary: 'Layers that float above the page. Each one traps focus, closes on Escape and gives focus back.',
      children: [
        AerosAlert(tone: AerosAlertTone.info, title: 'Last result', body: _last),
        const SizedBox(height: AerosSpacing.s8),
        Section(
          'Dialog',
          note: 'A task that must be finished or abandoned. Four widths: 400, 520, 720, 960.',
          child: Examples(
            children: [
              for (final size in AerosDialogSize.values)
                AerosButton.secondary(label: 'Dialog ${size.name}', onPressed: () => _openDialog(size)),
            ],
          ),
        ),
        Section(
          'Confirm dialog',
          note: 'One question, two answers. Destructive uses the solid danger button.',
          child: Examples(
            children: [
              AerosButton.secondary(label: 'Confirm', onPressed: () => _confirm(destructive: false)),
              AerosButton(
                label: 'Confirm a deletion',
                variant: AerosButtonVariant.dangerSubtle,
                onPressed: () => _confirm(destructive: true),
              ),
            ],
          ),
        ),
        Section(
          'Sheet',
          note:
              'Detail beside the page (left, right) or, on a phone, from the bottom. Drag a bottom sheet down to close.',
          child: Examples(
            children: [
              for (final side in AerosSheetSide.values)
                AerosButton.secondary(label: 'Sheet ${side.name}', onPressed: () => _openSheet(side)),
            ],
          ),
        ),
        Section(
          'Menu',
          note: 'Actions on one thing. Rows can run an action, toggle, or pick one of a group.',
          child: Examples(
            children: [
              AerosMenu(
                items: _menuItems(),
                semanticLabel: 'Order actions',
                trigger: (context, menu) => AerosButton(
                  label: 'Actions',
                  variant: AerosButtonVariant.secondary,
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  onPressed: menu.toggle,
                ),
              ),
              AerosMenu(
                align: AerosPopoverAlign.end,
                side: AerosPopoverSide.above,
                items: [
                  for (var i = 1; i <= 40; i++)
                    AerosMenuItem<void>(label: 'Warehouse $i', onSelected: () => _report('Warehouse $i')),
                ],
                trigger: (context, menu) => AerosButton.secondary(label: 'A long menu', onPressed: menu.toggle),
              ),
              // No trigger to wrap: open a menu from any context and await the value.
              Builder(
                builder: (context) => AerosButton.icon(
                  icon: const Icon(Icons.more_horiz),
                  semanticLabel: 'More',
                  variant: AerosButtonVariant.secondary,
                  onPressed: () async {
                    final value = await AerosMenu.show<String>(
                      context,
                      items: const [
                        AerosMenuItem(label: 'Rename', value: 'rename'),
                        AerosMenuItem(label: 'Move', value: 'move'),
                      ],
                    );
                    _report(value == null ? 'Menu dismissed' : 'AerosMenu.show → $value');
                  },
                ),
              ),
            ],
          ),
        ),
        Section(
          'Popover',
          note: 'Any content anchored to its trigger — filters, a share box, a short form.',
          child: Examples(
            children: [
              AerosPopover(
                semanticLabel: 'Share',
                constraints: const BoxConstraints(maxWidth: AerosMetricTokens.layoutDrawerSm),
                trigger: (context, popover) => AerosButton.secondary(
                  label: 'Share',
                  leading: const Icon(Icons.ios_share),
                  onPressed: popover.toggle,
                ),
                content: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Share this order', style: AerosTypography.labelMd(color: a.fgPrimary)),
                    const SizedBox(height: AerosSpacing.s2),
                    const AerosTextField(hint: 'name@company.com', size: AerosControlSize.sm),
                    const SizedBox(height: AerosSpacing.s3),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AerosButton(
                        label: 'Send invite',
                        size: AerosControlSize.sm,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _report('Invite sent');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Section(
          'Menu building blocks',
          note: 'AerosMenuList is a menu\'s rows with one shared highlight; AerosMenuRow is the row; '
              'AerosWholeRows cuts a scrolling list at a whole row. Use them to put a list on a surface of your own.',
          child: AerosResponsiveGrid.auto(
            tileMinWidth: 260,
            children: [
              AerosSurface(
                level: AerosSurfaceLevel.overlay,
                clipBehavior: Clip.antiAlias,
                child: AerosMenuList(
                  autofocus: false,
                  entries: const [
                    AerosMenuItem<void>(label: 'Inline list', leading: Icon(Icons.list)),
                    AerosMenuItem<void>(label: 'Keyboard and mouse', leading: Icon(Icons.keyboard_outlined)),
                    AerosMenuItem<void>(label: 'Share one highlight', leading: Icon(Icons.highlight_alt)),
                  ],
                  onChosen: (entry) => _report('Chose "${(entry as AerosMenuItem).label}" in the inline list'),
                ),
              ),
              AerosSurface(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(AerosMenu.panelPadding),
                child: SizedBox(
                  // Not a whole number of rows: AerosWholeRows trims the viewport to one.
                  height: 150,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AerosWholeRows(
                      rowHeight: AerosMenuRow.heightOf(context),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < 12; i++)
                              AerosMenuRow(
                                label: 'Lot ${i + 1}',
                                detail: '${(i + 1) * 500} cups',
                                mark: AerosMenuRowMark.selection,
                                checked: _highlight == i,
                                highlighted: _highlight == i,
                                onTap: () => setState(() => _highlight = i),
                              ),
                          ],
                        ),
                      ),
                    ),
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
