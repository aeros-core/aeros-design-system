import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../sample_data.dart';
import '../widgets/gallery_page.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  // Table.
  AerosDataSort _sort = const AerosDataSort(columnIndex: 0, ascending: false);
  Set<Order> _selected = {};
  bool _loading = false;
  bool _empty = false;

  // Pickers.
  String? _variant = 'ink';
  String? _swatch = 'kraft';
  final Map<String, AerosAttributeValue> _values = {
    'material': const AerosAttributeValue(enumValueId: 'kraft'),
    'cup_size': const AerosAttributeValue(enumValueId: '250', unitCode: 'ml'),
    'gsm': const AerosAttributeValue(numericValue: 250, unitCode: 'gsm'),
    'lid': const AerosAttributeValue(boolValue: true),
    'coating': const AerosAttributeValue(enumValueId: 'pla'),
    'finish': const AerosAttributeValue(),
    'artwork': const AerosAttributeValue(),
  };
  List<String> _addresses = ['Plot 14, GIDC Estate, Ahmedabad'];
  AerosFileRef? _file;

  List<Order> get _rows {
    if (_empty) return const [];
    final rows = orders.take(6).toList();
    int compare(Order a, Order b) => switch (_sort.columnIndex) {
          0 => a.id.compareTo(b.id),
          1 => a.buyer.compareTo(b.buyer),
          _ => a.total.compareTo(b.total),
        };
    rows.sort((a, b) => _sort.ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  /// A stand-in for the app's file picker and upload.
  Future<AerosFileRef?> _pickFile() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return artworkFile;
  }

  Widget _attribute(AerosAttributeSpec spec, {AerosAttributeInputVariant variant = AerosAttributeInputVariant.auto}) =>
      AerosAttributeSelector(
        spec: spec,
        value: _values[spec.key]!,
        forceVariant: variant,
        onChanged: (value) => setState(() => _values[spec.key] = value),
      );

  @override
  Widget build(BuildContext context) {
    final gsm = _values['gsm']!.numericValue ?? 250;
    return GalleryPage(
      title: 'Data',
      summary: 'Records in a table, and the pickers that configure a made-to-order product.',
      children: [
        Section(
          'Data table',
          note: 'Sort by a header, select rows, veil while loading, say so when empty. '
              'The emphasised column is the one a row is known by.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Examples(
                spacing: AerosSpacing.s2,
                children: [
                  AerosButton.secondary(
                    label: 'Reload',
                    size: AerosControlSize.sm,
                    leading: const Icon(Icons.refresh),
                    onPressed: _loading ? null : _reload,
                  ),
                  AerosFilterChip(
                    label: 'Show empty',
                    selected: _empty,
                    onTap: () => setState(() => _empty = !_empty),
                  ),
                  if (_selected.isNotEmpty) AerosBadge(label: '${_selected.length} selected', showDot: false),
                ],
              ),
              const SizedBox(height: AerosSpacing.s3),
              AerosDataTable<Order>(
                rows: _rows,
                loading: _loading,
                selected: _selected,
                onSelectionChanged: (selected) => setState(() => _selected = selected),
                sort: _sort,
                onSortChanged: (sort) => setState(() => _sort = sort),
                rowSemanticLabel: (order) => 'Order ${order.id}',
                emptyState: AerosEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No orders',
                  description: 'Nothing matches these filters.',
                  action: AerosButton.secondary(
                    label: 'Clear filters',
                    size: AerosControlSize.sm,
                    onPressed: () => setState(() => _empty = false),
                  ),
                ),
                columns: [
                  AerosDataColumn(label: 'Order', sortable: true, emphasis: true, cell: (o) => Text(o.id)),
                  AerosDataColumn(label: 'Buyer', sortable: true, cell: (o) => Text(o.buyer)),
                  AerosDataColumn(label: 'City', cell: (o) => Text(o.city)),
                  AerosDataColumn(
                    label: 'Status',
                    cell: (o) => AerosBadge(label: o.status.label, tone: o.status.tone),
                  ),
                  AerosDataColumn(label: 'Total', numeric: true, sortable: true, cell: (o) => Text(o.totalLabel)),
                ],
                footer: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AerosPagination(page: 1, totalPages: 2, onChanged: (_) {}),
                ),
              ),
            ],
          ),
        ),
        Section(
          'Price breakdown',
          note: 'How a price was built. Collapsed it is the total; expanded, every step.',
          child: Tiles(
            minWidth: 320,
            children: [
              AerosPriceBreakdown(
                data: priceFor(quantity: 1000, gsm: gsm, printed: true),
                initiallyExpanded: true,
              ),
              AerosPriceBreakdown(
                data: priceFor(quantity: 500, gsm: 180, printed: false),
                title: 'Your price',
                dense: true,
              ),
            ],
          ),
        ),
        Section(
          'Variant picker',
          note: 'Purchasable variants with their stock. Chips for names, swatches for colours.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosVariantPicker(
                label: 'Colour',
                required: true,
                variants: variants,
                selectedVariantId: _variant,
                onChanged: (id) => setState(() => _variant = id),
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosVariantPicker(
                label: 'Colour (swatches)',
                style: AerosVariantPickerStyle.swatch,
                variants: variants,
                selectedVariantId: _swatch,
                onChanged: (id) => setState(() => _swatch = id),
              ),
            ],
          ),
        ),
        Section(
          'Attribute selector',
          note: 'Hand it an attribute spec; it picks the input: chips, a dropdown, a slider, a switch, a file.',
          child: Tiles(
            minWidth: 320,
            spacing: AerosSpacing.s6,
            children: [
              _attribute(materialSpec),
              _attribute(sizeSpec),
              _attribute(finishSpec),
              _attribute(gsmSpec),
              _attribute(gsmSpec, variant: AerosAttributeInputVariant.measurement),
              _attribute(lidSpec),
              _attribute(coatingSpec),
              _attribute(artworkSpec),
            ],
          ),
        ),
        Section(
          'Repeating rows',
          note: 'A list the user grows and shrinks: addresses, contacts, line items.',
          child: Stacked(
            maxWidth: AerosMetricTokens.layoutDialogMd,
            children: [
              AerosRepeatingRows<String>(
                label: 'Delivery addresses',
                helperText: 'Up to three sites',
                required: true,
                maxItems: 3,
                addLabel: 'Add address',
                items: _addresses,
                onAdd: () => setState(() => _addresses = [..._addresses, '']),
                onRemove: (index) => setState(() => _addresses = [..._addresses]..removeAt(index)),
                itemBuilder: (context, index, address) => AerosTextField(
                  // Keyed by position and count so a removed row takes its text with it.
                  key: ValueKey('address-$index-${_addresses.length}'),
                  hint: 'Address ${index + 1}',
                  controller: TextEditingController(text: address),
                  onChanged: (text) => _addresses[index] = text,
                ),
              ),
            ],
          ),
        ),
        Section(
          'File upload',
          note: 'The button calls your picker and shows what came back. The design system uploads nothing.',
          child: Stacked(
            children: [
              AerosFileUploadButton(
                label: 'Artwork',
                required: true,
                value: _file,
                onPickFile: () async {
                  final file = await _pickFile();
                  if (mounted) setState(() => _file = file);
                  return file;
                },
                onRemove: () => setState(() => _file = null),
              ),
              AerosFileUploadButton(
                label: 'Purchase order',
                value: null,
                hint: 'Upload PO',
                acceptHint: 'PDF up to 5 MB',
                errorText: 'A purchase order is required for credit terms',
                onPickFile: _pickFile,
              ),
              AerosFileUploadButton(label: 'Locked', value: artworkFile, enabled: false, onPickFile: _pickFile),
            ],
          ),
        ),
      ],
    );
  }
}
