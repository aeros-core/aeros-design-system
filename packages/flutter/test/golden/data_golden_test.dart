import 'dart:async';

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

class _Order {
  const _Order(this.id, this.buyer, this.status, this.tone, this.total);

  final String id;
  final String buyer;
  final String status;
  final AerosBadgeTone tone;
  final String total;
}

const _orders = [
  _Order('#4821', 'Boson Machines', 'Paid', AerosBadgeTone.success, '₹ 48,200'),
  _Order('#4820', 'Lorven Foods', 'Pending', AerosBadgeTone.warning, '₹ 12,750'),
  _Order('#4819', 'Kiran Traders', 'Overdue', AerosBadgeTone.danger, '₹ 6,400'),
  _Order('#4818', 'Shree Packaging', 'Draft', AerosBadgeTone.neutral, '₹ 91,000'),
];

List<AerosDataColumn<_Order>> _columns(BuildContext context) => [
      AerosDataColumn(label: 'Order', sortable: true, cell: (o) => Text(o.id)),
      AerosDataColumn(label: 'Buyer', sortable: true, cell: (o) => Text(o.buyer)),
      AerosDataColumn(label: 'Status', cell: (o) => AerosBadge(label: o.status, tone: o.tone)),
      AerosDataColumn(label: 'Total', numeric: true, sortable: true, cell: (o) => Text(o.total)),
    ];

const _variants = [
  AerosVariantOption(id: 'ink', label: 'Ink', sku: 'CUP-250-INK', swatchColor: 0xFF1A1917, stockQty: 1200),
  AerosVariantOption(id: 'kraft', label: 'Kraft', sku: 'CUP-250-KRF', swatchColor: 0xFFB08D57, stockQty: 8),
  AerosVariantOption(id: 'white', label: 'White', sku: 'CUP-250-WHT', swatchColor: 0xFFFFFFFF, stockQty: 0),
  AerosVariantOption(
    id: 'gold',
    label: 'Gold foil',
    swatchColor: 0xFFC9A227,
    disabled: true,
    disabledReason: 'Not offered at this size',
  ),
];

const _breakdown = AerosPriceBreakdownData(
  currencySymbol: '₹',
  quantity: 1000,
  discountableSubtotal: 6500,
  nonDiscountableSubtotal: 500,
  total: 6650,
  steps: [
    AerosBreakdownStep(name: 'Base price · 350 ml', kind: 'BASE_PRICE', amount: 4.5, perUnit: true),
    AerosBreakdownStep(
      name: 'GSM 250',
      kind: 'MODIFIER',
      modifierKey: 'gsm_250',
      modifierVersion: 3,
      amount: 2,
      perUnit: true,
      note: 'Heavier board',
    ),
    AerosBreakdownStep(name: 'Printing plate', kind: 'SETUP', amount: 500, discountable: false),
    AerosBreakdownStep(name: 'Volume discount', kind: 'DISCOUNT', amount: -350),
  ],
);

const _materialSpec = AerosAttributeSpec(
  key: 'material',
  label: 'Material',
  datatype: AerosAttributeDatatype.enumValue,
  optionSource: AerosAttributeOptionSource.enumOptions,
  required: true,
  helperText: 'Board the cup is formed from',
  options: [
    AerosAttributeOption(id: 'kraft', label: 'Kraft'),
    AerosAttributeOption(id: 'white', label: 'White board'),
    AerosAttributeOption(id: 'pe', label: 'PE coated', disabled: true, disabledReason: 'Not for this size'),
  ],
);

const _gsmSpec = AerosAttributeSpec(
  key: 'gsm',
  label: 'Paper weight',
  datatype: AerosAttributeDatatype.measurement,
  optionSource: AerosAttributeOptionSource.range,
  range: AerosNumericRange(min: 150, max: 350, step: 10),
  units: [AerosMeasurementUnit(code: 'gsm', label: 'gsm')],
  defaultUnit: 'gsm',
);

const _heightSpec = AerosAttributeSpec(
  key: 'height',
  label: 'Height',
  datatype: AerosAttributeDatatype.measurement,
  optionSource: AerosAttributeOptionSource.range,
  range: AerosNumericRange(min: 40, max: 200),
  units: [AerosMeasurementUnit(code: 'mm', label: 'mm'), AerosMeasurementUnit(code: 'in', label: 'in')],
  defaultUnit: 'mm',
);

