import 'package:aeros_design_system/aeros_design_system.dart';

/// Deterministic sample data shared by the gallery pages. No network.

class Order {
  const Order(this.id, this.buyer, this.city, this.status, this.units, this.total);

  final String id;
  final String buyer;
  final String city;
  final OrderStatus status;
  final int units;
  final int total;

  String get totalLabel => rupees(total);
  String get unitsLabel => grouped(units);
}

enum OrderStatus {
  paid('Paid', AerosBadgeTone.success),
  pending('Pending', AerosBadgeTone.warning),
  overdue('Overdue', AerosBadgeTone.danger),
  draft('Draft', AerosBadgeTone.neutral);

  const OrderStatus(this.label, this.tone);

  final String label;
  final AerosBadgeTone tone;
}

const orders = <Order>[
  Order('#4821', 'Boson Machines', 'Ahmedabad', OrderStatus.paid, 12000, 48200),
  Order('#4820', 'Lorven Foods', 'Pune', OrderStatus.pending, 3000, 12750),
  Order('#4819', 'Kiran Traders', 'Surat', OrderStatus.overdue, 1500, 6400),
  Order('#4818', 'Shree Packaging', 'Mumbai', OrderStatus.draft, 24000, 91000),
  Order('#4817', 'Nilgiri Tea Co.', 'Coimbatore', OrderStatus.paid, 8000, 33600),
  Order('#4816', 'Urban Brew', 'Bengaluru', OrderStatus.paid, 5000, 21500),
  Order('#4815', 'Sagar Sweets', 'Rajkot', OrderStatus.pending, 2000, 8900),
  Order('#4814', 'Metro Canteens', 'Delhi', OrderStatus.overdue, 10000, 41000),
  Order('#4813', 'Kaveri Dairy', 'Mysuru', OrderStatus.paid, 6000, 25200),
  Order('#4812', 'Blue Lotus Cafe', 'Kochi', OrderStatus.draft, 1000, 4600),
  Order('#4811', 'Annapurna Foods', 'Indore', OrderStatus.paid, 16000, 64800),
  Order('#4810', 'Zenith Hotels', 'Jaipur', OrderStatus.pending, 9000, 37400),
];

const cities = ['Ahmedabad', 'Bengaluru', 'Chennai', 'Delhi', 'Hyderabad', 'Kolkata', 'Mumbai', 'Pune'];

/// 48200 → "₹ 48,200".
String rupees(num amount) => '₹ ${grouped(amount.round())}';

/// 12000 → "12,000".
String grouped(int value) {
  final digits = value.abs().toString();
  final out = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

const variants = [
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

const materialSpec = AerosAttributeSpec(
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

const sizeSpec = AerosAttributeSpec(
  key: 'cup_size',
  label: 'Cup size',
  datatype: AerosAttributeDatatype.measurement,
  optionSource: AerosAttributeOptionSource.enumOptions,
  required: true,
  defaultUnit: 'ml',
  options: [
    AerosAttributeOption(id: '150', label: '150'),
    AerosAttributeOption(id: '250', label: '250'),
    AerosAttributeOption(id: '350', label: '350'),
    AerosAttributeOption(id: '450', label: '450'),
  ],
);

const gsmSpec = AerosAttributeSpec(
  key: 'gsm',
  label: 'Paper weight',
  datatype: AerosAttributeDatatype.measurement,
  optionSource: AerosAttributeOptionSource.range,
  range: AerosNumericRange(min: 150, max: 350, step: 10),
  units: [AerosMeasurementUnit(code: 'gsm', label: 'gsm')],
  defaultUnit: 'gsm',
);

const lidSpec = AerosAttributeSpec(
  key: 'lid',
  label: 'Include lid',
  datatype: AerosAttributeDatatype.boolean,
  optionSource: AerosAttributeOptionSource.enumOptions,
  helperText: 'Adds a matching sip lid',
);

const artworkSpec = AerosAttributeSpec(
  key: 'artwork',
  label: 'Artwork',
  datatype: AerosAttributeDatatype.enumValue,
  optionSource: AerosAttributeOptionSource.file,
);

const coatingSpec = AerosAttributeSpec(
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

const finishSpec = AerosAttributeSpec(
  key: 'finish',
  label: 'Print finish',
  datatype: AerosAttributeDatatype.enumValue,
  optionSource: AerosAttributeOptionSource.enumOptions,
  options: [
    AerosAttributeOption(id: 'none', label: 'Unprinted'),
    AerosAttributeOption(id: '1c', label: 'One colour'),
    AerosAttributeOption(id: '2c', label: 'Two colour'),
    AerosAttributeOption(id: '4c', label: 'Full colour (CMYK)'),
    AerosAttributeOption(id: 'matte', label: 'Matte lamination'),
    AerosAttributeOption(id: 'gloss', label: 'Gloss lamination'),
    AerosAttributeOption(id: 'foil', label: 'Foil stamp', disabled: true, disabledReason: 'Above 5,000 units'),
  ],
);

const artworkFile = AerosFileRef(
  id: 'f1',
  name: 'cup-artwork-v3.pdf',
  sizeBytes: 2411724,
  mimeType: 'application/pdf',
);

const units = [
  AerosMeasurementUnit(code: 'mm', label: 'mm'),
  AerosMeasurementUnit(code: 'in', label: 'in'),
];

/// The price of [quantity] cups at [gsm], with or without a print plate.
AerosPriceBreakdownData priceFor({required int quantity, required num gsm, required bool printed}) {
  const base = 4.5;
  final board = gsm > 200 ? 2.0 : 0.0;
  final plate = printed ? 500 : 0;
  final discountable = (base + board) * quantity;
  final discount = quantity >= 1000 ? -(discountable * 0.05).round() : 0;
  return AerosPriceBreakdownData(
    currencySymbol: '₹',
    quantity: quantity,
    discountableSubtotal: discountable,
    nonDiscountableSubtotal: plate,
    total: discountable + plate + discount,
    steps: [
      const AerosBreakdownStep(name: 'Base price', kind: 'BASE_PRICE', amount: base, perUnit: true),
      if (board > 0)
        AerosBreakdownStep(
          name: 'GSM ${gsm.round()}',
          kind: 'MODIFIER',
          modifierKey: 'gsm_heavy',
          modifierVersion: 3,
          amount: board,
          perUnit: true,
          note: 'Heavier board',
        ),
      if (printed) AerosBreakdownStep(name: 'Printing plate', kind: 'SETUP', amount: plate, discountable: false),
      if (discount != 0) AerosBreakdownStep(name: 'Volume discount 5%', kind: 'DISCOUNT', amount: discount),
    ],
  );
}
