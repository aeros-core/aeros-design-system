import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../sample_data.dart';
import '../shell.dart';
import '../widgets/gallery_page.dart';

/// Pattern: a form screen. Fields grouped in cards in the main column, a
/// live summary in the aside, validation on submit, and a confirmation.
class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _quantity = TextEditingController(text: '1000');
  String? _buyer;
  String? _terms = 'net30';
  String? _colour = 'kraft';
  AerosAttributeValue _size = const AerosAttributeValue();
  AerosAttributeValue _gsm = const AerosAttributeValue(numericValue: 250, unitCode: 'gsm');
  AerosAttributeValue _lid = const AerosAttributeValue(boolValue: false);
  bool _printed = true;
  AerosFileRef? _artwork;
  List<String> _addresses = [''];
  List<String> _tags = [];
  bool _submitted = false;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  int get _units => int.tryParse(_quantity.text) ?? 0;

  /// What is still missing, keyed by field. Shown only after a first submit.
  Map<String, String> get _errors => {
        if (_buyer == null) 'buyer': 'Choose a buyer',
        if (_size.enumValueId == null) 'size': 'Choose a cup size',
        if (_units < 500) 'quantity': 'The minimum order is 500 cups',
        if (_printed && _artwork == null) 'artwork': 'Printed cups need artwork',
        if (_addresses.every((a) => a.trim().isEmpty)) 'address': 'Add a delivery address',
      };

  String? _error(String key) => _submitted ? _errors[key] : null;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_errors.isNotEmpty) {
      AerosSnackbar.show(
        context,
        '${_errors.length} ${_errors.length == 1 ? 'field needs' : 'fields need'} attention',
        tone: AerosSnackbarTone.danger,
      );
      return;
    }
    final ok = await AerosConfirmDialog.show(
      context,
      title: 'Place this order?',
      body: '$_buyer will be invoiced ${rupees(_price.total)} on ${_terms == 'advance' ? 'advance' : 'credit'} terms.',
      confirmLabel: 'Place order',
    );
    if (!ok || !mounted) return;
    AerosSnackbar.show(context, 'Order placed', tone: AerosSnackbarTone.success);
    GalleryNav.of(context).open('orders');
  }

  AerosPriceBreakdownData get _price => priceFor(
        quantity: _units,
        gsm: _gsm.numericValue ?? 250,
        printed: _printed,
      );

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final done = 5 - _errors.length;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AerosCard(
          title: 'Buyer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosFormField(
                // The search dropdown draws its own label but no error text.
                errorText: _error('buyer'),
                child: AerosDropdownSearch<String>(
                  label: 'Buyer',
                  required: true,
                  hint: 'Search buyers',
                  popupTitle: 'Choose a buyer',
                  items: [for (final order in orders) order.buyer],
                  selectedItem: _buyer,
                  itemAsString: (buyer) => buyer,
                  onChanged: (buyer) => setState(() => _buyer = buyer),
                ),
              ),
              const SizedBox(height: AerosSpacing.s4),
              AerosSelect<String>(
                label: 'Payment terms',
                value: _terms,
                onChanged: (value) => setState(() => _terms = value),
                items: const [
                  AerosSelectItem(value: 'advance', label: 'Advance'),
                  AerosSelectItem(value: 'net15', label: 'Net 15'),
                  AerosSelectItem(value: 'net30', label: 'Net 30'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AerosSpacing.s4),
        AerosCard(
          title: 'Product',
          subtitle: 'Paper cup, made to order',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosAttributeSelector(
                spec: sizeSpec,
                value: _size,
                requiredButMissing: _submitted,
                errorText: _error('size'),
                onChanged: (value) => setState(() => _size = value),
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosVariantPicker(
                label: 'Colour',
                variants: variants,
                selectedVariantId: _colour,
                onChanged: (id) => setState(() => _colour = id),
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosAttributeSelector(spec: gsmSpec, value: _gsm, onChanged: (v) => setState(() => _gsm = v)),
              const SizedBox(height: AerosSpacing.s5),
              AerosAttributeSelector(spec: lidSpec, value: _lid, onChanged: (v) => setState(() => _lid = v)),
              const SizedBox(height: AerosSpacing.s5),
              AerosTextField(
                label: 'Quantity',
                required: true,
                controller: _quantity,
                keyboardType: TextInputType.number,
                suffix: Text('cups', style: AerosTypography.bodySm(color: a.fgMuted)),
                helperText: 'Minimum 500. 5% off from 1,000.',
                errorText: _error('quantity'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: AerosSpacing.s4),
        AerosCard(
          title: 'Printing',
          trailing: AerosSwitch(
            value: _printed,
            semanticLabel: 'Printed',
            onChanged: (value) => setState(() => _printed = value),
          ),
          child: _printed
              ? AerosFileUploadButton(
                  label: 'Artwork',
                  required: true,
                  value: _artwork,
                  errorText: _error('artwork'),
                  onPickFile: () async {
                    await Future<void>.delayed(const Duration(milliseconds: 500));
                    if (mounted) setState(() => _artwork = artworkFile);
                    return artworkFile;
                  },
                  onRemove: () => setState(() => _artwork = null),
                )
              : Text('Plain cups — no artwork needed.', style: AerosTypography.bodySm(color: a.fgSecondary)),
        ),
        const SizedBox(height: AerosSpacing.s4),
        AerosCard(
          title: 'Delivery',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosRepeatingRows<String>(
                label: 'Addresses',
                required: true,
                maxItems: 3,
                addLabel: 'Add address',
                errorText: _error('address'),
                items: _addresses,
                onAdd: () => setState(() => _addresses = [..._addresses, '']),
                onRemove: (index) => setState(() => _addresses = [..._addresses]..removeAt(index)),
                itemBuilder: (context, index, address) => AerosTextField(
                  key: ValueKey('address-$index-${_addresses.length}'),
                  hint: 'Address ${index + 1}',
                  controller: TextEditingController(text: address),
                  onChanged: (text) => setState(() => _addresses[index] = text),
                ),
              ),
              const SizedBox(height: AerosSpacing.s4),
              AerosTagField(label: 'Labels', tags: _tags, onChanged: (tags) => setState(() => _tags = tags)),
            ],
          ),
        ),
      ],
    );

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AerosCard(
          title: 'Summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosStepper(currentStep: done.clamp(1, 5), totalSteps: 5, label: 'Required fields complete'),
              const SizedBox(height: AerosSpacing.s4),
              AerosPriceBreakdown(data: _price, initiallyExpanded: true, dense: true),
              if (_units >= 100000) ...[
                const SizedBox(height: AerosSpacing.s3),
                const AerosRoutingSignalBadge(
                  signal: AerosRoutingSignal(
                    kind: 'requires_rfq',
                    label: 'Above 100k — goes to a quote',
                    severity: AerosRoutingSeverity.warn,
                  ),
                ),
              ],
              const SizedBox(height: AerosSpacing.s4),
              AerosButton(label: 'Place order', fullWidth: true, onPressed: _submit),
              const SizedBox(height: AerosSpacing.s2),
              AerosButton(
                label: 'Cancel',
                fullWidth: true,
                variant: AerosButtonVariant.ghost,
                onPressed: () => GalleryNav.of(context).open('orders'),
              ),
            ],
          ),
        ),
      ],
    );

    return GalleryPage(
      title: 'New order',
      summary: 'Configure the product, then place the order.',
      breadcrumbs: [
        AerosBreadcrumbItem('Orders', onTap: () => GalleryNav.of(context).open('orders')),
        const AerosBreadcrumbItem('New order'),
      ],
      children: [
        if (_submitted && _errors.isNotEmpty) ...[
          AerosAlert(
            tone: AerosAlertTone.danger,
            title: 'Not ready yet',
            body: _errors.values.join(' · '),
          ),
          const SizedBox(height: AerosSpacing.s4),
        ],
        AerosTwoColumn(breakpoint: AerosBreakpoint.lg, primary: form, aside: summary),
      ],
    );
  }
}
