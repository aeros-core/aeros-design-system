import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class AerosSwitch extends StatelessWidget {
  const AerosSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AerosColors.royal600,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AerosColors.ink200,
      trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
