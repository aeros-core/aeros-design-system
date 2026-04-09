import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';

class AerosCheckbox extends StatelessWidget {
  const AerosCheckbox({super.key, required this.value, required this.onChanged, this.tristate = false});

  final bool? value;
  final ValueChanged<bool?> onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return SizedBox(
      width: 18, height: 18,
      child: Checkbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
        activeColor: AerosColors.royal600,
        checkColor: Colors.white,
        side: BorderSide(color: a.borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
