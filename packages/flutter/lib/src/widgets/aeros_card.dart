import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

class AerosCard extends StatelessWidget {
  const AerosCard({super.key, this.title, this.subtitle, this.header, this.footer, this.trailing, required this.child, this.padding, this.onTap, this.color});

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

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? a.bgSurface,
        borderRadius: AerosRadii.brXl,
        border: Border.all(color: a.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null || title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: a.borderDefault)),
              ),
              child: header ??
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title!, style: AerosTypography.h4(color: a.fgPrimary).copyWith(fontSize: 15)),
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
            padding: padding ?? const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: child,
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
              decoration: BoxDecoration(
                color: a.bgSubtle,
                border: Border(top: BorderSide(color: a.borderDefault)),
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
