import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';
import '../tokens/radii.dart';
import '../tokens/shadows.dart';
import '../tokens/typography.dart';

enum AerosTabVariant { underline, pill }

/// Tab strip. Keyboard-operable: Tab reaches the strip, Enter/Space activates
/// a tab (InkWell), and ←/→ move the selection while any tab has focus.
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

  void _step(int delta) {
    final next = (selectedIndex + delta).clamp(0, tabs.length - 1);
    if (next != selectedIndex) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final strip = variant == AerosTabVariant.underline
        ? Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: a.borderDefault)),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = i == selectedIndex;
                return _tab(
                  context,
                  index: i,
                  active: active,
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
                );
              }),
            ),
          )
        : Container(
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
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                  child: _tab(
                    context,
                    index: i,
                    active: active,
                    borderRadius: AerosRadii.brMd,
                    child: AnimatedContainer(
                      duration: AerosMotion.resolve(context, AerosMotion.fast),
                      curve: AerosMotion.standard,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

    // Arrow keys move the selection while focus is anywhere inside the strip.
    return FocusTraversalGroup(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(-1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(1),
        },
        child: strip,
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required int index,
    required bool active,
    required Widget child,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    final a = context.aerosColors;
    return Semantics(
      button: true,
      selected: active,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(index),
          borderRadius: borderRadius,
          hoverColor: Colors.transparent,
          splashColor: a.fgPrimary.withValues(alpha: 0.06),
          focusColor: a.brandPrimaryMuted,
          child: child,
        ),
      ),
    );
  }
}
