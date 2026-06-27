import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosAlertTone { blue, green, amber, red }

class AerosAlert extends StatelessWidget {
  const AerosAlert({super.key, required this.tone, this.title, required this.body, this.icon});

  final AerosAlertTone tone;
  final String? title;
  final String body;
  final IconData? icon;

  // Neutral "blue"/info tone resolves from the theme; green/amber/red stay
  // fixed semantics.
  ({Color bg, Color border, Color title, Color body, IconData icon}) _p(AerosAliasColors a) {
    switch (tone) {
      case AerosAlertTone.blue:
        return (bg: a.brandPrimaryMuted, border: a.borderDefault, title: a.fgPrimary, body: a.fgSecondary, icon: Icons.info_outline);
      case AerosAlertTone.green:
        return (bg: AerosColors.successBg, border: AerosColors.successBorder, title: AerosColors.successText, body: AerosColors.success, icon: Icons.check_circle_outline);
      case AerosAlertTone.amber:
        return (bg: AerosColors.warningBg, border: AerosColors.warningBorder, title: AerosColors.warningText, body: AerosColors.warning, icon: Icons.warning_amber_outlined);
      case AerosAlertTone.red:
        return (bg: AerosColors.dangerBg, border: AerosColors.dangerBorder, title: AerosColors.dangerText, body: AerosColors.danger, icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _p(context.aerosColors);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: AerosRadii.brLg,
        border: Border.all(color: p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? p.icon, size: 18, color: p.body),
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
    );
  }
}
