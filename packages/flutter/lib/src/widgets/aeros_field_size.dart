import 'package:flutter/widgets.dart';

import '../tokens/radii.dart';
import '../tokens/typography.dart';

/// Shared size ladder for Aeros input controls
/// ([AerosTextField], [AerosSearchField], [AerosTagField]).
///
/// The heights are lifted **verbatim** from the [AerosButton] min-height ladder
/// (sm 32 · md 40 · lg 46) and the radii from its radius-per-size mapping
/// (brSm · brMd · brLg), so a field and a button of the same size are
/// dimensionally interchangeable — placed side by side they share one baseline.
///
/// Value text is `w500` (one weight step below the `w600` button label) with a
/// tightened line-height, so an input reads as a sturdy sibling of the button
/// rather than a taller, thinner control.
enum AerosFieldSize { sm, md, lg }

extension AerosFieldSizeMetrics on AerosFieldSize {
  /// Target control height in logical px — equals [AerosButton] sm/md/lg.
  double get height => switch (this) {
        AerosFieldSize.sm => 32,
        AerosFieldSize.md => 40,
        AerosFieldSize.lg => 46,
      };

  /// Horizontal content padding.
  double get padH => switch (this) {
        AerosFieldSize.sm => 12,
        AerosFieldSize.md => 14,
        AerosFieldSize.lg => 16,
      };

  /// Vertical content padding, tuned so `lineBox + 2·padV + 2·border ≈ height`
  /// (value line-height is 1.3 — see [valueStyle]).
  double get padV => switch (this) {
        AerosFieldSize.sm => 7,
        AerosFieldSize.md => 10,
        AerosFieldSize.lg => 13,
      };

  /// Corner radius — matches the [AerosButton] radius for the same size.
  BorderRadius get radius => switch (this) {
        AerosFieldSize.sm => AerosRadii.brSm,
        AerosFieldSize.md => AerosRadii.brMd,
        AerosFieldSize.lg => AerosRadii.brLg,
      };

  /// Leading/trailing glyph size.
  double get iconSize => this == AerosFieldSize.sm ? 16 : 18;

  /// Typed-value / hint text style at this size — `w500`, line-height 1.3.
  TextStyle valueStyle({Color? color}) {
    final base = this == AerosFieldSize.sm
        ? AerosTypography.bodySm(color: color)
        : AerosTypography.bodyMd(color: color);
    return base.copyWith(fontWeight: FontWeight.w500, height: 1.3);
  }
}
