import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _units = [
  AerosMeasurementUnit(code: 'mm', label: 'mm'),
  AerosMeasurementUnit(code: 'cm', label: 'cm'),
  AerosMeasurementUnit(code: 'in', label: 'in'),
];

const _options = [
  AerosAttributeOption(id: 'kraft', label: 'Kraft'),
  AerosAttributeOption(id: 'white', label: 'White board'),
  AerosAttributeOption(id: 'pe', label: 'PE coated', disabled: true, disabledReason: 'Not for this size'),
];

const _cities = ['Ahmedabad', 'Bengaluru', 'Chennai', 'Delhi', 'Mumbai', 'Pune'];

TextEditingController _text(String value) => TextEditingController(text: value);

void main() {
  goldenMatrix(
    'fields_text',
    size: const Size(760, 720),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 340,
          children: [
            for (final size in AerosFieldSize.values)
              GoldenSection(
                'size ${size.name}',
                child: AerosTextField(label: 'Company name', hint: 'Acme Packaging', size: size),
              ),
            GoldenSection(
              'filled',
              child: AerosTextField(label: 'Company name', controller: _text('Boson Machines')),
            ),
            const GoldenSection(
              'helper text',
              child: AerosTextField(
                label: 'GSTIN',
                hint: '22AAAAA0000A1Z5',
                helperText: '15 characters, as on your certificate',
                required: true,
              ),
            ),
            GoldenSection(
              'error',
              child: AerosTextField(
                label: 'Email',
                controller: _text('parth@'),
                errorText: 'Enter a valid email address',
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'disabled',
              child: AerosTextField(label: 'Account ID', controller: _text('ACC-000412'), enabled: false),
            ),
            const GoldenSection(
              'disabled, empty',
              child: AerosTextField(label: 'Account ID', hint: 'Assigned on approval', enabled: false),
            ),
            const GoldenSection(
              'prefix and suffix',
              child: AerosTextField(
                label: 'Unit price',
                hint: '0.00',
                prefix: Icon(Icons.currency_rupee, size: 16),
                suffix: Icon(Icons.info_outline, size: 16),
              ),
            ),
            GoldenSection(
              'obscured',
              child: AerosTextField(label: 'Password', controller: _text('correct horse'), obscureText: true),
            ),
            GoldenSection(
              'multi-line',
              child: AerosTextField(
                label: 'Notes',
                controller: _text('Deliver to dock 3.\nCall before arrival.'),
                minLines: 3,
                maxLines: 5,
              ),
            ),
            const GoldenSection(
              'no label',
              child: AerosTextField(hint: 'Type a reply'),
            ),
          ],
        ),
      ],
    ),
  );

  // Hover and keyboard focus on a text field.
  Widget textFieldPair(BuildContext context) => const GoldenColumn(
        width: 320,
        children: [
          AerosTextField(key: Key('target'), label: 'Target', hint: 'Hint'),
          SizedBox(height: 16),
          AerosTextField(label: 'Resting', hint: 'Hint'),
        ],
      );
  goldenMatrix(
    'fields_text_hovered',
    textFieldPair,
    size: const Size(360, 200),
    act: (t) => hover(t, find.byKey(const Key('target'))),
  );
  goldenMatrix(
    'fields_text_focused',
    textFieldPair,
    size: const Size(360, 200),
    act: (t) => focus(t, find.byKey(const Key('target'))),
  );
  goldenMatrix(
    'fields_text_error_focused',
    (context) => GoldenColumn(
      width: 320,
      children: [
        AerosTextField(
          key: const Key('target'),
          label: 'Email',
          controller: _text('parth@'),
          errorText: 'Enter a valid email address',
        ),
      ],
    ),
    size: const Size(360, 130),
    act: (t) => focus(t, find.byKey(const Key('target'))),
  );

  goldenMatrix(
    'fields_search_tag_form',
    size: const Size(760, 720),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 340,
          children: [
            for (final size in AerosFieldSize.values)
              GoldenSection('AerosSearchField ${size.name}', child: AerosSearchField(hint: 'Search orders', size: size)),
            GoldenSection(
              'AerosSearchField with a query',
              child: AerosSearchField(controller: _text('paper cup 250 ml')),
            ),
            const GoldenSection('AerosSearchField disabled', child: AerosSearchField(enabled: false)),
            GoldenSection(
              'AerosFormField',
              child: AerosFormField(
                label: 'Delivery window',
                helperText: 'We deliver Monday to Saturday',
                required: true,
                trailing: Text('Optional', style: AerosTypography.caption(color: context.aerosColors.fgMuted)),
                child: const AerosTextField(hint: '10:00 to 18:00'),
              ),
            ),
            const GoldenSection(
              'AerosFormField error',
              child: AerosFormField(
                label: 'Delivery window',
                helperText: 'Hidden while the error shows',
                errorText: 'Pick a window inside business hours',
                child: AerosTextField(hint: '10:00 to 18:00'),
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosTagField',
              child: AerosTagField(label: 'Tags', tags: const ['kraft', 'food-grade', 'export'], onChanged: (_) {}),
            ),
            GoldenSection(
              'AerosTagField empty',
              child: AerosTagField(label: 'Tags', tags: const [], onChanged: (_) {}),
            ),
            for (final size in [AerosFieldSize.sm, AerosFieldSize.lg])
              GoldenSection(
                'AerosTagField ${size.name}',
                child: AerosTagField(tags: const ['kraft', 'export'], onChanged: (_) {}, size: size, prefixSymbol: ''),
              ),
            GoldenSection(
              'AerosTagField disabled',
              child: AerosTagField(label: 'Tags', tags: const ['kraft', 'export'], onChanged: (_) {}, enabled: false),
            ),
          ],
        ),
      ],
    ),
  );

  goldenMatrix(
    'fields_search_focused',
    (context) => SizedBox(
      width: 320,
      child: AerosSearchField(key: const Key('target'), controller: _text('paper cup')),
    ),
    size: const Size(360, 90),
    act: (t) => focus(t, find.byKey(const Key('target'))),
  );

  goldenMatrix(
    'fields_pickers',
    size: const Size(760, 810),
    (context) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosMeasurementInput',
              child: AerosMeasurementInput(
                label: 'Height',
                units: _units,
                numericValue: 120,
                unitCode: 'mm',
                onChanged: (_, __) {},
                helperText: 'Outer height of the cup',
                required: true,
                range: const AerosNumericRange(min: 40, max: 200),
              ),
            ),
            GoldenSection(
              'AerosMeasurementInput empty',
              child: AerosMeasurementInput(
                label: 'Height',
                hint: '0',
                units: _units,
                numericValue: null,
                unitCode: null,
                onChanged: (_, __) {},
              ),
            ),
            GoldenSection(
              'AerosMeasurementInput error',
              child: AerosMeasurementInput(
                label: 'Height',
                units: _units,
                numericValue: 260,
                unitCode: 'mm',
                onChanged: (_, __) {},
                errorText: 'Must be 200 mm or less',
              ),
            ),
            GoldenSection(
              'AerosMeasurementInput disabled',
              child: AerosMeasurementInput(
                label: 'Height',
                units: _units,
                numericValue: 12,
                unitCode: 'cm',
                onChanged: (_, __) {},
                enabled: false,
              ),
            ),
            GoldenSection(
              'AerosEnumDropdown',
              child: AerosEnumDropdown(label: 'Material', options: _options, selectedId: null, onChanged: (_) {}),
            ),
            GoldenSection(
              'AerosEnumDropdown selected',
              child: AerosEnumDropdown(
                label: 'Material',
                options: _options,
                selectedId: 'white',
                onChanged: (_) {},
                required: true,
              ),
            ),
          ],
        ),
        const SizedBox(width: 32),
        GoldenColumn(
          width: 340,
          children: [
            GoldenSection(
              'AerosEnumDropdown error',
              child: AerosEnumDropdown(
                label: 'Material',
                options: _options,
                selectedId: null,
                onChanged: (_) {},
                errorText: 'Choose a material',
              ),
            ),
            GoldenSection(
              'AerosEnumDropdown disabled',
              child: AerosEnumDropdown(
                label: 'Material',
                options: _options,
                selectedId: 'kraft',
                onChanged: (_) {},
                enabled: false,
              ),
            ),
            GoldenSection(
              'AerosDropdownSearch',
              child: AerosDropdownSearch<String>(
                label: 'City',
                hint: 'Select a city',
                items: _cities,
                itemAsString: (s) => s,
                onChanged: (_) {},
              ),
            ),
            GoldenSection(
              'AerosDropdownSearch selected, clearable',
              child: AerosDropdownSearch<String>(
                label: 'City',
                items: _cities,
                selectedItem: 'Mumbai',
                itemAsString: (s) => s,
                onChanged: (_) {},
                showClearButton: true,
                required: true,
              ),
            ),
            GoldenSection(
              'AerosDropdownSearch disabled',
              child: AerosDropdownSearch<String>(
                label: 'City',
                items: _cities,
                selectedItem: 'Pune',
                itemAsString: (s) => s,
                enabled: false,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
