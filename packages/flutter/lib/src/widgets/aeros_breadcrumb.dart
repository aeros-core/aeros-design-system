import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class AerosBreadcrumbItem {
  const AerosBreadcrumbItem(this.label, {this.onTap});
  final String label;
  final VoidCallback? onTap;
}

/// The trail to the current page.
///
/// Crumbs are `labelSm`: the ancestors in `fgMuted` (an ancestor with an
/// `onTap` is a button — `fgPrimary` on hover, the focus ring on keyboard
/// focus), the last one — the current page — in `fgPrimary`. Chevrons point
/// along the reading direction.
class AerosBreadcrumb extends StatelessWidget {
  const AerosBreadcrumb({super.key, required this.items});
  final List<AerosBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final last = i == items.length - 1;
      if (last || item.onTap == null) {
        children.add(Text(
          item.label,
          maxLines: 1,
          softWrap: false,
          style: AerosTypography.labelSm(color: last ? a.fgPrimary : a.fgMuted),
        ));
      } else {
        children.add(AerosPressable(
          onPressed: item.onTap,
          builder: (context, state) => AerosFocusRing(
            focused: state.focused,
            radius: const BorderRadius.all(Radius.circular(AerosShapeTokens.item)),
            child: Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              style: AerosTypography.labelSm(color: state.hovered || state.pressed ? a.fgPrimary : a.fgMuted),
            ),
          ),
        ));
      }
      if (!last) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1),
          child: ExcludeSemantics(
            child: Icon(
              rtl ? Icons.chevron_left : Icons.chevron_right,
              size: AerosSizeTokens.iconSm,
              color: a.fgMuted,
            ),
          ),
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
