import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/shadows.dart';
import '../tokens/typography.dart';

enum AerosDelta { up, down, flat }

class AerosStatCard extends StatelessWidget {
  const AerosStatCard({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
    this.delta,
    this.deltaDirection = AerosDelta.flat,
  });

  final String label;
  final String value;
  final bool mono;
  final String? delta;
  final AerosDelta deltaDirection;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final deltaColor = switch (deltaDirection) {
      AerosDelta.up => AerosColors.success,
      AerosDelta.down => AerosColors.danger,
      AerosDelta.flat => a.fgMuted,
    };
    final deltaIcon = switch (deltaDirection) {
      AerosDelta.up => Icons.arrow_upward_rounded,
      AerosDelta.down => Icons.arrow_downward_rounded,
      AerosDelta.flat => Icons.remove_rounded,
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: a.bgSurface,
        borderRadius: AerosRadii.brXl,
        border: Border.all(color: a.borderDefault),
        boxShadow: AerosShadows.card(context.aeros.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AerosTypography.overline(color: a.fgMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Shrink-to-fit so large values / narrow cards / big text scales never
          // overflow the card horizontally.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: mono
                  ? AerosTypography.monoLg(color: a.fgPrimary).copyWith(fontSize: 26, fontWeight: FontWeight.w500)
                  : AerosTypography.h1(color: a.fgPrimary),
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(deltaIcon, size: 12, color: deltaColor),
                const SizedBox(width: 4),
                Text(delta!, style: AerosTypography.caption(color: deltaColor).copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
