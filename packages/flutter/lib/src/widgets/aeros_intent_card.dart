import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_badge.dart';

/// Large tappable choice card used in onboarding intent screens
/// ("buying for myself" / "buying for my business").
///
/// Flat: a fill and a 1px hairline that stays 1px. Hover and press tint the
/// fill and strengthen the hairline; [selected] draws the hairline in
/// `fgPrimary` over the selected tint and is announced as selected.
class AerosIntentCard extends StatelessWidget {
  const AerosIntentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.badge,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badge;
  final bool selected;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.surface));

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    return AerosPressable(
      onPressed: onTap,
      expandHitTarget: false,
      selected: selected,
      builder: (context, state) {
        final active = state.hovered || state.pressed;
        return AerosFocusRing(
          focused: state.focused,
          radius: _radius,
          child: AerosStateFill(
            color: AerosStateLayer.resolve(
              a,
              a.bgSurface,
              hovered: state.hovered,
              pressed: state.pressed,
              selected: selected,
            ),
            borderColor: selected ? a.fgPrimary : (active ? a.borderStrong : a.borderDefault),
            radius: _radius,
            padding: const EdgeInsets.all(AerosSpacing.s4 - AerosMetricTokens.borderHairline),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    width: AerosSizeTokens.avatarLg,
                    height: AerosSizeTokens.avatarLg,
                    decoration: BoxDecoration(
                      color: a.bgSubtle,
                      borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.control)),
                      border: Border.all(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
                    ),
                    child: Icon(icon, size: AerosSizeTokens.iconLg, color: a.fgPrimary),
                  ),
                  const SizedBox(width: AerosSpacing.s3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(title, style: AerosTypography.h4(color: a.fgPrimary))),
                          if (badge != null) ...[
                            const SizedBox(width: AerosSpacing.s2),
                            AerosBadge(label: badge!, showDot: false),
                          ],
                        ],
                      ),
                      const SizedBox(height: AerosSpacing.s0_5),
                      Text(subtitle, style: AerosTypography.bodySm(color: a.fgSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: AerosSpacing.s2),
                Icon(
                  Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
                  size: AerosSizeTokens.iconLg,
                  color: active || selected ? a.fgPrimary : a.fgMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
