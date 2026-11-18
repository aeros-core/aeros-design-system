import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../sample_data.dart';
import '../widgets/gallery_page.dart';

class FieldsPage extends StatefulWidget {
  const FieldsPage({super.key});

  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  final _name = TextEditingController(text: 'Boson Machines');
  final _search = TextEditingController();
  List<String> _tags = ['wholesale', 'priority'];
  String? _payment = 'net30';
  String? _finish;
  String? _city = 'Delhi';
  String? _warehouse;
  num? _height = 120;
  String? _unit = 'mm';
  bool _terms = false;

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  /// A stand-in for a server search: filters the list after a short wait.
  Future<List<String>> _findWarehouse(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final all = [for (var i = 1; i <= 40; i++) 'Warehouse $i'];
    return all.where((w) => w.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = orders.where((o) => o.buyer.toLowerCase().contains(_search.text.toLowerCase())).length;
    return GalleryPage(
      title: 'Fields',
      summary: 'One frame for every input: a hairline that stays 1px, and the focus ring.',
      children: [
        Section(
          'Text field',
          note: 'Label above, helper or error below. Error replaces the helper.',
          child: Stacked(
            children: [
              AerosTextField(label: 'Company name', required: true, controller: _name),
              const AerosTextField(
                label: 'GSTIN',
                hint: '24ABCDE1234F1Z5',
                helperText: '15 characters, as on your certificate',
                textCapitalization: TextCapitalization.characters,
              ),
              const AerosTextField(
                label: 'Email',
                hint: 'you@company.com',
                prefix: Icon(Icons.mail_outline),
                errorText: 'Enter a valid email address',
              ),
              const AerosTextField(label: 'Password', obscureText: true, suffix: Icon(Icons.visibility_outlined)),
              const AerosTextField(label: 'Delivery notes', hint: 'Gate number, timings…', minLines: 3, maxLines: 5),
              const AerosTextField(label: 'Customer ID', hint: 'Assigned on approval', enabled: false),
            ],
          ),
        ),
        Section(
          'Search field',
          note: 'Clears itself; pair it with the list it filters.',
          child: Stacked(
            spacing: AerosSpacing.s2,
            children: [
              AerosSearchField(
                controller: _search,
                hint: 'Search buyers',
                onChanged: (_) => setState(() {}),
                onClear: () => setState(() {}),
              ),
              Text(
                '$results of ${orders.length} buyers match',
                style: AerosTypography.caption(color: context.aerosColors.fgMuted),
              ),
            ],
          ),
        ),
        Section(
          'Tag field',
          note: 'Enter or comma adds a tag; backspace on an empty input removes the last.',
          child: Stacked(
            children: [
              AerosTagField(label: 'Labels', tags: _tags, onChanged: (tags) => setState(() => _tags = tags)),
            ],
          ),
        ),
        Section(
          'Select',
          note: 'A short, fixed list. Opens a menu of the options under the field.',
          child: Stacked(
            children: [
              AerosSelect<String>(
                label: 'Payment terms',
                helper: 'Applies to every order from this buyer',
                value: _payment,
                onChanged: (value) => setState(() => _payment = value),
                items: const [
                  AerosSelectItem(value: 'advance', label: 'Advance', leading: Icon(Icons.bolt)),
                  AerosSelectItem(value: 'net15', label: 'Net 15', leading: Icon(Icons.schedule)),
                  AerosSelectItem(value: 'net30', label: 'Net 30', leading: Icon(Icons.schedule)),
                  AerosSelectItem(
                    value: 'net60',
                    label: 'Net 60',
                    leading: Icon(Icons.schedule),
                    enabled: false,
                    detail: 'Needs credit approval',
                  ),
                ],
              ),
              AerosSelect<String>(
                label: 'Currency',
                placeholder: 'Select…',
                error: 'Choose a currency',
                required: true,
                value: null,
                onChanged: (_) {},
                items: const [
                  AerosSelectItem(value: 'inr', label: 'INR — Indian rupee'),
                  AerosSelectItem(value: 'usd', label: 'USD — US dollar'),
                ],
              ),
            ],
          ),
        ),
        Section(
          'Enum dropdown',
          note: 'The select, fed straight from an attribute\'s options.',
          child: Stacked(
            children: [
              AerosEnumDropdown(
                label: finishSpec.label,
                options: finishSpec.options,
                selectedId: _finish,
                onChanged: (id) => setState(() => _finish = id),
              ),
            ],
          ),
        ),
        Section(
          'Search dropdown',
          note: 'A long or remote list. Presents as a dialog, a bottom sheet or a menu.',
          child: Stacked(
            children: [
              AerosDropdownSearch<String>(
                label: 'City (dialog)',
                hint: 'Select a city',
                popupTitle: 'Choose a city',
                items: cities,
                selectedItem: _city,
                itemAsString: (city) => city,
                showClearButton: true,
                onChanged: (city) => setState(() => _city = city),
              ),
              AerosDropdownSearch<String>(
                label: 'City (sheet)',
                hint: 'Select a city',
                popupTitle: 'Choose a city',
                items: cities,
                selectedItem: _city,
                itemAsString: (city) => city,
                mode: AerosDropdownMode.sheet,
                onChanged: (city) => setState(() => _city = city),
              ),
              AerosDropdownSearch<String>(
                label: 'Warehouse (menu, async)',
                hint: 'Search 40 warehouses',
                onFind: _findWarehouse,
                selectedItem: _warehouse,
                itemAsString: (warehouse) => warehouse,
                mode: AerosDropdownMode.menu,
                required: true,
                onChanged: (warehouse) => setState(() => _warehouse = warehouse),
              ),
            ],
          ),
        ),
        Section(
          'Measurement input',
          note: 'A number and its unit in one frame, with the allowed range under it.',
          child: Stacked(
            children: [
              AerosMeasurementInput(
                label: 'Cup height',
                units: units,
                range: const AerosNumericRange(min: 40, max: 200),
                numericValue: _height,
                unitCode: _unit,
                onChanged: (value, unit) => setState(() {
                  _height = value;
                  _unit = unit;
                }),
              ),
            ],
          ),
        ),
        Section(
          'Form field',
          note: 'Label, helper and error for a control that has none of its own.',
          child: Stacked(
            children: [
              AerosFormField(
                label: 'Terms of supply',
                required: true,
                helperText: 'You can review them again before paying',
                errorText: _terms ? null : 'Accept the terms to continue',
                trailing: const AerosBadge(label: 'v4', showDot: false),
                child: LabelledControl(
                  'I accept the terms of supply',
                  control: AerosCheckbox(value: _terms, onChanged: (value) => setState(() => _terms = value ?? false)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
