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
///
/// The default constructor gives every tile one shape ([aspectRatio], 1.0
/// when not given). For tiles that take the height of their content — cards,
/// stat tiles, form panels — use [AerosResponsiveGrid.auto].
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
  })  : _auto = false,
        equalHeights = false,
        assert(crossAxisCount != null || tileMinWidth != null, 'Provide crossAxisCount, tileMinWidth, or both.');

  /// A grid of equal-width tiles that take their own height: each row is as
  /// tall as its tallest tile.
  ///
  /// Columns come from [crossAxisCount] per breakpoint, or from
  /// [tileMinWidth]: as many columns as fit with every tile at least that
  /// wide (the spacing counted), and never more columns than tiles, so a
  /// short row still fills the width. [equalHeights] stretches the tiles of a
  /// row to the tallest one — for a row of cards.
  ///
  /// It does not scroll; put it in a scroll view. It needs a bounded width.
  ///
  /// ```dart
  /// AerosResponsiveGrid.auto(
  ///   tileMinWidth: 200,
  ///   equalHeights: true,
  ///   children: [for (final stat in stats) AerosStatCard(label: stat.label, value: stat.value)],
  /// )
  /// ```
  const AerosResponsiveGrid.auto({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.tileMinWidth,
    this.equalHeights = false,
    this.mainAxisSpacing = AerosSpacing.s3,
    this.crossAxisSpacing = AerosSpacing.s3,
    this.padding,
  })  : _auto = true,
        aspectRatio = null,
        shrinkWrap = true,
        physics = const NeverScrollableScrollPhysics(),
        assert(crossAxisCount != null || tileMinWidth != null, 'Provide crossAxisCount, tileMinWidth, or both.');

  final List<Widget> children;
  final AerosResponsiveValue<int>? crossAxisCount;

  /// Used when [crossAxisCount] is null. The grid divides the parent
  /// max width by this and clamps to `[1, 12]` columns.
  final double? tileMinWidth;

  /// Width / height of every tile. Not used by [AerosResponsiveGrid.auto].
  final AerosResponsiveValue<double>? aspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry? padding;

  /// [AerosResponsiveGrid.auto] only: make the tiles of a row as tall as the
  /// tallest. The tiles are then measured intrinsically, so they must not
  /// hold a `LayoutBuilder`.
  final bool equalHeights;
  final bool _auto;

  Widget _autoGrid(int columns) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      if (start > 0) rows.add(SizedBox(height: mainAxisSpacing));
      final row = Row(
        crossAxisAlignment: equalHeights ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: [
          for (var i = start; i < start + columns; i++) ...[
            if (i > start) SizedBox(width: crossAxisSpacing),
            // An empty cell keeps the last row's tiles the same width.
            Expanded(child: i < children.length ? children[i] : const SizedBox.shrink()),
          ],
        ],
      );
      rows.add(equalHeights ? IntrinsicHeight(child: row) : row);
    }
    final grid = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    return padding == null ? grid : Padding(padding: padding!, child: grid);
  }

  @override
  Widget build(BuildContext context) {
    final explicitCols = crossAxisCount?.resolve(context);

    if (_auto) {
      if (children.isEmpty) return const SizedBox.shrink();
      if (explicitCols != null) return _autoGrid(explicitCols.clamp(1, 12));
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width) -
              (padding?.horizontal ?? 0);
          final fit = ((width + crossAxisSpacing) / (tileMinWidth! + crossAxisSpacing)).floor();
          return _autoGrid(fit.clamp(1, children.length.clamp(1, 12)));
        },
      );
    }

    final ratio = aspectRatio?.resolve(context) ?? 1.0;

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
