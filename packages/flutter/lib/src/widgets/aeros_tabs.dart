import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AerosTabVariant { underline, pill }

/// Tab strip.
///
/// - [AerosTabVariant.underline]: a 1px baseline hairline under the strip and
///   a 2px `fgPrimary` indicator under the active tab. Tabs are one list row
///   high ([AerosSizeTokens.row]).
/// - [AerosTabVariant.pill]: a compact segmented track, one control high
///   ([AerosControlSize.md]); the active segment is a `bgElevated` chip with the
///   faintest lift ([AerosElevation.raised]).
///
/// The active label is `fgPrimary` at w600, the others `fgSecondary` at w500;
/// hover changes colour only. Keyboard-operable: Tab reaches the strip, Enter /
/// Space activates the focused tab (which draws the focus ring), and ← / →
/// move the selection while any tab has focus (mirrored in right-to-left).
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

  static const BorderRadius _item = BorderRadius.all(Radius.circular(AerosShapeTokens.item));
  static const BorderRadius _control = BorderRadius.all(Radius.circular(AerosShapeTokens.control));

  void _step(int delta) {
    final next = (selectedIndex + delta).clamp(0, tabs.length - 1);
    if (next != selectedIndex) onChanged(next);
  }

  TextStyle _label(AerosAliasColors a, {required bool active, required AerosInteraction state}) =>
      AerosTypography.labelSm(
        color: active || state.hovered || state.pressed ? a.fgPrimary : a.fgSecondary,
        weight: active ? FontWeight.w600 : FontWeight.w500,
      );

  Widget _pressable({
    required int index,
    required AerosPressableBuilder builder,
  }) =>
      AerosPressable(
        onPressed: () => onChanged(index),
        selected: index == selectedIndex,
        inMutuallyExclusiveGroup: true,
        // The tab is already a full row (or the full track) high.
        expandHitTarget: false,
        builder: builder,
      );

  Widget _underline(BuildContext context) {
    final a = context.aerosColors;
    final height = AerosDensity.of(context).sizes.row;
    return Stack(
      children: [
        // The baseline: the active indicator is drawn over it.
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          height: AerosMetricTokens.borderHairline,
          child: ColoredBox(color: a.borderDefault),
        ),
        Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              _pressable(
                index: i,
                builder: (context, state) {
                  final active = i == selectedIndex;
                  return AerosFocusRing(
                    focused: state.focused,
                    radius: _item,
                    placement: AerosFocusRingPlacement.inset,
                    child: SizedBox(
                      height: height,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
                            child: Text(
                              tabs[i],
                              maxLines: 1,
                              softWrap: false,
                              style: _label(a, active: active, state: state),
                            ),
                          ),
                          if (active)
                            PositionedDirectional(
                              start: 0,
                              end: 0,
                              bottom: 0,
                              height: AerosMetricTokens.borderThick,
                              child: ColoredBox(color: a.fgPrimary),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _segmented(BuildContext context) {
    final a = context.aerosColors;
    const gap = AerosSpacing.s0_5;
    // The track's hairline and inset, and the segment's own hairline, come
    // off the control height.
    final segment =
        AerosControlSize.md.resolveHeight(context) - (AerosMetricTokens.borderHairline * 2 + gap) * 2;
    return Container(
      padding: const EdgeInsets.all(gap),
      decoration: BoxDecoration(
        // A recessed track: darker than the page in dark mode, so the active
        // segment (bgElevated) reads as lifted in both themes.
        color: a.bgInset,
        border: Border.all(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
        borderRadius: _control,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : gap),
              child: _pressable(
                index: i,
                builder: (context, state) {
                  final active = i == selectedIndex;
                  final label = SizedBox(
                    height: segment,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          tabs[i],
                          maxLines: 1,
                          softWrap: false,
                          style: _label(a, active: active, state: state),
                        ),
                      ),
                    ),
                  );
                  return AerosFocusRing(
                    focused: state.focused,
                    radius: _item,
                    placement: AerosFocusRingPlacement.inset,
                    child: active
                        ? AerosSurface(
                            level: AerosSurfaceLevel.raised,
                            radius: _item,
                            color: a.bgElevated,
                            borderColor: a.borderDefault,
                            child: label,
                          )
                        : AerosStateFill(
                            color: AerosStateLayer.resolve(
                              a,
                              a.bgInset,
                              hovered: state.hovered,
                              pressed: state.pressed,
                            ),
                            radius: _item,
                            child: label,
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // Arrow keys move the selection while focus is anywhere inside the strip.
    return FocusTraversalGroup(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(rtl ? 1 : -1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(rtl ? -1 : 1),
        },
        child: variant == AerosTabVariant.underline ? _underline(context) : _segmented(context),
      ),
    );
  }
}
