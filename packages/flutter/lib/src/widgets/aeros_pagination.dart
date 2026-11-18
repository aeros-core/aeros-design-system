import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';

enum AerosPaginationVariant { compact, numbered }

/// Page navigation.
///
/// Every button is one control ([AerosControlSize.sm]) high and square. The
/// arrows are ghost icon buttons; page numbers are ghost until hovered, and
/// the current page is solid `brandPrimary`. Keyboard focus draws the focus
/// ring. [previousLabel] / [nextLabel] name the arrows for screen readers.
///
/// The numbered variant fits the width it is given: it shows up to
/// [maxVisiblePages] numbers around the current page, fewer when they do not
/// fit (the first page, the last page, the current page and the "…" between
/// them always stay), and falls back to the compact form when even that is
/// too wide. To do so it reads its constraints, so give it a bounded width —
/// in a `Row`, wrap it in `Flexible` or `Expanded`; as a plain child of a
/// `Row` it is offered unlimited width and shows the full window. (For the
/// same reason the numbered variant cannot be measured by `IntrinsicWidth` /
/// `IntrinsicHeight`.)
class AerosPagination extends StatelessWidget {
  const AerosPagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onChanged,
    this.variant = AerosPaginationVariant.compact,
    this.maxVisiblePages = 5,
    this.previousLabel = 'Previous page',
    this.nextLabel = 'Next page',
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onChanged;
  final AerosPaginationVariant variant;

  /// The most page numbers shown around the current page by the numbered
  /// variant (the first and last page and the "…" come on top). An upper
  /// bound: fewer are shown when the width runs out.
  final int maxVisiblePages;
  final String previousLabel;
  final String nextLabel;

  static const AerosControlSize _size = AerosControlSize.sm;

  bool get _hasPrev => page > 1;
  bool get _hasNext => page < totalPages;

  void _go(int target) {
    if (target < 1 || target > totalPages || target == page) return;
    onChanged(target);
  }

  Widget _arrow(BuildContext context, {required bool forward}) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = forward ? _hasNext : _hasPrev;
    return AerosButton.icon(
      // Points along the reading direction.
      icon: Icon(forward != rtl ? Icons.chevron_right : Icons.chevron_left),
      semanticLabel: forward ? nextLabel : previousLabel,
      size: _size,
      onPressed: enabled ? () => _go(forward ? page + 1 : page - 1) : null,
    );
  }

  /// The room one page number takes: at least a square control, wider for a
  /// long number. Mirrors [_PageButton]'s own box.
  double _pageWidth(BuildContext context, int? page, double side) {
    if (page == null) return side;
    final painter = TextPainter(
      text: TextSpan(text: '$page', style: _size.labelStyle()),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width + (AerosSpacing.s1_5 + AerosMetricTokens.borderHairline) * 2;
    painter.dispose();
    return math.max(side, width.ceilToDouble());
  }

  /// Width of the numbered row showing [pages].
  double _numberedWidth(BuildContext context, List<int?> pages) {
    final side = _size.resolveHeight(context);
    // An arrow is a square control inside the density's minimum target.
    final arrow = math.max(side, AerosDensity.of(context).sizes.minTarget);
    var width = arrow * 2 + AerosSpacing.s1;
    for (final page in pages) {
      width += _pageWidth(context, page, side) + AerosSpacing.s1;
    }
    return width;
  }

  /// The widest run of pages that fits [maxWidth], or null when not even the
  /// smallest (first … current … last) does.
  List<int?>? _fit(BuildContext context, double maxWidth) {
    final windows = <int>[
      maxVisiblePages,
      // Then odd windows, shrinking to the current page alone.
      for (var half = (maxVisiblePages - 1) ~/ 2; half >= 0; half--)
        if (half * 2 + 1 < maxVisiblePages) half * 2 + 1,
    ];
    for (final window in windows) {
      final pages = _visiblePages(window);
      if (!maxWidth.isFinite || _numberedWidth(context, pages) <= maxWidth) return pages;
    }
    return null;
  }

  Widget _row(BuildContext context, List<int?>? pages) {
    final a = context.aerosColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _arrow(context, forward: false),
        const SizedBox(width: AerosSpacing.s1),
        if (pages == null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2),
            child: Text(
              '$page / $totalPages',
              maxLines: 1,
              softWrap: false,
              style: AerosTypography.labelSm(color: a.fgPrimary),
            ),
          ),
          const SizedBox(width: AerosSpacing.s1),
        ] else
          for (final p in pages) ...[
            _PageButton(
              page: p,
              selected: p == page,
              size: _size,
              onTap: p == null ? null : () => _go(p),
            ),
            const SizedBox(width: AerosSpacing.s1),
          ],
        _arrow(context, forward: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == AerosPaginationVariant.compact) return _row(context, null);
    return LayoutBuilder(
      builder: (context, constraints) => _row(context, _fit(context, constraints.maxWidth)),
    );
  }

  List<int?> _visiblePages(int window) {
    if (totalPages <= window) {
      return [for (var i = 1; i <= totalPages; i++) i];
    }
    final half = window ~/ 2;
    var start = page - half;
    var end = page + half;
    if (start < 1) {
      end += 1 - start;
      start = 1;
    }
    if (end > totalPages) {
      start -= end - totalPages;
      end = totalPages;
    }
    if (start < 1) start = 1;

    final out = <int?>[];
    if (start > 1) {
      out.add(1);
      if (start > 2) out.add(null);
    }
    for (var i = start; i <= end; i++) {
      out.add(i);
    }
    if (end < totalPages) {
      if (end < totalPages - 1) out.add(null);
      out.add(totalPages);
    }
    return out;
  }
}

/// One page number, or — with a null [page] — the "…" between two runs.
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final int? page;
  final bool selected;
  final AerosControlSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final side = size.resolveHeight(context);
    final box = BoxConstraints(minWidth: side, minHeight: side, maxHeight: side);
    final page = this.page;

    if (page == null) {
      return ConstrainedBox(
        constraints: box,
        child: Center(
          widthFactor: 1,
          child: ExcludeSemantics(child: Text('…', style: size.labelStyle(color: a.fgMuted))),
        ),
      );
    }

    return AerosPressable(
      onPressed: onTap,
      selected: selected,
      // A run of numbers stays as tight as the controls themselves; the
      // arrows on either side carry the full-size target.
      expandHitTarget: false,
      semanticLabel: 'Page $page',
      excludeSemantics: true,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        // The state overlays are ink and vanish on the solid brand fill.
        final fill = selected
            ? (active ? a.brandPrimaryHover : a.brandPrimary)
            : AerosStateLayer.resolve(a, Colors.transparent, hovered: state.hovered, pressed: state.pressed);
        return AerosFocusRing(
          focused: state.focused,
          radius: size.radius,
          child: AerosStateFill(
            color: fill,
            radius: size.radius,
            constraints: box,
            padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1_5),
            child: Center(
              widthFactor: 1,
              child: Text(
                '$page',
                maxLines: 1,
                softWrap: false,
                style: size.labelStyle(color: selected ? a.fgInverse : a.fgPrimary),
              ),
            ),
          ),
        );
      },
    );
  }
}
