import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_breadcrumb.dart';

/// Compound page header used at the top of every admin screen.
/// Composes: optional breadcrumbs row, then a title row (leading +
/// title + subtitle + action buttons).
///
/// The title row is at least one app header high ([AerosSizeTokens.header]
/// for the density — the height of `AerosTopnav` and of the sidenav's header
/// block), with the title centred in it. With the default padding (horizontal
/// only) a page header at the top of the content therefore sits level with
/// the rail's header beside it.
///
/// **Responsive by construction.** The title and subtitle take the width the
/// actions leave: the title runs to two lines and the subtitle to three before
/// they are cut with an ellipsis. The [actions] sit beside the title while the
/// title block either fits whole or keeps a readable measure
/// ([AerosMetricTokens.layoutSidebar]); when it cannot, they move to a row of
/// their own under the title, across the full width, and wrap there. Nothing
/// overflows at any width, so a page never has to move its actions itself.
///
/// ```dart
/// AerosPageHeader(
///   breadcrumbs: [
///     AerosBreadcrumbItem('Home', onTap: ...),
///     AerosBreadcrumbItem('Masters', onTap: ...),
///     AerosBreadcrumbItem('Industries'),
///   ],
///   title: 'Industries',
///   subtitle: 'Manage the industries available to organisations',
///   actions: [
///     AerosButton(label: 'Export', onPressed: ..., variant: AerosButtonVariant.secondary),
///     AerosButton(label: 'Add', onPressed: ...),
///   ],
/// );
/// ```
class AerosPageHeader extends StatelessWidget {
  const AerosPageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.breadcrumbs,
    this.leading,
    this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: AerosSpacing.s4),
  }) : assert(title != null || titleWidget != null, 'Provide either title or titleWidget');

  /// Title string. If you need richer content, use [titleWidget] instead.
  final String? title;

  /// Custom title widget. Takes precedence over [title].
  final Widget? titleWidget;

  /// One-line description shown below the title.
  final String? subtitle;

  /// Custom subtitle widget. Takes precedence over [subtitle].
  final Widget? subtitleWidget;

  /// Optional breadcrumb trail rendered above the title row.
  final List<AerosBreadcrumbItem>? breadcrumbs;

  /// Optional widget shown to the left of the title (e.g. back button).
  final Widget? leading;

  /// Action buttons: at the end of the title row while there is room, on a
  /// wrapping row under the title when there is not.
  final List<Widget>? actions;

  /// Around the header. Horizontal only by default: the title row brings its
  /// own height.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    final titleNode = titleWidget ??
        Semantics(
          header: true,
          child: Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AerosTypography.h2(color: a.fgPrimary),
          ),
        );

    final subtitleNode = subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AerosTypography.bodySm(color: a.fgSecondary),
              )
            : null);

    final hasCrumbs = breadcrumbs != null && breadcrumbs!.isNotEmpty;
    final hasActions = actions != null && actions!.isNotEmpty;

    // Hugs its content under loose constraints, so the row below can tell
    // whether the whole title block fits beside the actions.
    final main = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AerosSpacing.s3),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleNode,
              if (subtitleNode != null) subtitleNode,
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasCrumbs)
            Padding(
              // The trail keeps its own air above the title, whatever the
              // title row's height leaves.
              padding: const EdgeInsets.only(top: AerosSpacing.s2, bottom: AerosSpacing.s1_5),
              // A long trail scrolls rather than overflowing.
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AerosBreadcrumb(items: breadcrumbs!),
              ),
            ),
          _TitleRow(
            minHeight: AerosDensity.of(context).sizes.header,
            gap: AerosSpacing.s4,
            stackedGap: AerosSpacing.s2,
            minTitleWidth: AerosMetricTokens.layoutSidebar,
            textDirection: Directionality.of(context),
            children: [
              main,
              if (hasActions)
                Wrap(
                  spacing: AerosSpacing.s2,
                  runSpacing: AerosSpacing.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lays out the title block (first child) and, optionally, the actions
/// (second child): side by side while both fit, stacked when they do not.
class _TitleRow extends MultiChildRenderObjectWidget {
  const _TitleRow({
    required this.minHeight,
    required this.gap,
    required this.stackedGap,
    required this.minTitleWidth,
    required this.textDirection,
    required super.children,
  });

  final double minHeight;
  final double gap;
  final double stackedGap;
  final double minTitleWidth;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTitleRow(
        minHeight: minHeight,
        gap: gap,
        stackedGap: stackedGap,
        minTitleWidth: minTitleWidth,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderTitleRow renderObject) {
    renderObject
      ..minHeight = minHeight
      ..gap = gap
      ..stackedGap = stackedGap
      ..minTitleWidth = minTitleWidth
      ..textDirection = textDirection;
  }
}

class _TitleRowParentData extends ContainerBoxParentData<RenderBox> {}

typedef _ChildLayouter = Size Function(RenderBox child, BoxConstraints constraints);

class _RenderTitleRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TitleRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TitleRowParentData> {
  _RenderTitleRow({
    required double minHeight,
    required double gap,
    required double stackedGap,
    required double minTitleWidth,
    required TextDirection textDirection,
  })  : _minHeight = minHeight,
        _gap = gap,
        _stackedGap = stackedGap,
        _minTitleWidth = minTitleWidth,
        _textDirection = textDirection;

  double _minHeight;
  set minHeight(double value) {
    if (value == _minHeight) return;
    _minHeight = value;
    markNeedsLayout();
  }

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  double _stackedGap;
  set stackedGap(double value) {
    if (value == _stackedGap) return;
    _stackedGap = value;
    markNeedsLayout();
  }

  double _minTitleWidth;
  set minTitleWidth(double value) {
    if (value == _minTitleWidth) return;
    _minTitleWidth = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TitleRowParentData) child.parentData = _TitleRowParentData();
  }

  /// Sizes both children and reports where they go. Shared by the real and
  /// the dry layout.
  ({Size size, Size main, Size actions, bool stacked}) _compute(BoxConstraints constraints, _ChildLayouter layout) {
    final main = firstChild!;
    final actions = childAfter(main);
    final available = constraints.maxWidth;
    final loose = BoxConstraints(maxWidth: available);

    if (actions == null) {
      final mainSize = layout(main, loose);
      final width = available.isFinite ? available : mainSize.width;
      return (
        size: constraints.constrain(Size(width, math.max(_minHeight, mainSize.height))),
        main: mainSize,
        actions: Size.zero,
        stacked: false,
      );
    }

    // The actions on one line, as wide as they like (a Wrap breaks only when
    // it runs out of width).
    var actionsSize = layout(actions, loose);
    var mainSize = layout(main, loose);
    final beside = available - _gap - actionsSize.width;

    var stacked = false;
    if (mainSize.width > beside) {
      if (beside >= _minTitleWidth) {
        // Not whole, but a readable measure: the title wraps or truncates.
        mainSize = layout(main, BoxConstraints(maxWidth: beside));
      } else {
        stacked = true;
      }
    }

    if (!stacked) {
      final height = math.max(_minHeight, math.max(mainSize.height, actionsSize.height));
      final width = available.isFinite ? available : mainSize.width + _gap + actionsSize.width;
      return (size: constraints.constrain(Size(width, height)), main: mainSize, actions: actionsSize, stacked: false);
    }

    actionsSize = layout(actions, loose);
    final titleBand = math.max(_minHeight, mainSize.height);
    final width = available.isFinite ? available : math.max(mainSize.width, actionsSize.width);
    return (
      size: constraints.constrain(Size(width, titleBand + _stackedGap + actionsSize.height)),
      main: mainSize,
      actions: actionsSize,
      stacked: true,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (firstChild == null) return constraints.constrain(Size(0, _minHeight));
    return _compute(constraints, ChildLayoutHelper.dryLayoutChild).size;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width = math.max(width, child.getMinIntrinsicWidth(double.infinity));
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    var count = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width += child.getMaxIntrinsicWidth(double.infinity);
      count++;
    }
    return width + (count > 1 ? _gap : 0);
  }

  @override
  double computeMinIntrinsicHeight(double width) => computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (firstChild == null) return _minHeight;
    return getDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  void performLayout() {
    final main = firstChild;
    if (main == null) {
      size = constraints.constrain(Size(0, _minHeight));
      return;
    }
    final actions = childAfter(main);
    final result = _compute(constraints, ChildLayoutHelper.layoutChild);
    size = result.size;
    final rtl = _textDirection == TextDirection.rtl;

    double startX(double childWidth) => rtl ? size.width - childWidth : 0;
    double endX(double childWidth) => rtl ? 0 : size.width - childWidth;

    final mainData = main.parentData! as _TitleRowParentData;
    if (!result.stacked) {
      mainData.offset = Offset(startX(result.main.width), (size.height - result.main.height) / 2);
      if (actions != null) {
        (actions.parentData! as _TitleRowParentData).offset =
            Offset(endX(result.actions.width), (size.height - result.actions.height) / 2);
      }
      return;
    }
    final titleBand = math.max(_minHeight, result.main.height);
    mainData.offset = Offset(startX(result.main.width), (titleBand - result.main.height) / 2);
    (actions!.parentData! as _TitleRowParentData).offset =
        Offset(startX(result.actions.width), titleBand + _stackedGap);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
