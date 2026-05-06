import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosButtonVariant { primary, secondary, ghost, danger, dark, link }
enum AerosButtonSize { xs, sm, md, lg, xl }

class AerosButton extends StatefulWidget {
  const AerosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AerosButtonVariant.primary,
    this.size = AerosButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.fullWidth = false,
  });

  factory AerosButton.primary({Key? key, required String label, required VoidCallback? onPressed, Widget? leading, AerosButtonSize size = AerosButtonSize.md}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, leading: leading, size: size);

  factory AerosButton.secondary({Key? key, required String label, required VoidCallback? onPressed, Widget? leading, AerosButtonSize size = AerosButtonSize.md}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, leading: leading, size: size, variant: AerosButtonVariant.secondary);

  factory AerosButton.ghost({Key? key, required String label, required VoidCallback? onPressed, AerosButtonSize size = AerosButtonSize.md}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, size: size, variant: AerosButtonVariant.ghost);

  factory AerosButton.danger({Key? key, required String label, required VoidCallback? onPressed, AerosButtonSize size = AerosButtonSize.md}) =>
      AerosButton(key: key, label: label, onPressed: onPressed, size: size, variant: AerosButtonVariant.danger);

  final String label;
  final VoidCallback? onPressed;
  final AerosButtonVariant variant;
  final AerosButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool fullWidth;

  @override
  State<AerosButton> createState() => _AerosButtonState();
}

class _AerosButtonState extends State<AerosButton> {
  bool _focused = false;

  EdgeInsets get _padding {
    switch (widget.size) {
      case AerosButtonSize.xs: return const EdgeInsets.symmetric(horizontal: 11, vertical: 5);
      case AerosButtonSize.sm: return const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
      case AerosButtonSize.md: return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case AerosButtonSize.lg: return const EdgeInsets.symmetric(horizontal: 26, vertical: 13);
      case AerosButtonSize.xl: return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AerosButtonSize.xs: return 11;
      case AerosButtonSize.sm: return 12;
      case AerosButtonSize.md: return 14;
      case AerosButtonSize.lg: return 15;
      case AerosButtonSize.xl: return 16;
    }
  }

  BorderRadius get _radius {
    switch (widget.size) {
      case AerosButtonSize.xs:
      case AerosButtonSize.sm: return AerosRadii.brSm;
      case AerosButtonSize.md: return AerosRadii.brMd;
      case AerosButtonSize.lg:
      case AerosButtonSize.xl: return AerosRadii.brLg;
    }
  }

  ({Color bg, Color fg, Color? border}) _colors(AerosAliasColors a) {
    switch (widget.variant) {
      case AerosButtonVariant.primary:
        return (bg: a.brandPrimary, fg: Colors.white, border: null);
      case AerosButtonVariant.secondary:
        return (bg: a.bgSurface, fg: a.fgPrimary, border: a.borderDefault);
      case AerosButtonVariant.ghost:
        return (bg: Colors.transparent, fg: a.fgPrimary, border: a.borderDefault);
      case AerosButtonVariant.danger:
        return (bg: AerosColors.dangerBg, fg: AerosColors.dangerText, border: AerosColors.dangerBorder);
      case AerosButtonVariant.dark:
        return (bg: AerosColors.ink900, fg: Colors.white, border: null);
      case AerosButtonVariant.link:
        return (bg: Colors.transparent, fg: a.brandPrimary, border: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final c = _colors(a);
    final disabled = widget.onPressed == null || widget.loading;

    final content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: _fontSize, height: _fontSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.fg),
          )
        else if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
        Text(widget.label, style: AerosTypography.bodyMd(color: c.fg).copyWith(fontSize: _fontSize, fontWeight: FontWeight.w600)),
        if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
      ],
    );

    // Visible focus ring: 2px brandPrimary outline (a.borderFocus) when
    // the button is keyboard-focused. Native hover ripple from Material
    // InkWell is preserved untouched so mouse interaction is unchanged.
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: c.bg,
        borderRadius: _radius,
        child: InkWell(
          onTap: disabled ? null : widget.onPressed,
          borderRadius: _radius,
          splashColor: Colors.white.withValues(alpha: 0.1),
          onFocusChange: (focused) {
            if (_focused != focused) setState(() => _focused = focused);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            padding: _padding,
            decoration: BoxDecoration(
              borderRadius: _radius,
              border: _focused
                  ? Border.all(color: a.borderFocus, width: 2)
                  : (c.border != null ? Border.all(color: c.border!) : null),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
