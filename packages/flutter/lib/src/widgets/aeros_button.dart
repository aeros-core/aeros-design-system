import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';

/// 3.0: `danger` is the solid destructive button; `dangerSubtle` carries the
/// tinted look `danger` had before. 2.0: `dark` was removed (same as `primary`).
enum AerosButtonVariant { primary, secondary, ghost, danger, dangerSubtle, link }

/// 3.0: buttons and fields share one size ladder.
@Deprecated('Use AerosControlSize')
typedef AerosButtonSize = AerosControlSize;

/// A button.
///
/// Flat at rest and in every state: no shadow, no lift, no ripple. Hover and
/// press change the fill only; keyboard focus draws the [AerosFocusRing].
/// Height comes from the size ladder ([AerosControlSize]) and the input
/// density, the radius is [AerosShapeTokens.control] at every size.
class AerosButton extends StatefulWidget {
  const AerosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AerosButtonVariant.primary,
    this.size,
    this.leading,
    this.trailing,
    this.loading = false,
    this.fullWidth = false,
  }) : _iconOnly = false;

  /// A square, icon-only button. [semanticLabel] is what a screen reader
  /// announces — there is no visible text, so it is required.
  const AerosButton.icon({
    super.key,
    required Widget icon,
    required String semanticLabel,
    required this.onPressed,
    this.variant = AerosButtonVariant.ghost,
    this.size,
    this.loading = false,
  })  : label = semanticLabel,
        leading = icon,
        trailing = null,
        fullWidth = false,
        _iconOnly = true;

  factory AerosButton.primary({Key? key, required String label, required VoidCallback? onPressed, Widget? leading, AerosControlSize? size}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, leading: leading, size: size);

  factory AerosButton.secondary({Key? key, required String label, required VoidCallback? onPressed, Widget? leading, AerosControlSize? size}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, leading: leading, size: size, variant: AerosButtonVariant.secondary);

  factory AerosButton.ghost({Key? key, required String label, required VoidCallback? onPressed, AerosControlSize? size}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, size: size, variant: AerosButtonVariant.ghost);

  factory AerosButton.danger({Key? key, required String label, required VoidCallback? onPressed, AerosControlSize? size}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, size: size, variant: AerosButtonVariant.danger);

  /// The visible label; for [AerosButton.icon], the screen-reader label.
  final String label;
  final VoidCallback? onPressed;
  final AerosButtonVariant variant;

  /// Null takes the size from the nearest [AerosControlSizeScope] (md).
  final AerosControlSize? size;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool fullWidth;
  final bool _iconOnly;

  @override
  State<AerosButton> createState() => _AerosButtonState();
}

class _AerosButtonState extends State<AerosButton> {
  /// Resolves fill, label and border colours for the variant and state.
  ({Color bg, Color fg, Color? border}) _colors(
    AerosAliasColors a,
    AerosSemanticColors s,
    AerosInteraction state,
  ) {
    final active = state.hovered || state.pressed;
    Color layer(Color base) =>
        AerosStateLayer.resolve(a, base, hovered: state.hovered, pressed: state.pressed, enabled: state.enabled);

    switch (widget.variant) {
      case AerosButtonVariant.primary:
        // The state overlays are ink over a light surface and vanish on the
        // solid brand fill, so the solid variants swap to their hover colour.
        return (bg: active ? a.brandPrimaryHover : a.brandPrimary, fg: a.fgInverse, border: null);
      case AerosButtonVariant.secondary:
        return (bg: layer(a.bgSurface), fg: a.fgPrimary, border: a.borderStrong);
      case AerosButtonVariant.ghost:
        return (bg: layer(Colors.transparent), fg: a.fgPrimary, border: null);
      case AerosButtonVariant.danger:
        return (bg: active ? s.dangerHover : s.danger, fg: a.fgInverse, border: null);
      case AerosButtonVariant.dangerSubtle:
        return (bg: layer(s.dangerBg), fg: s.dangerText, border: s.dangerBorder);
      case AerosButtonVariant.link:
        return (bg: Colors.transparent, fg: a.brandPrimary, border: null);
    }
  }

  bool get _isDanger =>
      widget.variant == AerosButtonVariant.danger || widget.variant == AerosButtonVariant.dangerSubtle;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final semantic = context.aerosSemantic;
    final size = widget.size ?? AerosControlSize.of(context);
    final height = size.resolveHeight(context);
    final disabled = widget.onPressed == null || widget.loading;
    final iconOnly = widget._iconOnly;

    return AerosPressable(
      onPressed: disabled ? null : widget.onPressed,
      // The label is announced once: from the visible text, or — for a
      // loading or icon-only button — from this label, with the subtree's own
      // semantics dropped.
      semanticLabel: widget.loading
          ? '${widget.label}, loading'
          : iconOnly
              ? widget.label
              : null,
      excludeSemantics: widget.loading || iconOnly,
      builder: (context, state) {
        final c = _colors(a, semantic, state);
        final underline = widget.variant == AerosButtonVariant.link && (state.hovered || state.pressed);
        final labelStyle = size.labelStyle(color: c.fg).copyWith(
              decoration: underline ? TextDecoration.underline : TextDecoration.none,
              decorationColor: c.fg,
            );

        final spinner = SizedBox.square(
          dimension: size.iconSize,
          child: CircularProgressIndicator(strokeWidth: AerosMetricTokens.borderThick, color: c.fg),
        );

        // IconTheme gives leading / trailing icons the resolved foreground
        // and the size's glyph size; an Icon with its own colour still wins.
        final content = IconTheme.merge(
          data: IconThemeData(color: c.fg, size: size.iconSize),
          child: iconOnly
              ? Center(child: widget.loading ? spinner : widget.leading)
              : Row(
                  mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.loading) ...[
                      spinner,
                      SizedBox(width: size.gap),
                    ] else if (widget.leading != null) ...[
                      widget.leading!,
                      SizedBox(width: size.gap),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: labelStyle,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      SizedBox(width: size.gap),
                      widget.trailing!,
                    ],
                  ],
                ),
        );

        final fill = AerosStateFill(
          color: c.bg,
          borderColor: c.border,
          radius: size.radius,
          constraints: iconOnly
              ? BoxConstraints.tightFor(width: height, height: height)
              : BoxConstraints(minHeight: height),
          // The hairline is part of the box, so it comes off the padding and
          // every variant is the same width for the same label.
          padding: iconOnly
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: size.padH - AerosMetricTokens.borderHairline),
          child: content,
        );

        return Opacity(
          opacity: disabled ? AerosMetricTokens.opacityDisabled : 1,
          child: AerosFocusRing(
            focused: state.focused,
            radius: size.radius,
            tone: _isDanger ? AerosFocusRingTone.danger : AerosFocusRingTone.neutral,
            child: fill,
          ),
        );
      },
    );
  }
}
