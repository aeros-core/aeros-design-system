import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was blue/green/amber/red).
enum AerosAlertTone { info, success, warning, danger }

class AerosAlert extends StatelessWidget {
  const AerosAlert({super.key, required this.tone, this.title, required this.body, this.icon});

  final AerosAlertTone tone;
  final String? title;
  final String body;
  final IconData? icon;

  // Info resolves from the theme neutrals; status tones use the theme-aware
  // semantic sets. Body copy uses the `-text` shade (WCAG 4.5:1 on the tinted
  // bg); only the icon may use the brighter base color (3:1 non-text minimum).
  ({Color bg, Color border, Color title, Color body, Color iconColor, IconData icon}) _p(
      AerosAliasColors a, AerosSemanticColors s) {
    switch (tone) {
      case AerosAlertTone.info:
        return (bg: a.brandPrimaryMuted, border: a.borderDefault, title: a.fgPrimary, body: a.fgSecondary, iconColor: a.fgSecondary, icon: Icons.info_outline);
      case AerosAlertTone.success:
        return (bg: s.successBg, border: s.successBorder, title: s.successText, body: s.successText, iconColor: s.success, icon: Icons.check_circle_outline);
      case AerosAlertTone.warning:
        return (bg: s.warningBg, border: s.warningBorder, title: s.warningText, body: s.warningText, iconColor: s.warning, icon: Icons.warning_amber_outlined);
      case AerosAlertTone.danger:
        return (bg: s.dangerBg, border: s.dangerBorder, title: s.dangerText, body: s.dangerText, iconColor: s.danger, icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _p(context.aerosColors, context.aerosSemantic);
    return Semantics(
      // Alerts are announced politely; danger content is what screen-reader
      // users most need to hear.
      liveRegion: tone == AerosAlertTone.danger,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: AerosRadii.brLg,
          border: Border.all(color: p.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? p.icon, size: 18, color: p.iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(title!, style: AerosTypography.labelMd(color: p.title)),
                    const SizedBox(height: 3),
                  ],
                  Text(body, style: AerosTypography.caption(color: p.body)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
