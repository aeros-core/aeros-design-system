import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _cities = ['Ahmedabad', 'Bengaluru', 'Chennai', 'Delhi', 'Hyderabad', 'Kolkata', 'Mumbai', 'Pune'];

Widget _anchor(BuildContext context) => const SizedBox(key: Key('anchor'), width: 10, height: 10);

Widget _dropdown(AerosDropdownMode mode, {bool searchBox = true}) => GoldenColumn(
      width: 320,
      children: [
        AerosDropdownSearch<String>(
          key: const Key('target'),
          label: 'City',
          hint: 'Select a city',
          popupTitle: 'Choose a city',
          items: _cities,
          selectedItem: 'Delhi',
          itemAsString: (s) => s,
          onChanged: (_) {},
          mode: mode,
          showSearchBox: searchBox,
        ),
      ],
    );

void main() {
  goldenMatrix(
    'overlays_confirm_dialog',
    size: const Size(640, 400),
    _anchor,
    act: (t) async {
      AerosConfirmDialog.show(
        t.element(find.byKey(const Key('anchor'))),
        title: 'Publish this listing?',
        body: 'Buyers will see "Paper cup 250 ml" in the catalogue straight away.',
        confirmLabel: 'Publish',
      );
    },
  );

  goldenMatrix(
    'overlays_confirm_dialog_destructive',
    size: const Size(640, 400),
    _anchor,
    act: (t) async {
      AerosConfirmDialog.show(
        t.element(find.byKey(const Key('anchor'))),
        title: 'Delete industry?',
        body: 'This removes "Construction" from the catalog. Items in this industry will be reclassified as "Other".',
        confirmLabel: 'Delete',
        cancelLabel: 'Keep it',
        destructive: true,
      );
    },
  );

  // A body longer than the dialog scrolls inside it.
  goldenMatrix(
    'overlays_confirm_dialog_long_body',
    size: const Size(390, 420),
    _anchor,
    act: (t) async {
      AerosConfirmDialog.show(
        t.element(find.byKey(const Key('anchor'))),
        title: 'Accept the updated terms?',
        body: List.filled(14, 'Orders are fulfilled by the seller named on the invoice.').join(' '),
        confirmLabel: 'Accept',
      );
    },
  );

  for (final mode in AerosDropdownMode.values) {
    goldenMatrix(
      'overlays_dropdown_search_${mode.name}',
      size: const Size(640, 560),
      (context) => _dropdown(mode),
      act: (t) => t.tap(find.byType(AerosFieldFrame)),
    );
  }

  goldenMatrix(
    'overlays_dropdown_search_dialog_no_search_box',
    size: const Size(640, 560),
    (context) => _dropdown(AerosDropdownMode.dialog, searchBox: false),
    act: (t) => t.tap(find.byKey(const Key('target'))),
  );

  // A query that matches nothing shows the empty text.
  goldenMatrix(
    'overlays_dropdown_search_dialog_no_results',
    size: const Size(640, 560),
    (context) => _dropdown(AerosDropdownMode.dialog),
    act: (t) async {
      await t.tap(find.byKey(const Key('target')));
      await t.pumpAndSettle();
      await t.enterText(find.byType(EditableText).last, 'zz');
      // The popup debounces its filter by 250 ms.
      await t.pump(const Duration(milliseconds: 300));
    },
  );

  goldenMatrix(
    'overlays_enum_dropdown_open',
    size: const Size(400, 320),
    (context) => SizedBox(
      width: 320,
      child: AerosEnumDropdown(
        key: const Key('target'),
        label: 'Material',
        options: const [
          AerosAttributeOption(id: 'kraft', label: 'Kraft'),
          AerosAttributeOption(id: 'white', label: 'White board'),
          AerosAttributeOption(id: 'pe', label: 'PE coated', disabled: true, disabledReason: 'Not for this size'),
        ],
        selectedId: 'white',
        onChanged: (_) {},
      ),
    ),
    act: (t) => t.tap(find.byKey(const Key('target'))),
  );

  // ─── Dialog ───
  for (final size in AerosDialogSize.values) {
    goldenMatrix(
      'overlays_dialog_${size.name}',
      size: Size(size.maxWidth + 120, 460),
      _anchor,
      act: (t) async {
        AerosDialog.show<void>(
          t.element(find.byKey(const Key('anchor'))),
          builder: (context) => AerosDialog(
            size: size,
            title: 'Invite a teammate',
            description: 'They get access to every order in this workspace.',
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AerosTextField(label: 'Work email', hint: 'name@company.com'),
                SizedBox(height: 12),
                AerosSelect<String>(
                  label: 'Role',
                  value: 'buyer',
                  onChanged: null,
                  items: [AerosSelectItem(value: 'buyer', label: 'Buyer')],
                ),
              ],
            ),
            actions: [
              AerosButton.secondary(label: 'Cancel', onPressed: () {}),
              AerosButton(label: 'Send invite', onPressed: () {}),
            ],
          ),
        );
      },
    );
  }

  // No footer, no description: the header and the body alone.
  goldenMatrix(
    'overlays_dialog_plain',
    size: const Size(640, 320),
    _anchor,
    act: (t) async {
      AerosDialog.show<void>(
        t.element(find.byKey(const Key('anchor'))),
        builder: (context) => const AerosDialog(
          title: 'Keyboard shortcuts',
          content: Text('Press ? anywhere to see the shortcuts for the screen you are on.'),
        ),
      );
    },
  );

  // A body taller than the screen scrolls between a fixed header and footer.
  goldenMatrix(
    'overlays_dialog_scrolling',
    size: const Size(640, 420),
    _anchor,
    act: (t) async {
      AerosDialog.show<void>(
        t.element(find.byKey(const Key('anchor'))),
        builder: (context) => AerosDialog(
          title: 'Terms of supply',
          content: Text(List.filled(30, 'Orders are fulfilled by the seller named on the invoice.').join(' ')),
          actions: [
            AerosButton.secondary(label: 'Decline', onPressed: () {}),
            AerosButton(label: 'Accept', onPressed: () {}),
          ],
        ),
      );
    },
  );

  goldenMatrix(
    'overlays_dialog_close_focused',
    size: const Size(640, 320),
    _anchor,
    act: (t) async {
      AerosDialog.show<void>(
        t.element(find.byKey(const Key('anchor'))),
        builder: (context) => const AerosDialog(
          title: 'Keyboard shortcuts',
          content: Text('Press ? anywhere to see the shortcuts for the screen you are on.'),
        ),
      );
      await t.pumpAndSettle();
      await focus(t, find.byType(AerosDialog));
    },
  );

  // ─── Sheet ───
  for (final side in AerosSheetSide.values) {
    goldenMatrix(
      'overlays_sheet_${side.name}',
      size: side == AerosSheetSide.bottom ? const Size(420, 640) : const Size(900, 560),
      _anchor,
      act: (t) async {
        AerosSheet.show<void>(
          t.element(find.byKey(const Key('anchor'))),
          side: side,
          size: AerosSheetSize.sm,
          builder: (context) => AerosSheet(
            title: 'Filter orders',
            description: 'Showing 128 orders.',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AerosTextField(label: 'Buyer', hint: 'Any buyer'),
                const SizedBox(height: 12),
                AerosEnumChips(
                  label: 'Status',
                  options: const [
                    AerosAttributeOption(id: 'paid', label: 'Paid'),
                    AerosAttributeOption(id: 'pending', label: 'Pending'),
                    AerosAttributeOption(id: 'overdue', label: 'Overdue'),
                  ],
                  selectedId: 'pending',
                  onChanged: (_) {},
                ),
              ],
            ),
            actions: [
              AerosButton.secondary(label: 'Reset', onPressed: () {}),
              AerosButton(label: 'Apply', onPressed: () {}),
            ],
          ),
        );
      },
    );
  }

  // ─── Menu ───
  List<AerosMenuEntry> menuItems() => [
        const AerosMenuLabel('Order #4821'),
        AerosMenuItem<void>(label: 'Open', leading: const Icon(Icons.open_in_new), shortcut: '↵', onSelected: () {}),
        AerosMenuItem<void>(label: 'Duplicate', leading: const Icon(Icons.copy_outlined), shortcut: '⌘D', onSelected: () {}),
        AerosMenuItem<void>(
          label: 'Export invoice',
          leading: const Icon(Icons.download_outlined),
          enabled: false,
          onSelected: () {},
        ),
        const AerosMenuSeparator(),
        AerosMenuCheckboxItem(label: 'Pin to top', checked: true, onChanged: (_) {}),
        AerosMenuCheckboxItem(label: 'Mute updates', checked: false, onChanged: (_) {}),
        const AerosMenuSeparator(),
        const AerosMenuLabel('Density'),
        AerosMenuRadioItem<String>(label: 'Compact', value: 'c', groupValue: 'c', onChanged: (_) {}),
        AerosMenuRadioItem<String>(label: 'Comfortable', value: 'm', groupValue: 'c', onChanged: (_) {}),
        const AerosMenuSeparator(),
        AerosMenuItem<void>(
          label: 'Delete order',
          leading: const Icon(Icons.delete_outline),
          destructive: true,
          onSelected: () {},
        ),
      ];

  Widget menuScene(BuildContext context) => AerosMenu(
        items: menuItems(),
        trigger: (context, menu) => AerosButton(
          key: const Key('target'),
          label: 'Actions',
          variant: AerosButtonVariant.secondary,
          trailing: const Icon(Icons.keyboard_arrow_down),
          onPressed: menu.toggle,
        ),
      );

  goldenMatrix(
    'overlays_menu',
    size: const Size(360, 560),
    menuScene,
    act: (t) => t.tap(find.byKey(const Key('target'))),
  );

  goldenMatrix(
    'overlays_menu_row_highlighted',
    size: const Size(360, 560),
    menuScene,
    act: (t) async {
      await t.tap(find.byKey(const Key('target')));
      await t.pumpAndSettle();
      await hover(t, find.text('Duplicate'));
    },
  );

  goldenMatrix(
    'overlays_menu_destructive_highlighted',
    size: const Size(360, 560),
    menuScene,
    act: (t) async {
      await t.tap(find.byKey(const Key('target')));
      await t.pumpAndSettle();
      await hover(t, find.text('Delete order'));
    },
  );

  // At the bottom-right corner the menu flips above and is pulled inside.
  goldenMatrix(
    'overlays_menu_at_edge',
    size: const Size(360, 560),
    padded: false,
    (context) => Scaffold(
      body: Align(
        alignment: Alignment.bottomRight,
        child: Padding(padding: const EdgeInsets.all(8), child: menuScene(context)),
      ),
    ),
    act: (t) => t.tap(find.byKey(const Key('target'))),
  );

  goldenMatrix(
    'overlays_popover',
    size: const Size(360, 260),
    (context) => AerosPopover(
      trigger: (context, popover) => AerosButton.secondary(
        key: const Key('target'),
        label: 'Share',
        onPressed: popover.toggle,
      ),
      content: (context) => SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Share this order', style: AerosTypography.labelMd(color: context.aerosColors.fgPrimary)),
            const SizedBox(height: 4),
            Text(
              'Anyone with the link can view it.',
              style: AerosTypography.caption(color: context.aerosColors.fgSecondary),
            ),
            const SizedBox(height: 12),
            AerosButton(label: 'Copy link', size: AerosControlSize.sm, fullWidth: true, onPressed: () {}),
          ],
        ),
      ),
    ),
    act: (t) => t.tap(find.byKey(const Key('target'))),
  );

  // ─── Select ───
  const materials = [
    AerosSelectItem(value: 'kraft', label: 'Kraft'),
    AerosSelectItem(value: 'white', label: 'White board'),
    AerosSelectItem(value: 'pe', label: 'PE coated', enabled: false, detail: 'Not for this size'),
    AerosSelectItem(value: 'pla', label: 'PLA lined'),
  ];

  goldenMatrix(
    'overlays_select',
    size: const Size(720, 420),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 320,
          children: [
            GoldenSection(
              'AerosSelect placeholder, helper',
              child: AerosSelect<String>(
                label: 'Material',
                placeholder: 'Select…',
                helper: 'Shown on the quote.',
                required: true,
                items: materials,
                value: null,
                onChanged: (_) {},
              ),
            ),
            GoldenSection(
              'AerosSelect with a value',
              child: AerosSelect<String>(label: 'Material', items: materials, value: 'white', onChanged: (_) {}),
            ),
            GoldenSection(
              'AerosSelect error',
              child: AerosSelect<String>(
                label: 'Material',
                placeholder: 'Select…',
                error: 'Choose a material',
                items: materials,
                value: null,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
        GoldenColumn(
          width: 320,
          children: [
            GoldenSection(
              'AerosSelect disabled',
              child: AerosSelect<String>(
                label: 'Material',
                items: materials,
                value: 'kraft',
                enabled: false,
                onChanged: (_) {},
              ),
            ),
            for (final size in [AerosControlSize.sm, AerosControlSize.lg])
              GoldenSection(
                'AerosSelect ${size.name}, no label',
                child: AerosSelect<String>(size: size, items: materials, value: 'kraft', onChanged: (_) {}),
              ),
          ],
        ),
      ],
    ),
  );

  Widget selectScene(BuildContext context, {String? error}) => SizedBox(
        width: 320,
        child: AerosSelect<String>(
          key: const Key('target'),
          label: 'Material',
          placeholder: 'Select…',
          error: error,
          items: materials,
          value: error == null ? 'white' : null,
          onChanged: (_) {},
        ),
      );

  goldenMatrix(
    'overlays_select_open',
    size: const Size(400, 320),
    selectScene,
    act: (t) => t.tap(find.byType(AerosFieldFrame)),
  );

  goldenMatrix(
    'overlays_select_error_open',
    size: const Size(400, 320),
    (context) => selectScene(context, error: 'Choose a material'),
    act: (t) => t.tap(find.byType(AerosFieldFrame)),
  );

  goldenMatrix(
    'overlays_select_focused',
    size: const Size(400, 140),
    selectScene,
    act: (t) => focus(t, find.byKey(const Key('target'))),
  );

  // A long list in the menu presentation: the viewport ends on a whole row.
  goldenMatrix(
    'overlays_dropdown_search_menu_long',
    size: const Size(400, 520),
    (context) => SizedBox(
      width: 320,
      child: AerosDropdownSearch<String>(
        key: const Key('target'),
        label: 'City',
        hint: 'Select a city',
        items: [for (var i = 1; i <= 40; i++) 'Warehouse $i'],
        selectedItem: 'Warehouse 3',
        itemAsString: (s) => s,
        onChanged: (_) {},
        mode: AerosDropdownMode.menu,
        showSearchBox: false,
      ),
    ),
    act: (t) => t.tap(find.byType(AerosFieldFrame)),
  );
}
