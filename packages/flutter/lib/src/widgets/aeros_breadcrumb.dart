import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class AerosBreadcrumbItem {
  const AerosBreadcrumbItem(this.label, {this.onTap});
  final String label;
  final VoidCallback? onTap;
}

class AerosBreadcrumb extends StatelessWidget {
  const AerosBreadcrumb({super.key, required this.items});
  final List<AerosBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final last = i == items.length - 1;
      children.add(
        GestureDetector(
          onTap: last ? null : items[i].onTap,
          child: Text(
            items[i].label,
            style: AerosTypography.bodySm(
              color: last ? a.fgPrimary : a.fgMuted,
            ).copyWith(fontWeight: last ? FontWeight.w600 : FontWeight.w500),
          ),
        ),
      );
      if (!last) {
        children.add(const SizedBox(width: 4));
        children.add(Icon(Icons.chevron_right, size: 14, color: AerosColors.ink200));
        children.add(const SizedBox(width: 4));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
