import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';
import '../tokens/radii.dart';
import '../tokens/shadows.dart';
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
            return _tabSemantics(
              active: active,
              child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? a.fgPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: AerosTypography.bodySm(
                      color: active ? a.fgPrimary : a.fgMuted,
                    ).copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
                  ),
                ),
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
          return _tabSemantics(
            active: active,
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: AerosMotion.fast,
                curve: AerosMotion.standard,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                decoration: BoxDecoration(
                  color: active ? a.bgSurface : Colors.transparent,
                  borderRadius: AerosRadii.brMd,
                  boxShadow: active ? AerosShadows.card(context.aeros.isDark) : null,
                ),
                child: Text(
                  tabs[i],
                  style: AerosTypography.bodySm(color: active ? a.fgPrimary : a.fgMuted)
                      .copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w500),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Screen readers hear each tab as a selectable button ("selected"/"tab").
  /// Full keyboard roving (arrow keys, focus ring) is tracked as audit A-17.
  Widget _tabSemantics({required bool active, required Widget child}) {
    return Semantics(
      button: true,
      selected: active,
      inMutuallyExclusiveGroup: true,
      child: child,
    );
  }
}
