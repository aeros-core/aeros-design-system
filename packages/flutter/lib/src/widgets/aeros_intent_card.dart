import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

/// Large tappable choice card used in onboarding intent screens
/// ("buying for myself" / "buying for my business").
class AerosIntentCard extends StatelessWidget {
  const AerosIntentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.badge,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final borderColor = selected ? a.fgPrimary : a.borderDefault;
    final borderWidth = selected ? 2.0 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AerosRadii.brXl,
        child: Container(
          decoration: BoxDecoration(
            color: a.bgSurface,
            borderRadius: AerosRadii.brXl,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: a.bgSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 22, color: a.fgPrimary),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title, style: AerosTypography.h4(color: a.fgPrimary).copyWith(fontSize: 16)),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: a.bgSubtle,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge!,
                              style: AerosTypography.caption(color: a.fgSecondary).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: AerosTypography.body(color: a.fgSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: a.fgMuted),
            ],
          ),
        ),
      ),
    );
  }
}
