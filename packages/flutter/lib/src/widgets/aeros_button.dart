import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

enum AerosButtonVariant { primary, secondary, ghost, danger, dark, link }
enum AerosButtonSize { xs, sm, md, lg, xl }

class AerosButton extends StatelessWidget {
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

  EdgeInsets get _padding {
    switch (size) {
      case AerosButtonSize.xs: return const EdgeInsets.symmetric(horizontal: 11, vertical: 5);
      case AerosButtonSize.sm: return const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
      case AerosButtonSize.md: return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case AerosButtonSize.lg: return const EdgeInsets.symmetric(horizontal: 26, vertical: 13);
      case AerosButtonSize.xl: return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double get _fontSize {
    switch (size) {
      case AerosButtonSize.xs: return 11;
      case AerosButtonSize.sm: return 12;
      case AerosButtonSize.md: return 14;
      case AerosButtonSize.lg: return 15;
      case AerosButtonSize.xl: return 16;
    }
  }

  BorderRadius get _radius {
    switch (size) {
      case AerosButtonSize.xs:
      case AerosButtonSize.sm: return AerosRadii.brSm;
      case AerosButtonSize.md: return AerosRadii.brMd;
      case AerosButtonSize.lg:
      case AerosButtonSize.xl: return AerosRadii.brLg;
    }
  }

  ({Color bg, Color fg, Color? border}) _colors(AerosAliasColors a) {
    switch (variant) {
      case AerosButtonVariant.primary:
        return (bg: a.brandPrimary, fg: Colors.white, border: null);
      case AerosButtonVariant.secondary:
        return (bg: a.bgSurface, fg: a.fgPrimary, border: a.borderDefault);
      case AerosButtonVariant.ghost:
        return (bg: Colors.transparent, fg: a.brandPrimary, border: AerosColors.royal100);
      case AerosButtonVariant.danger:
        return (bg: AerosColors.dangerBg, fg: AerosColors.dangerText, border: AerosColors.dangerBorder);
      case AerosButtonVariant.dark:
        return (bg: AerosColors.slate900, fg: Colors.white, border: null);
      case AerosButtonVariant.link:
        return (bg: Colors.transparent, fg: a.brandPrimary, border: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final c = _colors(a);
    final disabled = onPressed == null || loading;

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: _fontSize, height: _fontSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.fg),
          )
        else if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(label, style: AerosTypography.bodyMd(color: c.fg).copyWith(fontSize: _fontSize, fontWeight: FontWeight.w600)),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: c.bg,
        borderRadius: _radius,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: _radius,
          splashColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              borderRadius: _radius,
              border: c.border != null ? Border.all(color: c.border!) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
