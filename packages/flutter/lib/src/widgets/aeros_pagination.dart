import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
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

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _arrow(context, forward: false),
        const SizedBox(width: AerosSpacing.s1),
        if (variant == AerosPaginationVariant.compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2),
            child: Text('$page / $totalPages', style: AerosTypography.labelSm(color: a.fgPrimary)),
          )
        else
          for (final p in _visiblePages()) ...[
            _PageButton(
              page: p,
              selected: p == page,
              size: _size,
              onTap: p == null ? null : () => _go(p),
            ),
            const SizedBox(width: AerosSpacing.s1),
          ],
        if (variant == AerosPaginationVariant.compact) const SizedBox(width: AerosSpacing.s1),
        _arrow(context, forward: true),
      ],
    );
  }

  List<int?> _visiblePages() {
    if (totalPages <= maxVisiblePages) {
      return [for (var i = 1; i <= totalPages; i++) i];
    }
    final half = maxVisiblePages ~/ 2;
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
