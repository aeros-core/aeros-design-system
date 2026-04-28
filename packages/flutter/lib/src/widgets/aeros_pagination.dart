import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AerosPaginationVariant { compact, numbered }

class AerosPagination extends StatelessWidget {
  const AerosPagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onChanged,
    this.variant = AerosPaginationVariant.compact,
    this.maxVisiblePages = 5,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onChanged;
  final AerosPaginationVariant variant;
  final int maxVisiblePages;

  bool get _hasPrev => page > 1;
  bool get _hasNext => page < totalPages;

  void _go(int target) {
    if (target < 1 || target > totalPages || target == page) return;
    onChanged(target);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return switch (variant) {
      AerosPaginationVariant.compact => _buildCompact(a),
      AerosPaginationVariant.numbered => _buildNumbered(a),
    };
  }

  Widget _buildCompact(a) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(
          icon: Icons.arrow_back_ios_new,
          enabled: _hasPrev,
          onTap: () => _go(page - 1),
          fg: a.fgPrimary,
          fgMuted: a.fgMuted,
        ),
        const SizedBox(width: AerosSpacing.s3),
        Text(
          '$page / $totalPages',
          style: AerosTypography.bodyMd(color: a.fgPrimary),
        ),
        const SizedBox(width: AerosSpacing.s3),
        _ArrowButton(
          icon: Icons.arrow_forward_ios,
          enabled: _hasNext,
          onTap: () => _go(page + 1),
          fg: a.fgPrimary,
          fgMuted: a.fgMuted,
        ),
      ],
    );
  }

  Widget _buildNumbered(a) {
    final pages = _visiblePages();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowButton(
          icon: Icons.arrow_back_ios_new,
          enabled: _hasPrev,
          onTap: () => _go(page - 1),
          fg: a.fgPrimary,
          fgMuted: a.fgMuted,
        ),
        const SizedBox(width: AerosSpacing.s2),
        for (final p in pages) ...[
          _PageButton(
            label: p == null ? '…' : '$p',
            selected: p == page,
            onTap: p == null ? null : () => _go(p),
            fg: a.fgPrimary,
            fgMuted: a.fgMuted,
            selectedBg: a.brandPrimary,
            selectedFg: a.fgInverse,
            border: a.borderDefault,
          ),
          const SizedBox(width: AerosSpacing.s1),
        ],
        const SizedBox(width: AerosSpacing.s1),
        _ArrowButton(
          icon: Icons.arrow_forward_ios,
          enabled: _hasNext,
          onTap: () => _go(page + 1),
          fg: a.fgPrimary,
          fgMuted: a.fgMuted,
        ),
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

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.fg,
    required this.fgMuted,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color fg;
  final Color fgMuted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AerosRadii.brSm,
      child: Padding(
        padding: const EdgeInsets.all(AerosSpacing.s2),
        child: Icon(icon, size: 14, color: enabled ? fg : fgMuted),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fg,
    required this.fgMuted,
    required this.selectedBg,
    required this.selectedFg,
    required this.border,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color fg;
  final Color fgMuted;
  final Color selectedBg;
  final Color selectedFg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: AerosRadii.brSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AerosRadii.brSm,
        child: Container(
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: AerosRadii.brSm,
            border: selected ? null : Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AerosTypography.bodySm(
              color: selected ? selectedFg : (disabled ? fgMuted : fg),
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
