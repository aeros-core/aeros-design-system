import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/shadows.dart';
import '../tokens/typography.dart';

/// How the card separates from the canvas.
/// - [flat]: hairline border only (default — lists, dense grids).
/// - [raised]: border + soft shadow in light, lighter fill carries it in dark
///   (dashboard stat cards, anything floating over the canvas).
enum AerosCardVariant { flat, raised }

class AerosCard extends StatelessWidget {
  const AerosCard({
    super.key,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.trailing,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.variant = AerosCardVariant.flat,
  });

  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? padding;

  /// When set, the whole card becomes tappable with a ripple.
  final VoidCallback? onTap;

  /// Surface colour override (defaults to the theme surface).
  final Color? color;

  /// Elevation treatment — see [AerosCardVariant].
  final AerosCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final isDark = context.aeros.isDark;
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? a.bgSurface,
        borderRadius: AerosRadii.brXl,
        border: Border.all(color: a.borderDefault),
        boxShadow: variant == AerosCardVariant.raised ? AerosShadows.card(isDark) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null || title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: a.borderSubtle)),
              ),
              child: header ??
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title!, style: AerosTypography.h4(color: a.fgPrimary)),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(subtitle!, style: AerosTypography.caption(color: a.fgMuted)),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: child,
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: a.bgSubtle,
                border: Border(top: BorderSide(color: a.borderSubtle)),
              ),
              child: footer,
            ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AerosRadii.brXl,
        onTap: onTap,
        child: card,
      ),
    );
  }
}
