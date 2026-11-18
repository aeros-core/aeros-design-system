import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../sample_data.dart';
import '../widgets/gallery_page.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  bool _email = true;
  bool _sms = false;
  String _shipping = 'standard';
  bool _autoRenew = true;
  int _filter = 0;
  String? _city = 'Pune';
  String? _size = '250';
  String? _colour = 'kraft';
  num? _gsm = 250;
  RangeValues _band = const RangeValues(180, 240);

  static const _filters = <(String, int)>[('All', 128), ('Open', 12), ('Overdue', 3), ('Drafts', 0)];
  static const _range = AerosNumericRange(min: 150, max: 350, step: 10);

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Selection',
      summary: 'Pick one, pick many, switch on, narrow down, choose a value.',
      children: [
        Section(
          'Checkbox',
          note: 'Many of many. The parent is tristate: mixed when only some children are on.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelledControl(
                'Notify me',
                control: AerosCheckbox(
                  value: _email && _sms ? true : (_email || _sms ? null : false),
                  tristate: true,
                  onChanged: (_) => setState(() {
                    final next = !(_email && _sms);
                    _email = next;
                    _sms = next;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AerosSpacing.s6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelledControl(
                      'By email',
                      control: AerosCheckbox(value: _email, onChanged: (v) => setState(() => _email = v ?? false)),
                    ),
                    LabelledControl(
                      'By SMS',
                      control: AerosCheckbox(value: _sms, onChanged: (v) => setState(() => _sms = v ?? false)),
                    ),
                    LabelledControl(
                      'By post (not available)',
                      enabled: false,
                      control: AerosCheckbox(value: false, enabled: false, onChanged: (_) {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Section(
          'Radio',
          note: 'One of a few, all visible.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (value, label) in const [
                ('standard', 'Standard — 5 to 7 days'),
                ('express', 'Express — 2 days'),
                ('pickup', 'Pick up from the factory'),
              ])
                LabelledControl(
                  label,
                  control: AerosRadio<String>(
                    value: value,
                    groupValue: _shipping,
                    onChanged: (v) => setState(() => _shipping = v ?? _shipping),
                  ),
                ),
              const LabelledControl(
                'Same day (not in your city)',
                enabled: false,
                control: AerosRadio<String>(value: 'same-day', groupValue: 'standard', onChanged: null),
              ),
            ],
          ),
        ),
        Section(
          'Switch',
          note: 'A setting that takes effect at once.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelledControl(
                'Reorder automatically when stock is low',
                control: AerosSwitch(value: _autoRenew, onChanged: (v) => setState(() => _autoRenew = v)),
              ),
              const LabelledControl(
                'Two-step approval (set by your admin)',
                enabled: false,
                control: AerosSwitch(value: true, onChanged: null),
              ),
              LabelledControl(
                'Compact, for a dense table row',
                control: AerosSwitch(value: _sms, compact: true, onChanged: (v) => setState(() => _sms = v)),
              ),
            ],
          ),
        ),
        Section(
          'Filter chips',
          note: 'Narrow a list. A count says how much is behind each; a dropdown chip holds a picked value.',
          child: Examples(
            spacing: AerosSpacing.s2,
            children: [
              for (var i = 0; i < _filters.length; i++)
                AerosFilterChip(
                  label: _filters[i].$1,
                  count: _filters[i].$2,
                  selected: _filter == i,
                  tone: _filters[i].$1 == 'Overdue' ? AerosFilterChipTone.warning : AerosFilterChipTone.neutral,
                  onTap: () => setState(() => _filter = i),
                ),
              AerosFilterChip(
                label: _city ?? 'City',
                leadingIcon: Icons.place_outlined,
                dropdown: true,
                selected: _city != null,
                onClear: _city == null ? null : () => setState(() => _city = null),
                onTap: () => setState(() => _city = cities[(cities.indexOf(_city ?? cities.last) + 1) % cities.length]),
              ),
            ],
          ),
        ),
        Section(
          'Enum chips',
          note: 'One of a short list of attribute options. Tap the chosen chip to clear it.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AerosEnumChips(
                label: 'Cup size',
                required: true,
                unitSuffix: 'ml',
                options: sizeSpec.options,
                selectedId: _size,
                requiredButMissing: true,
                errorText: _size == null ? 'Choose a size' : null,
                onChanged: (id) => setState(() => _size = id),
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosEnumChips(
                label: 'Colour',
                options: const [
                  AerosAttributeOption(id: 'ink', label: 'Ink', swatchColor: 0xFF1A1917),
                  AerosAttributeOption(id: 'kraft', label: 'Kraft', swatchColor: 0xFFB08D57),
                  AerosAttributeOption(id: 'white', label: 'White', swatchColor: 0xFFFFFFFF),
                  AerosAttributeOption(
                    id: 'gold',
                    label: 'Gold foil',
                    swatchColor: 0xFFC9A227,
                    disabled: true,
                    disabledReason: 'Not offered at this size',
                  ),
                ],
                selectedId: _colour,
                onChanged: (id) => setState(() => _colour = id),
              ),
              const SizedBox(height: AerosSpacing.s5),
              AerosEnumChips(
                label: 'Coating (disabled)',
                options: coatingSpec.options,
                selectedId: 'pla',
                enabled: false,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        Section(
          'Sliders',
          note: 'A value in a continuous range; the band picks a low and a high.',
          child: Stacked(
            children: [
              AerosRangeSlider(
                label: 'Paper weight',
                unitLabel: 'gsm',
                range: _range,
                value: _gsm,
                onChanged: (v) => setState(() => _gsm = v),
              ),
              AerosNumericRangeBand(
                label: 'GSM offered',
                unitLabel: 'gsm',
                range: _range,
                values: _band,
                onChanged: (v) => setState(() => _band = v),
              ),
              AerosRangeSlider(
                label: 'Paper weight (disabled)',
                unitLabel: 'gsm',
                range: _range,
                value: 200,
                enabled: false,
                onChanged: (_) {},
              ),
              AerosNumericRangeBand(
                label: 'GSM offered (disabled)',
                range: _range,
                values: const RangeValues(180, 240),
                enabled: false,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
