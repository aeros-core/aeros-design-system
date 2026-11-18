import 'package:flutter/material.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AerosDelta { up, down, flat }

/// One number with its label and, optionally, how it moved.
///
/// A flat surface (hairline, no shadow). The label is a muted caption, the
/// value is the `h1` role — or `monoLg` with [mono], for figures that should
/// line up. The delta is coloured by direction, and the direction is also
/// announced in words ("up 12.4%"), so it never depends on colour or the arrow.
class AerosStatCard extends StatelessWidget {
  const AerosStatCard({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
    this.delta,
    this.deltaDirection = AerosDelta.flat,
    this.deltaSemanticLabel,
  });

  final String label;
  final String value;
  final bool mono;
  final String? delta;
  final AerosDelta deltaDirection;

  /// What a screen reader says for the delta. Defaults to the direction in
  /// English followed by [delta] — "up +12.4%", "down -3.1%", "no change 0.0%".
  /// Pass a localised sentence here.
  final String? deltaSemanticLabel;

  /// The English word(s) announced for [direction].
  static String directionLabel(AerosDelta direction) => switch (direction) {
        AerosDelta.up => 'up',
        AerosDelta.down => 'down',
        AerosDelta.flat => 'no change',
      };

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final s = context.aerosSemantic;
    // `-text` shades: delta copy is small text and needs WCAG 4.5:1 on the
    // card surface (the base status colours only clear the 3:1 icon minimum).
    final deltaColor = switch (deltaDirection) {
      AerosDelta.up => s.successText,
      AerosDelta.down => s.dangerText,
      AerosDelta.flat => a.fgMuted,
    };
    final deltaIcon = switch (deltaDirection) {
      AerosDelta.up => Icons.arrow_upward_rounded,
      AerosDelta.down => Icons.arrow_downward_rounded,
      AerosDelta.flat => Icons.remove_rounded,
    };
    final h1 = AerosTypography.h1(color: a.fgPrimary);
    return MergeSemantics(
      child: AerosSurface(
        padding: const EdgeInsets.all(AerosSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AerosTypography.caption(color: a.fgMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AerosSpacing.s1),
            // One height for both faces (the taller, `h1`), so the line under
            // the value sits level across a row of cards, mono or not.
            SizedBox(
              height: MediaQuery.textScalerOf(context).scale(h1.fontSize!) * h1.height!,
              // Shrink-to-fit so large values / narrow cards / big text scales never
              // overflow the card horizontally.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: mono ? AerosTypography.monoLg(color: a.fgPrimary, weight: FontWeight.w500) : h1,
                ),
              ),
            ),
            if (delta != null) ...[
              const SizedBox(height: AerosSpacing.s2),
              Semantics(
                label: deltaSemanticLabel ?? '${directionLabel(deltaDirection)} ${delta!}',
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deltaIcon, size: AerosSizeTokens.iconXs, color: deltaColor),
                      const SizedBox(width: AerosSpacing.s1),
                      Text(delta!, style: AerosTypography.caption(color: deltaColor, weight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
