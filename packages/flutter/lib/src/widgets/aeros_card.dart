import 'package:flutter/material.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 3.0: every card is flat — a fill and a 1px hairline, no shadow. Shadows
/// belong to floating layers only (see `AerosSurface`).
enum AerosCardVariant {
  flat,

  /// Renders exactly like [flat]; kept so 2.x call sites compile.
  @Deprecated('Cards are flat in 3.0. Remove the variant; for a floating layer use AerosSurface.')
  raised,
}

/// A resting surface: `bgSurface`, a 1px hairline, [AerosShapeTokens.surface]
/// corners and no shadow.
///
/// A header ([title] / [subtitle] / [trailing], or a custom [header]) and a
/// [footer] are separated from the body by hairlines; the footer has no fill
/// of its own.
///
/// With [onTap] the whole card is one button: hover and press tint the fill
/// and strengthen the hairline, keyboard focus draws the focus ring. Its
/// content is announced as that one button, so do not put other buttons
/// inside a tappable card.
class AerosCard extends StatelessWidget {
  const AerosCard({
    super.key,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.trailing,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.variant = AerosCardVariant.flat,
    this.semanticLabel,
  });

  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final Widget? trailing;
  final Widget child;

  /// Around [child]. Defaults to [AerosSpacing.s4] on every side.
  final EdgeInsetsGeometry? padding;

  /// When set, the whole card is a button.
  final VoidCallback? onTap;

  /// Surface colour override (defaults to `bgSurface`).
  final Color? color;

  /// No longer changes the look — see [AerosCardVariant].
  final AerosCardVariant variant;

  /// For a tappable card: announced instead of the card's own text.
  final String? semanticLabel;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.surface));
  static const EdgeInsets _blockPadding =
      EdgeInsets.symmetric(horizontal: AerosSpacing.s4, vertical: AerosSpacing.s3);

  Widget _surface(BuildContext context, {bool hovered = false, bool pressed = false}) {
    final a = context.aerosColors;
    final rule = BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline);
    final active = hovered || pressed;
    return AerosSurface(
      radius: _radius,
      color: AerosStateLayer.resolve(a, color ?? a.bgSurface, hovered: hovered, pressed: pressed),
      borderColor: active ? a.borderStrong : a.borderDefault,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null || title != null)
            Container(
              padding: _blockPadding,
              decoration: BoxDecoration(border: Border(bottom: rule)),
              child: header ??
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title!, style: AerosTypography.h4(color: a.fgPrimary)),
                            if (subtitle != null) Text(subtitle!, style: AerosTypography.caption(color: a.fgMuted)),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AerosSpacing.s3),
                        trailing!,
                      ],
                    ],
                  ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(AerosSpacing.s4),
            child: child,
          ),
          if (footer != null)
            Container(
              padding: _blockPadding,
              decoration: BoxDecoration(border: Border(top: rule)),
              child: footer,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return _surface(context);
    return AerosPressable(
      onPressed: onTap,
      // A card is far larger than the minimum target, and must keep the size
      // its parent gave it.
      expandHitTarget: false,
      semanticLabel: semanticLabel,
      excludeSemantics: semanticLabel != null,
      builder: (context, state) => AerosFocusRing(
        focused: state.focused,
        radius: _radius,
        child: _surface(context, hovered: state.hovered, pressed: state.pressed),
      ),
    );
  }
}
