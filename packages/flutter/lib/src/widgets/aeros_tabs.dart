import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosTabVariant { underline, pill }

class AerosTabs extends StatelessWidget {
  const AerosTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = AerosTabVariant.underline,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final AerosTabVariant variant;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    if (variant == AerosTabVariant.underline) {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: a.borderDefault)),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = i == selectedIndex;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: -1),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? AerosColors.royal600 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: AerosTypography.bodySm(
                    color: active ? AerosColors.royal600 : a.fgMuted,
                  ).copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
                ),
              ),
            );
          }),
        ),
      );
    }
    // pill
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: a.bgSubtle,
        border: Border.all(color: a.borderDefault),
        borderRadius: AerosRadii.brLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (i) {
          final active = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
              decoration: BoxDecoration(
                color: active ? a.bgSurface : Colors.transparent,
                borderRadius: AerosRadii.brMd,
                boxShadow: active
                    ? const [BoxShadow(color: Color(0x120A0F2E), blurRadius: 3, offset: Offset(0, 1))]
                    : null,
              ),
              child: Text(
                tabs[i],
                style: AerosTypography.bodySm(color: active ? a.fgPrimary : a.fgMuted)
                    .copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
              ),
            ),
          );
        }),
      ),
    );
  }
}
