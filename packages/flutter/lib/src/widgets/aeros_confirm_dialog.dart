import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';
import 'aeros_dialog.dart';

/// Reusable confirmation dialog for destructive or otherwise-significant
/// actions. Returns `true` if the user confirms, `false` if they cancel
/// or dismiss.
///
/// A small [AerosDialog]: the title, the body (which scrolls when it is long)
/// and a footer with the two buttons. [destructive] makes the confirm button
/// the solid danger button.
///
/// ```dart
/// final ok = await AerosConfirmDialog.show(
///   context,
///   title: 'Delete industry?',
///   body: 'This removes "Construction" from the catalog. Items in this '
///         'industry will be reclassified as "Other".',
///   confirmLabel: 'Delete',
///   destructive: true,
/// );
/// if (ok) bloc.add(IndustryDeleteEvent(id: id));
/// ```
class AerosConfirmDialog extends StatelessWidget {
  const AerosConfirmDialog._({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    /// Set false to force an explicit answer (no scrim-tap / Escape dismiss).
    bool barrierDismissible = true,
  }) async {
    final result = await AerosDialog.show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AerosConfirmDialog._(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return AerosDialog(
      size: AerosDialogSize.sm,
      title: title,
      showClose: false,
      content: Text(body, style: AerosTypography.bodySm(color: a.fgSecondary)),
      actions: [
        AerosButton.secondary(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AerosButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(context).pop(true),
          variant: destructive ? AerosButtonVariant.danger : AerosButtonVariant.primary,
        ),
      ],
    );
  }
}
