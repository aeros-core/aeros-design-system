import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was green/amber/red/blue/grey/dark).
enum AerosBadgeTone { success, warning, danger, info, neutral, inverse }

/// A status label: a pill with a tinted fill, a 1px border in the tone's
/// border colour and a `labelXs` label.
///
/// It is as tall as the density's badge size ([AerosSizeTokens.badge]: 18 for
/// a mouse, 20 for fingers) — the same height as [AerosTag] and
/// `AerosCountBadge`, so they sit on one line.
class AerosBadge extends StatelessWidget {
  const AerosBadge({super.key, required this.label, this.tone = AerosBadgeTone.neutral, this.showDot = true});

  final String label;
  final AerosBadgeTone tone;
  final bool showDot;

  /// Every tone resolves from the theme — status tints have true dark
  /// counterparts via [AerosSemanticColors].
  ({Color bg, Color fg, Color border, Color dot}) _palette(AerosAliasColors a, AerosSemanticColors s) {
    return switch (tone) {
      AerosBadgeTone.success => (bg: s.successBg, fg: s.successText, border: s.successBorder, dot: s.success),
      AerosBadgeTone.warning => (bg: s.warningBg, fg: s.warningText, border: s.warningBorder, dot: s.warning),
      AerosBadgeTone.danger => (bg: s.dangerBg, fg: s.dangerText, border: s.dangerBorder, dot: s.danger),
      AerosBadgeTone.info => (bg: s.infoBg, fg: s.infoText, border: s.infoBorder, dot: s.info),
      AerosBadgeTone.neutral => (bg: a.bgSubtle, fg: a.fgSecondary, border: a.borderDefault, dot: a.fgMuted),
      AerosBadgeTone.inverse => (bg: a.bgInverse, fg: a.fgInverse, border: a.bgInverse, dot: a.fgInverse),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context.aerosColors, context.aerosSemantic);
    return Container(
      height: AerosDensity.of(context).sizes.badge,
      // The hairline is part of the box, so it comes off the padding.
      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2 - AerosMetricTokens.borderHairline),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
        border: Border.all(color: p.border, width: AerosMetricTokens.borderHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: AerosSpacing.s1_5,
              height: AerosSpacing.s1_5,
              decoration: BoxDecoration(color: p.dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AerosSpacing.s1_5),
          ],
          Text(label, maxLines: 1, softWrap: false, style: AerosTypography.labelXs(color: p.fg)),
        ],
      ),
    );
  }
}
