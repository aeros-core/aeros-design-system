import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';

enum AerosSnackbarTone { neutral, success, warning, danger }

/// Themed snackbars: `AerosSnackbar.show(context, 'Saved')`.
///
/// The same toast as the web: one elevated surface for every tone
/// (`bgElevated` with the overlay shadow, [AerosShapeTokens.surface] corners).
/// The tone colours the icon and the message only — status text never sits on
/// a tinted or inverse slab. An optional [description] line is `caption` in
/// `fgSecondary`; the action is a small secondary button.
class AerosSnackbar {
  AerosSnackbar._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    String? description,
    AerosSnackbarTone tone = AerosSnackbarTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final a = context.aerosColors;
    final s = context.aerosSemantic;
    final (IconData? icon, Color iconColor, Color titleColor) = switch (tone) {
      AerosSnackbarTone.neutral => (null, a.fgPrimary, a.fgPrimary),
      AerosSnackbarTone.success => (Icons.check_circle_outline, s.success, s.successText),
      AerosSnackbarTone.warning => (Icons.warning_amber_outlined, s.warning, s.warningText),
      AerosSnackbarTone.danger => (Icons.error_outline, s.danger, s.dangerText),
    };
    final titleStyle = AerosTypography.labelSm(color: titleColor);
    final messenger = ScaffoldMessenger.of(context);
    return messenger.showSnackBar(
      SnackBar(
        duration: duration,
        // The surface below is the whole look: the SnackBar's own box is
        // transparent, unpadded and unclipped (a clip would cut the shadow).
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        behavior: SnackBarBehavior.floating,
        content: AerosSurface(
          level: AerosSurfaceLevel.overlay,
          padding: const EdgeInsets.all(AerosSpacing.s3),
          child: Row(
            crossAxisAlignment: description == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                SizedBox(
                  height: titleStyle.fontSize! * titleStyle.height!,
                  child: Icon(icon, size: AerosSizeTokens.iconMd, color: iconColor),
                ),
                const SizedBox(width: AerosSpacing.s2),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, style: titleStyle),
                    if (description != null)
                      Text(description, style: AerosTypography.caption(color: a.fgSecondary)),
                  ],
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(width: AerosSpacing.s3),
                AerosButton(
                  label: actionLabel,
                  variant: AerosButtonVariant.secondary,
                  size: AerosControlSize.xs,
                  onPressed: () {
                    messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.action);
                    onAction?.call();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