const _lidSpec = AerosAttributeSpec(
  key: 'lid',
  label: 'Include lid',
  datatype: AerosAttributeDatatype.boolean,
  optionSource: AerosAttributeOptionSource.enumOptions,
  helperText: 'Adds a matching sip lid',
);

const _artworkSpec = AerosAttributeSpec(
  key: 'artwork',
  label: 'Artwork',
  datatype: AerosAttributeDatatype.enumValue,
  optionSource: AerosAttributeOptionSource.file,
);

const _lockedSpec = AerosAttributeSpec(
  key: 'coating',
  label: 'Coating',
  datatype: AerosAttributeDatatype.enumValue,
  optionSource: AerosAttributeOptionSource.enumOptions,
  lockedByAdmin: true,
  options: [
    AerosAttributeOption(id: 'pla', label: 'PLA'),
    AerosAttributeOption(id: 'pe', label: 'PE'),
  ],
);

const _file = AerosFileRef(id: 'f1', name: 'cup-artwork-v3.pdf', sizeBytes: 2411724, mimeType: 'application/pdf');

void main() {
  goldenMatrix(
    'data_table',
    size: const Size(760, 720),
    (context) => GoldenColumn(
      width: 720,
      children: [
        GoldenSection(
          'AerosDataTable rows, ascending sort on Order',
          child: AerosDataTable<_Order>(
            rows: _orders,
            columns: _columns(context),
            sort: const AerosDataSort(columnIndex: 0, ascending: true),
            onSortChanged: (_) {},
            onRowTap: (_) {},
          ),
        ),
        GoldenSection(
          'AerosDataTable selection (one row selected), descending sort on Total, footer',
          child: AerosDataTable<_Order>(
            rows: _orders,
            columns: _columns(context),
            selected: {_orders[1]},
            onSelectionChanged: (_) {},
            sort: const AerosDataSort(columnIndex: 3, ascending: false),
            onSortChanged: (_) {},
            footer: Align(
              alignment: Alignment.centerRight,
              child: AerosPagination(page: 2, totalPages: 9, onChanged: (_) {}),
            ),
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'data_table_all_selected',
    size: const Size(760, 320),
    (context) => SizedBox(
      width: 720,
      child: AerosDataTable<_Order>(
        rows: _orders,
        columns: _columns(context),
        selected: _orders.toSet(),
        onSelectionChanged: (_) {},
      ),
    ),
  );

  goldenMatrix(
    'data_table_empty',
    size: const Size(760, 620),
    (context) => GoldenColumn(
      width: 720,
      children: [
        GoldenSection(
          'AerosDataTable no rows, with emptyState',
          child: AerosDataTable<_Order>(
            rows: const [],
            columns: _columns(context),
            emptyState: const AerosEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              description: 'Orders you receive will show up here.',
            ),
          ),
        ),
        GoldenSection(
          'AerosDataTable no rows, no emptyState',
          child: AerosDataTable<_Order>(rows: const [], columns: _columns(context)),
        ),
      ],
    ),
  );

  // The loading spinner never stops, so it is caught at a fixed frame.
  goldenMatrix(
    'data_table_loading',
    size: const Size(760, 320),
    settle: GoldenSettle.bounded,
    (context) => SizedBox(
      width: 720,
      child: AerosDataTable<_Order>(rows: _orders, columns: _columns(context), loading: true),
    ),
  );

  goldenMatrix(
    'data_table_row_hovered',
    size: const Size(760, 320),
    (context) => SizedBox(
      width: 720,
      child: AerosDataTable<_Order>(rows: _orders, columns: _columns(context), onRowTap: (_) {}),
    ),
    act: (t) => hover(t, find.text('Lorven Foods')),
  );

  // Mono amounts render in the test font until IBM Plex Mono is bundled.
  goldenMatrix(
    'data_price_breakdown',
    size: const Size(860, 560),
    (context) => const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 400,
          children: [
            GoldenSection('AerosPriceBreakdown collapsed', child: AerosPriceBreakdown(data: _breakdown)),
            GoldenSection(
              'AerosPriceBreakdown expanded',
              child: AerosPriceBreakdown(data: _breakdown, initiallyExpanded: true),
            ),
          ],
        ),
        SizedBox(width: 24),
        GoldenColumn(
          width: 400,
          children: [
            GoldenSection(
              'AerosPriceBreakdown dense, collapsed',
              child: AerosPriceBreakdown(data: _breakdown, dense: true, title: 'Your price'),
            ),
            GoldenSection(
              'AerosPriceBreakdown dense, expanded',
              child: AerosPriceBreakdown(data: _breakdown, dense: true, initiallyExpanded: true, title: 'Your price'),
            ),
          ],
        ),
      ],
    ),
  );

  goldenMatrix(
    'data_variant_picker',
    size: const Size(600, 640),
    (context) => GoldenColumn(
      width: 560,
      children: [
        GoldenSection(
          'AerosVariantPicker chip',
          child: AerosVariantPicker(variants: _variants, selectedVariantId: 'ink', onChanged: (_) {}, required: true),
        ),
        GoldenSection(
          'AerosVariantPicker chip, no stock badges, nothing selected',
          child: AerosVariantPicker(
            variants: _variants,
            selectedVariantId: null,
            onChanged: (_) {},
            showStockBadge: false,
            label: 'Colour',
          ),
        ),
        GoldenSection(
          'AerosVariantPicker swatch',
          child: AerosVariantPicker(
            variants: _variants,
            selectedVariantId: 'kraft',
            onChanged: (_) {},
            style: AerosVariantPickerStyle.swatch,
          ),
        ),
        GoldenSection(
          'AerosVariantPicker swatch, error',
          child: AerosVariantPicker(
            variants: _variants,
            selectedVariantId: null,
            onChanged: (_) {},
            style: AerosVariantPickerStyle.swatch,
            required: true,
            errorText: 'Choose a variant',
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'data_attribute_selector',
    size: const Size(800, 720),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 360,
          children: [
            GoldenSection(
              'enum, auto (chips under the threshold)',
              child: AerosAttributeSelector(
                spec: _materialSpec,
                value: const AerosAttributeValue(enumValueId: 'kraft'),
                onChanged: (_) {},
              ),
            ),
            GoldenSection(
              'enum, forced dropdown',
              child: AerosAttributeSelector(
                spec: _materialSpec,
                value: const AerosAttributeValue(enumValueId: 'white'),
                onChanged: (_) {},
                forceVariant: AerosAttributeInputVariant.dropdown,
              ),
            ),
            GoldenSection(
              'enum, required but missing, error',
              child: AerosAttributeSelector(
                spec: _materialSpec,
                value: const AerosAttributeValue(),
                onChanged: (_) {},
                requiredButMissing: true,
                errorText: 'Choose a material',
              ),
            ),
            GoldenSection(
              'enum, locked by admin',
              child: AerosAttributeSelector(
                spec: _lockedSpec,
                value: const AerosAttributeValue(enumValueId: 'pla'),
                onChanged: (_) {},
              ),
            ),
            GoldenSection(
              'boolean (switch row)',
              child: AerosAttributeSelector(
                spec: _lidSpec,
                value: const AerosAttributeValue(boolValue: true),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 360,
          children: [
            GoldenSection(
              'range, auto',
              child: AerosAttributeSelector(
                spec: _gsmSpec,
                value: const AerosAttributeValue(numericValue: 250, unitCode: 'gsm'),
                onChanged: (_) {},
              ),
            ),
            GoldenSection(
              'range, forced slider',
              child: AerosAttributeSelector(
                spec: _gsmSpec,
                value: const AerosAttributeValue(numericValue: 250, unitCode: 'gsm'),
                onChanged: (_) {},
                forceVariant: AerosAttributeInputVariant.slider,
              ),
            ),
            GoldenSection(
              'range, forced measurement',
              child: AerosAttributeSelector(
                spec: _heightSpec,
                value: const AerosAttributeValue(numericValue: 120, unitCode: 'mm'),
                onChanged: (_) {},
                forceVariant: AerosAttributeInputVariant.measurement,
              ),
            ),
            GoldenSection(
              'file',
              child: AerosAttributeSelector(
                spec: _artworkSpec,
                value: const AerosAttributeValue(fileRef: _file),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ],
    ),
  );

  goldenMatrix(
    'data_repeating_rows',
    size: const Size(520, 920),
    (context) => GoldenColumn(
      width: 480,
      children: [
        GoldenSection(
          'AerosRepeatingRows',
          child: AerosRepeatingRows<String>(
            label: 'Delivery addresses',
            helperText: 'Add every site we should ship to',
            required: true,
            items: const ['Plot 14, GIDC, Ahmedabad', 'Unit 3, MIDC, Pune'],
            itemBuilder: (context, index, item) => AerosTextField(controller: TextEditingController(text: item)),
            onAdd: () {},
            onRemove: (_) {},
            addLabel: 'Add address',
          ),
        ),
        GoldenSection(
          'AerosRepeatingRows at the minimum (remove hidden or disabled)',
          child: AerosRepeatingRows<String>(
            label: 'Contacts',
            items: const ['parth@example.com'],
            itemBuilder: (context, index, item) => AerosTextField(controller: TextEditingController(text: item)),
            onAdd: () {},
            onRemove: (_) {},
            addLabel: 'Add contact',
          ),
        ),
        GoldenSection(
          'AerosRepeatingRows at the maximum, with error',
          child: AerosRepeatingRows<String>(
            label: 'Contacts',
            items: const ['a@example.com', 'b@example.com'],
            itemBuilder: (context, index, item) => AerosTextField(controller: TextEditingController(text: item)),
            onAdd: () {},
            onRemove: (_) {},
            addLabel: 'Add contact',
            maxItems: 2,
            errorText: 'Two contacts at most',
          ),
        ),
        GoldenSection(
          'AerosRepeatingRows without remove',
          child: AerosRepeatingRows<String>(
            items: const ['Fixed row'],
            itemBuilder: (context, index, item) => AerosTextField(controller: TextEditingController(text: item)),
            onAdd: () {},
            addLabel: 'Add row',
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'data_file_upload',
    size: const Size(440, 960),
    (context) => GoldenColumn(
      width: 400,
      children: [
        GoldenSection(
          'AerosFileUploadButton empty',
          child: AerosFileUploadButton(label: 'Artwork', value: null, onPickFile: () async => null, required: true),
        ),
        GoldenSection(
          'AerosFileUploadButton with a file',
          child: AerosFileUploadButton(
            label: 'Artwork',
            value: _file,
            onPickFile: () async => null,
            onRemove: () {},
          ),
        ),
        GoldenSection(
          'AerosFileUploadButton with a file, no remove',
          child: AerosFileUploadButton(value: _file, onPickFile: () async => null),
        ),
        GoldenSection(
          'AerosFileUploadButton error',
          child: AerosFileUploadButton(
            label: 'Artwork',
            value: null,
            onPickFile: () async => null,
            errorText: 'Artwork is required for printed cups',
            hint: 'Upload print file',
            acceptHint: 'PDF or AI, up to 25 MB',
          ),
        ),
        GoldenSection(
          'AerosFileUploadButton disabled',
          child: AerosFileUploadButton(label: 'Artwork', value: null, onPickFile: () async => null, enabled: false),
        ),
        GoldenSection(
          'AerosFileUploadButton disabled with a file',
          child: AerosFileUploadButton(value: _file, onPickFile: () async => null, onRemove: () {}, enabled: false),
        ),
      ],
    ),
  );

  // While the picker is open the button shows a spinner; the pick is left
  // pending and the frame is caught at a fixed time.
  final pending = Completer<AerosFileRef?>();
  goldenMatrix(
    'data_file_upload_busy',
    size: const Size(440, 190),
    settle: GoldenSettle.bounded,
    (context) => SizedBox(
      width: 400,
      child: AerosFileUploadButton(
        key: const Key('target'),
        label: 'Artwork',
        value: null,
        onPickFile: () => pending.future,
      ),
    ),
    act: (t) => t.tap(find.byType(InkWell).first),
  );
}
