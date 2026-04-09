import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

class AerosEmptyState extends StatelessWidget {
  const AerosEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData? icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
      decoration: BoxDecoration(
        borderRadius: AerosRadii.brXl,
        border: Border.all(color: a.borderStrong, width: 1.5, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: a.bgSubtle,
                borderRadius: AerosRadii.brLg,
                border: Border.all(color: a.borderDefault),
              ),
              child: Icon(icon, size: 22, color: a.fgMuted),
            ),
            const SizedBox(height: 16),
          ],
          Text(title, textAlign: TextAlign.center, style: AerosTypography.h4(color: a.fgSecondary).copyWith(fontSize: 15)),
          if (description != null) ...[
            const SizedBox(height: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: AerosTypography.bodySm(color: a.fgMuted),
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 18),
            action!,
          ],
        ],
      ),
    );
  }
}
