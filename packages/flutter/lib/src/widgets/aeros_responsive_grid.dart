import 'package:flutter/material.dart';
import '../tokens/spacing.dart';
import 'aeros_responsive_value.dart';

/// Grid that picks its `crossAxisCount` and `childAspectRatio` per
/// breakpoint, so a single declaration covers phone → wide.
///
/// ```dart
/// AerosResponsiveGrid(
///   crossAxisCount: AerosResponsiveValue(xs: 2, sm: 2, md: 4, lg: 4),
///   aspectRatio:    AerosResponsiveValue(xs: 1.4, md: 1.9),
///   children: tiles,
/// )
/// ```
///
/// Alternatively, supply `tileMinWidth` to auto-fill: the widget divides
/// the parent width by `tileMinWidth` to pick the column count
/// (clamped to `[1, 12]`). `crossAxisCount` wins when both are set.
class AerosResponsiveGrid extends StatelessWidget {
  const AerosResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.tileMinWidth,
    this.aspectRatio,
    this.mainAxisSpacing = AerosSpacing.s3,
    this.crossAxisSpacing = AerosSpacing.s3,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
  }) : assert(crossAxisCount != null || tileMinWidth != null,
            'Provide crossAxisCount, tileMinWidth, or both.');

  final List<Widget> children;
  final AerosResponsiveValue<int>? crossAxisCount;

  /// Used when [crossAxisCount] is null. The grid divides the parent
  /// max width by this and clamps to `[1, 12]` columns.
  final double? tileMinWidth;

  final AerosResponsiveValue<double>? aspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ratio = aspectRatio?.resolve(context) ?? 1.0;
    final explicitCols = crossAxisCount?.resolve(context);

    if (explicitCols != null) {
      return GridView.count(
        crossAxisCount: explicitCols,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: ratio,
        children: children,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final cols = (width / tileMinWidth!).floor().clamp(1, 12);
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: ratio,
          children: children,
        );
      },
    );
  }
}
