import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';

class AerosRadio<T> extends StatelessWidget {
  const AerosRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.compact = false,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  /// Shrinks the hit area to the 18dp glyph for dense desktop tables.
  /// The default keeps Material's padded 48dp touch target.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final radio = Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: a.brandPrimary,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      materialTapTargetSize:
          compact ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
    );
    if (!compact) return radio;
    return SizedBox(width: 18, height: 18, child: radio);
  }
}
