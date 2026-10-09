import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/density.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

/// A count that something is waiting — unread messages, pending items.
///
/// A filled pill, at least as wide as it is tall: 18px at [AerosDensity.pointer], 20px at
/// [AerosDensity.touch] (from the nearest [AerosDensityScope] unless [density] is given). Counts
/// above 99 read "99+". Set [floor] when the number is a lower bound (more exist than were
/// counted), and it reads "6+". Set [muted] when the source is muted: the count still shows, it
/// just stops shouting (the WhatsApp grey badge).
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
    final d = density ?? AerosDensity.of(context);
    final h = d.badgeHeight;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Container(
        constraints: BoxConstraints(minWidth: h),
        height: h,
        padding: EdgeInsets.symmetric(horizontal: d.isPointer ? 5 : 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: muted ? a.fgMuted : a.brandPrimary,
          borderRadius: AerosRadii.brFull,
        ),
        child: Text(
          label(count, floor: floor),
          maxLines: 1,
          style: AerosTypography.labelXs(color: a.fgInverse)
              .copyWith(fontSize: d.isPointer ? 11 : 12, height: 1.0)
              .withWeight(FontWeight.w700),
        ),
      ),
    );
  }
}
