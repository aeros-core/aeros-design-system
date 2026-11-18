import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A count that something is waiting — unread messages, pending items.
///
/// A filled pill, at least as wide as it is tall and never wider than its
/// number needs: [AerosSizeTokens.badge] high — 18px at [AerosDensity.pointer],
/// 20px at [AerosDensity.touch] (from the nearest [AerosDensityScope] unless
/// [density] is given). Counts above 99 read "99+". Set [floor] when the number
/// is a lower bound (more exist than were counted), and it reads "6+". Set
/// [muted] when the source is muted: the count still shows, it just stops
/// shouting (the WhatsApp grey badge).
class AerosCountBadge extends StatelessWidget {
  const AerosCountBadge({
    super.key,
    required this.count,
    this.floor = false,
    this.muted = false,
    this.density,
    this.semanticsLabel,
  });

  final int count;

  /// The count is a lower bound: render "N+".
  final bool floor;

  /// Grey instead of the brand fill.
  final bool muted;

  /// Overrides the ambient [AerosDensity].
  final AerosDensity? density;

  /// What a screen reader says instead of the bare number (e.g. "3 unread").
  final String? semanticsLabel;

  /// The text a [count] renders as.
  static String label(int count, {bool floor = false}) {
    if (count > 99) return '99+';
    return floor ? '$count+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final h = (density ?? AerosDensity.of(context)).sizes.badge;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Container(
        constraints: BoxConstraints(minWidth: h),
        height: h,
        // Tight enough that one digit stays a circle.
        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1),
        decoration: BoxDecoration(
          color: muted ? a.fgMuted : a.brandPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
        ),
        // Shrink-wraps: an Align with no width factor would fill whatever
        // width a Wrap or a Column offers.
        child: Center(
          widthFactor: 1,
          child: Text(
            label(count, floor: floor),
            maxLines: 1,
            softWrap: false,
            style: AerosTypography.labelXs(color: a.fgInverse, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
