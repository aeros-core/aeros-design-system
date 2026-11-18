/// How the digits of a whole number are grouped.
enum AerosDigitGrouping {
  /// No separators: `1234567`.
  none,

  /// Thousands: `1,234,567`.
  thousands,

  /// The Indian system — the last three digits, then pairs (lakh, crore):
  /// `12,34,567`.
  indian,
}

/// Formats an amount of money as text. See [AerosAmountFormat.money].
typedef AerosAmountFormatter = String Function(num amount);

/// Number formatting for amounts, with no dependency on `intl`.
///
/// The design system prints money in a few places ([AerosPriceBreakdown]);
/// this is the small formatter behind them. For anything locale-aware
/// (decimal commas, currency placement) pass your own [AerosAmountFormatter].
class AerosAmountFormat {
  AerosAmountFormat._();

  /// The grouping a currency is conventionally written with: Indian for the
  /// rupee (`₹`, `Rs`, `Rs.`, `INR`), thousands for everything else.
  static AerosDigitGrouping groupingFor(String currencySymbol) {
    final symbol = currencySymbol.trim().toLowerCase();
    const rupee = {'₹', 'rs', 'rs.', 'inr', '₨'};
    return rupee.contains(symbol) ? AerosDigitGrouping.indian : AerosDigitGrouping.thousands;
  }

  /// [value] with [fractionDigits] decimals and its whole part grouped:
  /// `group(1234567.5)` is `1,234,567.50`; with [AerosDigitGrouping.indian],
  /// `12,34,567.50`. A negative value takes a leading [minus] (a real minus
  /// sign by default); a value that rounds to zero is never negative.
  static String group(
    num value, {
    int fractionDigits = 2,
    AerosDigitGrouping grouping = AerosDigitGrouping.thousands,
    String minus = '−',
  }) {
    final fixed = value.abs().toStringAsFixed(fractionDigits);
    final negative = value < 0 && double.parse(fixed) != 0;
    final dot = fixed.indexOf('.');
    final whole = dot < 0 ? fixed : fixed.substring(0, dot);
    final fraction = dot < 0 ? '' : fixed.substring(dot);
    return '${negative ? minus : ''}${_groupWhole(whole, grouping)}$fraction';
  }

  /// [value] as money: the sign, then [currencySymbol], then the grouped
  /// number — `₹6,675.00`, `−$1,250.00`. [grouping] defaults to
  /// [groupingFor] the symbol.
  static String money(
    num value, {
    required String currencySymbol,
    int fractionDigits = 2,
    AerosDigitGrouping? grouping,
    String minus = '−',
  }) {
    final number = group(
      value,
      fractionDigits: fractionDigits,
      grouping: grouping ?? groupingFor(currencySymbol),
      minus: '',
    );
    final negative = value < 0 && double.parse(value.abs().toStringAsFixed(fractionDigits)) != 0;
    return '${negative ? minus : ''}$currencySymbol$number';
  }

  static String _groupWhole(String digits, AerosDigitGrouping grouping) {
    // Not a plain run of digits (1e+21, Infinity): leave it alone.
    if (grouping == AerosDigitGrouping.none || digits.length <= 3 || int.tryParse(digits[0]) == null) return digits;
    if (digits.contains(RegExp(r'[^0-9]'))) return digits;
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final step = grouping == AerosDigitGrouping.indian ? 2 : 3;
    final groups = <String>[];
    for (var end = head.length; end > 0; end -= step) {
      groups.insert(0, head.substring(end - step < 0 ? 0 : end - step, end));
    }
    return '${groups.join(',')},$tail';
  }
}
