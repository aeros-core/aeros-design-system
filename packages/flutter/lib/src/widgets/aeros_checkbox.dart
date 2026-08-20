import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';

class AerosCheckbox extends StatelessWidget {
  const AerosCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.compact = false,
  });

  final bool? value;
  final ValueChanged<bool?> onChanged;
  final bool tristate;

  /// Shrinks the hit area to the 18dp glyph for dense desktop tables.
  /// The default keeps Material's padded 48dp touch target — only opt into
  /// compact where rows are keyboard/mouse-first.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final checkbox = Checkbox(
      value: value,
      tristate: tristate,
      onChanged: onChanged,
      activeColor: a.brandPrimary,
      checkColor: a.fgInverse,
      side: BorderSide(color: a.borderStrong, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      materialTapTargetSize:
          compact ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
    );
    if (!compact) return checkbox;
    return SizedBox(width: 18, height: 18, child: checkbox);
  }
}
