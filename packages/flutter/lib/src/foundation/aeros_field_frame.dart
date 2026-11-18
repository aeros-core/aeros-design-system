import 'package:flutter/material.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import 'aeros_control_size.dart';
import 'aeros_focus_ring.dart';
import 'aeros_state_layer.dart';

/// The one field look: a `bgSurface` fill, a 1px `borderStrong` hairline that
/// stays 1px in every state, the control radius, and the focus ring.
///
/// [AerosTextField], [AerosSearchField] and [AerosTagField] all sit in this
/// frame; use it for a composite input that should match them. It is at least
/// the [size]'s height for the nearest density and grows with its content.
class AerosFieldFrame extends StatelessWidget {
  const AerosFieldFrame({
    super.key,
    required this.child,
    this.size = AerosControlSize.md,
    this.focused = false,
    this.hasError = false,
    this.enabled = true,
    this.padding,
    this.onTap,
  });

  final AerosControlSize size;

  /// Draws the focus ring. A text input passes its focus state as is (the
  /// ring shows for pointer focus too).
  final bool focused;

  /// Border and ring take the semantic danger colour.
  final bool hasError;

  /// False dims the whole field to [AerosMetricTokens.opacityDisabled].
  final bool enabled;

  /// Inside the border. Defaults to the size's horizontal padding.
  final EdgeInsetsGeometry? padding;

  /// Tapping the frame (its padding, an affix) — usually focuses the input.
  final VoidCallback? onTap;
  final Widget child;

  /// An [InputDecoration] with no fill, border or padding of its own, for the
  /// `TextField` that sits inside the frame.
  static InputDecoration bareDecoration({String? hintText, TextStyle? hintStyle}) => InputDecoration(
        isCollapsed: true,
        isDense: true,
        filled: false,
        // Explicit: a collapsed decoration still inherits the theme's padding.
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: hintStyle,
        hintMaxLines: 1,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      );

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final semantic = context.aerosSemantic;

    Widget frame = AerosFocusRing(
      focused: focused && enabled,
      radius: size.radius,
      tone: hasError ? AerosFocusRingTone.danger : AerosFocusRingTone.neutral,
      placement: AerosFocusRingPlacement.field,
      child: AerosStateFill(
        color: a.bgSurface,
        borderColor: hasError ? semantic.danger : a.borderStrong,
        radius: size.radius,
        constraints: BoxConstraints(minHeight: size.resolveHeight(context)),
        padding: padding ?? EdgeInsets.symmetric(horizontal: size.padH),
        child: child,
      ),
    );

    if (onTap != null && enabled) {
      frame = MouseRegion(
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: frame,
        ),
      );
    }
    return enabled ? frame : Opacity(opacity: AerosMetricTokens.opacityDisabled, child: frame);
  }
}
