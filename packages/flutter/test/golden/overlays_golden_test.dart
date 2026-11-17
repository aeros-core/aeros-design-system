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
      act: (t) => t.tap(find.byKey(const Key('target'))),
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
}
