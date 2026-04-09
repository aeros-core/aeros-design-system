import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AerosBadgeTone { green, amber, red, blue, grey, dark }

class AerosBadge extends StatelessWidget {
  const AerosBadge({super.key, required this.label, this.tone = AerosBadgeTone.grey, this.showDot = true});

  final String label;
  final AerosBadgeTone tone;
  final bool showDot;

  ({Color bg, Color fg, Color dot}) _palette() {
    switch (tone) {
      case AerosBadgeTone.green: return (bg: AerosColors.successBg, fg: AerosColors.successText, dot: AerosColors.success);
      case AerosBadgeTone.amber: return (bg: AerosColors.warningBg, fg: AerosColors.warningText, dot: AerosColors.warning);
      case AerosBadgeTone.red:   return (bg: AerosColors.dangerBg,  fg: AerosColors.dangerText,  dot: AerosColors.danger);
      case AerosBadgeTone.blue:  return (bg: AerosColors.royal50,   fg: AerosColors.royal800,    dot: AerosColors.royal600);
      case AerosBadgeTone.grey:  return (bg: AerosColors.ink50,     fg: AerosColors.ink600,      dot: AerosColors.ink400);
      case AerosBadgeTone.dark:  return (bg: AerosColors.slate900,  fg: AerosColors.slate200,    dot: AerosColors.slate400);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(width: 5, height: 5, decoration: BoxDecoration(color: p.dot, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label, style: AerosTypography.caption(color: p.fg).copyWith(fontSize: 11, fontWeight: FontWeight.w600, height: 1)),
        ],
      ),
    );
  }
}
