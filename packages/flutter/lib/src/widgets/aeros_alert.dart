import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was blue/green/amber/red).
enum AerosAlertTone { info, success, warning, danger }

/// An inline message: a tinted fill with a 1px border in the tone's border
/// colour, [AerosShapeTokens.surface] corners and no shadow. The title is
/// `labelSm`, the body `bodySm`.
class AerosAlert extends StatelessWidget {
  const AerosAlert({super.key, required this.tone, this.title, required this.body, this.icon});

  final AerosAlertTone tone;
  final String? title;
  final String body;
  final IconData? icon;

  // Every tone resolves from the theme-aware status sets (info is the neutral
  // grey set). Copy uses the `-text` shade (WCAG 4.5:1 on the tinted fill);
  // only the icon may use the brighter base colour (3:1 non-text minimum).
  ({Color bg, Color border, Color text, Color iconColor, IconData icon}) _p(AerosSemanticColors s) {
    return switch (tone) {
      AerosAlertTone.info => (
          bg: s.infoBg,
          border: s.infoBorder,
          text: s.infoText,
          iconColor: s.info,
          icon: Icons.info_outline,
        ),
      AerosAlertTone.success => (
          bg: s.successBg,
          border: s.successBorder,
          text: s.successText,
          iconColor: s.success,
          icon: Icons.check_circle_outline,
        ),
      AerosAlertTone.warning => (
          bg: s.warningBg,
          border: s.warningBorder,
          text: s.warningText,
          iconColor: s.warning,
          icon: Icons.warning_amber_outlined,
        ),
      AerosAlertTone.danger => (
          bg: s.dangerBg,
          border: s.dangerBorder,
          text: s.dangerText,
          iconColor: s.danger,
          icon: Icons.error_outline,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = _p(context.aerosSemantic);
    final titleStyle = AerosTypography.labelSm(color: p.text);
    final firstLine = title != null ? titleStyle : AerosTypography.bodySm();
    return Semantics(
      // Alerts are announced politely; danger content is what screen-reader
      // users most need to hear.
      liveRegion: tone == AerosAlertTone.danger,
      child: Container(
        padding: const EdgeInsets.all(AerosSpacing.s3 - AerosMetricTokens.borderHairline),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.surface)),
          border: Border.all(color: p.border, width: AerosMetricTokens.borderHairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // As tall as the first line of text, so the icon sits on it.
            SizedBox(
              height: firstLine.fontSize! * firstLine.height!,
              child: Icon(icon ?? p.icon, size: AerosSizeTokens.iconMd, color: p.iconColor),
            ),
            const SizedBox(width: AerosSpacing.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(title!, style: titleStyle),
                    const SizedBox(height: AerosSpacing.s0_5),
                  ],
                  Text(body, style: AerosTypography.bodySm(color: p.text)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
