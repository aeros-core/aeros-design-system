import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AerosSnackbarTone { neutral, success, warning, danger }

/// Themed snackbars: `AerosSnackbar.show(context, 'Saved')`.
/// Base visuals come from `AerosTheme.snackBarTheme` (inverse surface,
/// floating); tones add a leading status icon.
class AerosSnackbar {
  AerosSnackbar._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    AerosSnackbarTone tone = AerosSnackbarTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final a = context.aerosColors;
    // Icons sit on the inverse surface, so the DARK status set reads correctly
    // in light mode and vice versa.
    final s = AerosSemanticColors.resolve(!context.aeros.isDark);
    final (icon, iconColor) = switch (tone) {
      AerosSnackbarTone.neutral => (null, null),
      AerosSnackbarTone.success => (Icons.check_circle_outline, s.success),
      AerosSnackbarTone.warning => (Icons.warning_amber_outlined, s.warning),
      AerosSnackbarTone.danger => (Icons.error_outline, s.danger),
    };
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(message, style: AerosTypography.bodySm(color: a.fgInverse)),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: a.bgSurface, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }
}
