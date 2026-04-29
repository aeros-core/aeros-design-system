import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});
  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aeros DS',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      home: Gallery(onToggleTheme: () {
        setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
      }),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _tab = 0;
  bool _check = true;
  bool _switch = true;
  String _radio = 'a';
  double _progress = 0.64;

  // Configurable-MTO gallery state.
  AerosAttributeValue _cupSize = const AerosAttributeValue(enumValueId: '350ml');
  AerosAttributeValue _gsm = const AerosAttributeValue(numericValue: 250);
  AerosAttributeValue _printed = const AerosAttributeValue(boolValue: true);
  AerosAttributeValue _quantity = const AerosAttributeValue(
    numericValue: 1000,
    unitCode: 'pcs',
  );
  AerosAttributeValue _artwork = const AerosAttributeValue();
  String? _variantId = 'red';

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aeros UI Kit'),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6_outlined), onPressed: widget.onToggleTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Text('Run everything.', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Complete component library for the Aeros platform.',
              style: AerosTypography.bodyMd(color: a.fgMuted),
            ),
            const SizedBox(height: 32),

            _section('Buttons'),
            Wrap(spacing: 10, runSpacing: 10, children: [
              AerosButton.primary(label: 'Primary', onPressed: () {}),
              AerosButton.secondary(label: 'Secondary', onPressed: () {}),
              AerosButton.ghost(label: 'Ghost', onPressed: () {}),
              AerosButton.danger(label: 'Danger', onPressed: () {}),
              const AerosButton(label: 'Loading', onPressed: null, loading: true),
            ]),
            const SizedBox(height: 32),

            _section('Badges & tags'),
            Wrap(spacing: 8, runSpacing: 8, children: const [
              AerosBadge(label: 'Active', tone: AerosBadgeTone.green),
              AerosBadge(label: 'Pending', tone: AerosBadgeTone.amber),
              AerosBadge(label: 'Failed', tone: AerosBadgeTone.red),
              AerosBadge(label: 'New', tone: AerosBadgeTone.blue),
              AerosTag(label: 'RFQ-0042', tone: AerosTagTone.blue),
              AerosTag(label: 'v1.0', tone: AerosTagTone.grey),
            ]),
            const SizedBox(height: 32),

            _section('Stat cards'),
            Row(children: const [
              Expanded(child: AerosStatCard(label: 'Output', value: '4,820', delta: '+8%', deltaDirection: AerosDelta.up)),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'RFQ value', value: '₹1,24,000', mono: true, delta: '-2%', deltaDirection: AerosDelta.down)),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'Attendance', value: '96%', delta: 'Steady', deltaDirection: AerosDelta.flat)),
            ]),
            const SizedBox(height: 32),

            _section('Card'),
            AerosCard(
              title: "Today's production",
              subtitle: 'Line 3 · updated 3 min ago',
              trailing: const AerosBadge(label: 'Live', tone: AerosBadgeTone.green),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('8% above yesterday', style: AerosTypography.caption(color: a.fgMuted)),
                  AerosButton(label: 'View', onPressed: () {}, size: AerosButtonSize.sm, variant: AerosButtonVariant.secondary),
                ],
              ),
              child: AerosProgress(label: 'Output', value: _progress),
            ),
            const SizedBox(height: 32),

            _section('Alerts'),
            Column(children: const [
              AerosAlert(tone: AerosAlertTone.blue, title: 'Heads up', body: 'New RFQ available for review.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.green, title: 'Approved', body: 'Order passed QC checks.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.amber, title: 'Delayed', body: 'Shipment running 2 hours behind.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.red, title: 'Failed', body: 'Line 4 halted — check sensor 2.'),
            ]),
            const SizedBox(height: 32),

            _section('Form'),
            AerosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AerosTextField(label: 'Buyer name', hint: 'Pacific Pack Co.', required: true),
                  const SizedBox(height: 16),
                  const AerosTextField(label: 'Email', hint: 'priya@pacificpack.co'),
                  const SizedBox(height: 16),
                  Row(children: [
                    AerosCheckbox(value: _check, onChanged: (v) => setState(() => _check = v ?? false)),
                    const SizedBox(width: 8),
                    Text('I agree to the Terms', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    AerosRadio<String>(value: 'a', groupValue: _radio, onChanged: (v) => setState(() => _radio = v!)),
                    const SizedBox(width: 8),
                    Text('Option A', style: AerosTypography.bodySm(color: a.fgSecondary)),
                    const SizedBox(width: 16),
                    AerosRadio<String>(value: 'b', groupValue: _radio, onChanged: (v) => setState(() => _radio = v!)),
                    const SizedBox(width: 8),
                    Text('Option B', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    AerosSwitch(value: _switch, onChanged: (v) => setState(() => _switch = v)),
                    const SizedBox(width: 12),
                    Text('Enable notifications', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _section('Tabs'),
            AerosTabs(
              tabs: const ['Overview', 'Production', 'Orders', 'Team'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            AerosTabs(
              tabs: const ['Day', 'Week', 'Month'],
              selectedIndex: _tab.clamp(0, 2),
              onChanged: (i) => setState(() => _tab = i),
              variant: AerosTabVariant.pill,
            ),
            const SizedBox(height: 32),

            _section('Breadcrumb'),
            AerosBreadcrumb(items: [
              AerosBreadcrumbItem('Operations', onTap: () {}),
              AerosBreadcrumbItem('RFQs', onTap: () {}),
              const AerosBreadcrumbItem('RFQ-0042'),
            ]),
            const SizedBox(height: 32),

            _section('Avatars'),
            Row(children: const [
              AerosAvatar(initials: 'PS'),
              SizedBox(width: 12),
              AerosAvatar(initials: 'RK', tone: AerosAvatarTone.dark),
              SizedBox(width: 12),
              AerosAvatar(initials: 'MN', tone: AerosAvatarTone.green, size: AerosAvatarSize.lg),
              SizedBox(width: 12),
              AerosAvatar(initials: 'AA', tone: AerosAvatarTone.amber, size: AerosAvatarSize.xl),
            ]),
            const SizedBox(height: 32),

            _section('Empty state'),
            const AerosEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No RFQs yet',
              description: 'When buyers submit requests, they\'ll show up here. Invite your team to get started.',
            ),
            const SizedBox(height: 32),

            _section('Configurable MTO — attribute selectors'),
            AerosCard(
              title: 'Printed paper cups · 12oz',
              subtitle: 'Configure your order, see the price update live',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ENUM datatype, ≤6 options → AerosEnumChips
                  AerosAttributeSelector(
                    spec: const AerosAttributeSpec(
                      key: 'cup_size',
                      label: 'Cup size',
                      datatype: AerosAttributeDatatype.enumValue,
                      optionSource: AerosAttributeOptionSource.enumOptions,
                      required: true,
                      options: [
                        AerosAttributeOption(id: '200ml', label: '200ml'),
                        AerosAttributeOption(id: '250ml', label: '250ml'),
                        AerosAttributeOption(id: '350ml', label: '350ml'),
                        AerosAttributeOption(
                          id: '500ml',
                          label: '500ml',
                          disabled: true,
                          disabledReason: 'Out of stock for this paper weight',
                        ),
                      ],
                    ),
                    value: _cupSize,
                    onChanged: (v) => setState(() => _cupSize = v),
                  ),
                  const SizedBox(height: 20),

                  // MEASUREMENT + RANGE → AerosRangeSlider
                  AerosAttributeSelector(
                    spec: const AerosAttributeSpec(
                      key: 'paper_weight',
                      label: 'Paper weight',
                      datatype: AerosAttributeDatatype.measurement,
                      optionSource: AerosAttributeOptionSource.range,
                      range: AerosNumericRange(min: 150, max: 350, step: 25),
                      defaultUnit: 'gsm',
                      required: true,
                    ),
                    value: _gsm,
                    onChanged: (v) => setState(() => _gsm = v),
                  ),
                  const SizedBox(height: 20),

                  // BOOLEAN → switch row
                  AerosAttributeSelector(
                    spec: const AerosAttributeSpec(
                      key: 'printed',
                      label: 'Print logo on cup',
                      datatype: AerosAttributeDatatype.boolean,
                      optionSource: AerosAttributeOptionSource.enumOptions,
                    ),
                    value: _printed,
                    onChanged: (v) => setState(() => _printed = v),
                  ),
                  const SizedBox(height: 20),

                  // MEASUREMENT + free numeric input
                  AerosAttributeSelector(
                    spec: const AerosAttributeSpec(
                      key: 'quantity',
                      label: 'Order quantity',
                      datatype: AerosAttributeDatatype.measurement,
                      optionSource: AerosAttributeOptionSource.range,
                      units: [
                        AerosMeasurementUnit(code: 'pcs', label: 'pcs'),
                        AerosMeasurementUnit(code: 'ctn', label: 'cartons'),
                      ],
                      defaultUnit: 'pcs',
                      range: AerosNumericRange(min: 100, max: 500000, step: 100),
                      required: true,
                    ),
                    value: _quantity,
                    forceVariant: AerosAttributeInputVariant.measurement,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 20),

                  // FILE upload (artwork)
                  AerosAttributeSelector(
                    spec: const AerosAttributeSpec(
                      key: 'artwork',
                      label: 'Upload artwork',
                      datatype: AerosAttributeDatatype.enumValue,
                      optionSource: AerosAttributeOptionSource.file,
                    ),
                    value: _artwork,
                    onChanged: (v) => setState(() => _artwork = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _section('Variant picker'),
            AerosCard(
              child: AerosVariantPicker(
                label: 'Colour',
                selectedVariantId: _variantId,
                onChanged: (id) => setState(() => _variantId = id),
                style: AerosVariantPickerStyle.swatch,
                variants: const [
                  AerosVariantOption(
                    id: 'red',
                    label: 'Crimson',
                    sku: 'PC-12-RED',
                    swatchColor: 0xFFDC2626,
                    stockQty: 1200,
                  ),
                  AerosVariantOption(
                    id: 'blue',
                    label: 'Royal',
                    sku: 'PC-12-BLU',
                    swatchColor: 0xFF2347D9,
                    stockQty: 7,
                  ),
                  AerosVariantOption(
                    id: 'green',
                    label: 'Forest',
                    sku: 'PC-12-GRN',
                    swatchColor: 0xFF15803D,
                    stockQty: 0,
                  ),
                  AerosVariantOption(
                    id: 'kraft',
                    label: 'Kraft',
                    sku: 'PC-12-KFT',
                    swatchColor: 0xFFB45309,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _section('Routing signals'),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AerosRoutingSignalBadge(
                  signal: AerosRoutingSignal(
                    kind: 'requires_rfq',
                    label: 'Send as RFQ',
                  ),
                ),
                AerosRoutingSignalBadge(
                  signal: AerosRoutingSignal(
                    kind: 'requires_credit_check',
                    label: 'Credit review needed',
                    severity: AerosRoutingSeverity.warn,
                  ),
                ),
                AerosRoutingSignalBadge(
                  signal: AerosRoutingSignal(
                    kind: 'over_capacity',
                    label: 'Over seller capacity',
                    severity: AerosRoutingSeverity.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _section('Constraint error alert'),
            const AerosConstraintErrorAlert(
              messageByLocale: {
                'en': 'Custom Pantone print requires GSM ≥ 250.',
                'hi': 'कस्टम पैंटोन प्रिंट के लिए जीएसएम ≥ 250 चाहिए।',
              },
              locale: 'en',
            ),
            const SizedBox(height: 32),

            _section('Price breakdown'),
            const AerosPriceBreakdown(
              initiallyExpanded: true,
              data: AerosPriceBreakdownData(
                currencySymbol: '₹',
                quantity: 1000,
                discountableSubtotal: 6500,
                nonDiscountableSubtotal: 500,
                total: 7000,
                steps: [
                  AerosBreakdownStep(
                    name: 'Base price · 350ml',
                    kind: 'BASE_PRICE',
                    amount: 4.5,
                    perUnit: true,
                  ),
                  AerosBreakdownStep(
                    name: 'GSM 250',
                    kind: 'ADD_PER_UNIT',
                    amount: 0.6,
                    perUnit: true,
                    note: 'Heavier paper · +13%',
                  ),
                  AerosBreakdownStep(
                    name: 'Printed',
                    kind: 'ADD_PER_UNIT',
                    amount: 1.4,
                    perUnit: true,
                  ),
                  AerosBreakdownStep(
                    name: 'Bulk discount · ≥500',
                    kind: 'BULK_DISCOUNT',
                    amount: -0,
                    note: 'Discount built into per-unit lines',
                  ),
                  AerosBreakdownStep(
                    name: 'Plate setup',
                    kind: 'ADD_FLAT',
                    amount: 500,
                    discountable: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: AerosTypography.overline(color: AerosColors.slate400),
      ),
    );
  }
}
