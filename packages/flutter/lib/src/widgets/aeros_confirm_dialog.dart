import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';

/// Reusable confirmation dialog for destructive or otherwise-significant
/// actions. Returns `true` if the user confirms, `false` if they cancel
/// or dismiss.
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
    final result = await showDialog<bool>(
      context: context,
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
    return Dialog(
      backgroundColor: a.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: AerosRadii.brLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          // Long bodies scroll inside the dialog instead of overflowing short
          // viewports.
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AerosSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AerosTypography.h3(color: a.fgPrimary)),
              const SizedBox(height: AerosSpacing.s3),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(body, style: AerosTypography.bodyMd(color: a.fgSecondary)),
                ),
              ),
              const SizedBox(height: AerosSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AerosButton.secondary(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: AerosSpacing.s2),
                  AerosButton(
                    label: confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                    variant: destructive
                        ? AerosButtonVariant.danger
                        : AerosButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
