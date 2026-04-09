import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class AerosRadio<T> extends StatelessWidget {
  const AerosRadio({super.key, required this.value, required this.groupValue, required this.onChanged});

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18, height: 18,
      child: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AerosColors.royal600,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
