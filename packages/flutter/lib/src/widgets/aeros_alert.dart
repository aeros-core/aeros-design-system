import 'package:flutter/material.dart';
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

  ({Color bg, Color border, Color title, Color body, IconData icon}) _p() {
    switch (tone) {
      case AerosAlertTone.blue:
        return (bg: AerosColors.royal50, border: AerosColors.royal100, title: AerosColors.royal800, body: AerosColors.royal600, icon: Icons.info_outline);
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
    final p = _p();
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
                  Text(title!, style: AerosTypography.bodySm(color: p.title).copyWith(fontWeight: FontWeight.w700)),
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
