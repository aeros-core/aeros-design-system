import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// What a list or a page shows when it has nothing to show.
///
/// A 1px dashed outline (`borderStrong`, [AerosShapeTokens.surface] corners)
/// with no fill and no shadow: an empty slot, not a card. The [title] is a
/// heading for assistive technology.
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
    return CustomPaint(
      painter: _DashedOutlinePainter(color: a.borderStrong),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s6, vertical: AerosSpacing.s10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: AerosSizeTokens.avatarLg,
                height: AerosSizeTokens.avatarLg,
                decoration: BoxDecoration(
                  color: a.bgSubtle,
                  borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.control)),
                  border: Border.all(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
                ),
                child: Icon(icon, size: AerosSizeTokens.iconLg, color: a.fgMuted),
              ),
              const SizedBox(height: AerosSpacing.s3),
            ],
            Semantics(
              header: true,
              child: Text(title, textAlign: TextAlign.center, style: AerosTypography.h4(color: a.fgPrimary)),
            ),
            if (description != null) ...[
              const SizedBox(height: AerosSpacing.s1),
              ConstrainedBox(
                // No measure token yet: the mobile-sidebar width is the nearest (280).
                constraints: const BoxConstraints(maxWidth: AerosMetricTokens.layoutSidebarMobile),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AerosTypography.bodySm(color: a.fgMuted),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AerosSpacing.s4),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A hairline rounded rectangle drawn in dashes ([AerosSpacing.s1] on,
/// [AerosSpacing.s1] off), inset by half its width so it stays inside the box.
class _DashedOutlinePainter extends CustomPainter {
  const _DashedOutlinePainter({required this.color});

  final Color color;

  static const double _width = AerosMetricTokens.borderHairline;
  static const double _dash = AerosSpacing.s1;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_width / 2);
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(AerosShapeTokens.surface)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _width
      ..color = color;
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash * 2) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutlinePainter old) => old.color != color;
}
