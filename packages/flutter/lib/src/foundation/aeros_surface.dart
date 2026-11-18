import 'package:flutter/widgets.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';

/// How far a surface sits above the page.
enum AerosSurfaceLevel {
  /// Resting: a fill and a hairline, no shadow. Cards, panels, list containers.
  flat,

  /// Resting, with the faintest lift ([AerosElevation.raised]) under the hairline.
  raised,

  /// Floating: menus, popovers, tooltips ([AerosElevation.overlay]).
  overlay,

  /// Floating above a scrim: dialogs, sheets ([AerosElevation.modal]).
  modal,
}

/// The one container that knows about elevation.
///
/// Resting surfaces ([AerosSurfaceLevel.flat], [AerosSurfaceLevel.raised]) are
/// `bgSurface` with a 1px hairline. Floating surfaces
/// ([AerosSurfaceLevel.overlay], [AerosSurfaceLevel.modal]) are `bgElevated`
/// with the matching [AerosElevation] shadow, which already draws its own 1px
/// edge — so they take no border. Nothing else in the design system should
/// attach a [BoxShadow].
class AerosSurface extends StatelessWidget {
  const AerosSurface({
    super.key,
    required this.child,
    this.level = AerosSurfaceLevel.flat,
    this.radius,
    this.color,
    this.borderColor,
    this.padding,
    this.clipBehavior = Clip.none,
  });

  final AerosSurfaceLevel level;

  /// Defaults to [AerosShapeTokens.modal] for a modal, [AerosShapeTokens.surface] otherwise.
  final BorderRadius? radius;

  /// Defaults to `bgSurface` at rest and `bgElevated` when floating.
  final Color? color;

  /// Hairline colour of a resting surface (default `borderDefault`). Ignored
  /// when floating — the shadow carries the edge.
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final Widget child;

  bool get _floating => level == AerosSurfaceLevel.overlay || level == AerosSurfaceLevel.modal;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final elevation = context.aerosElevation;
    final shape = radius ??
        BorderRadius.all(Radius.circular(
          level == AerosSurfaceLevel.modal ? AerosShapeTokens.modal : AerosShapeTokens.surface,
        ));
    final shadow = switch (level) {
      AerosSurfaceLevel.flat => null,
      AerosSurfaceLevel.raised => elevation.raised,
      AerosSurfaceLevel.overlay => elevation.overlay,
      AerosSurfaceLevel.modal => elevation.modal,
    };
    return Container(
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color ?? (_floating ? a.bgElevated : a.bgSurface),
        borderRadius: shape,
        border: _floating
            ? null
            : Border.all(color: borderColor ?? a.borderDefault, width: AerosMetricTokens.borderHairline),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
