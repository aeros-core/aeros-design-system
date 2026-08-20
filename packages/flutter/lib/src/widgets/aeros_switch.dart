import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';

class AerosSwitch extends StatelessWidget {
  const AerosSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Shrinks the hit area to the track for dense desktop rows.
  /// The default keeps Material's padded 48dp touch target.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: a.fgInverse,
      activeTrackColor: a.brandPrimary,
      inactiveThumbColor: a.fgMuted,
      inactiveTrackColor: a.bgSubtle,
      trackOutlineColor: WidgetStateProperty.resolveWith((_) => a.borderStrong),
      materialTapTargetSize:
          compact ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
    );
  }
}
