import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was green/amber/red/blue/grey/dark).
enum AerosBadgeTone { success, warning, danger, info, neutral, inverse }

class AerosBadge extends StatelessWidget {
  const AerosBadge({super.key, required this.label, this.tone = AerosBadgeTone.neutral, this.showDot = true});

  final String label;
  final AerosBadgeTone tone;
  final bool showDot;

  /// Every tone resolves from the theme — status tints have true dark
  /// counterparts via [AerosSemanticColors].
  ({Color bg, Color fg, Color dot}) _palette(AerosAliasColors a, AerosSemanticColors s) {
    switch (tone) {
      case AerosBadgeTone.success: return (bg: s.successBg, fg: s.successText, dot: s.success);
      case AerosBadgeTone.warning: return (bg: s.warningBg, fg: s.warningText, dot: s.warning);
      case AerosBadgeTone.danger:  return (bg: s.dangerBg,  fg: s.dangerText,  dot: s.danger);
      case AerosBadgeTone.info:    return (bg: a.brandPrimaryMuted, fg: a.fgPrimary, dot: a.fgSecondary);
      case AerosBadgeTone.neutral: return (bg: a.bgSubtle,  fg: a.fgSecondary, dot: a.fgMuted);
      case AerosBadgeTone.inverse: return (bg: a.brandPrimary, fg: a.fgInverse, dot: a.fgInverse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context.aerosColors, context.aerosSemantic);
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
          Text(label, style: AerosTypography.labelXs(color: p.fg)),
        ],
      ),
    );
  }
}
