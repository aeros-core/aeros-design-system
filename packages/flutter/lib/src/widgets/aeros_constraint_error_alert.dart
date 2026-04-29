import 'package:flutter/material.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';

/// Locale-aware constraint-violation alert for v1 literal and v2 JSONLogic
/// constraints.
///
/// The backend stores the message as a JSONB locale map, e.g.
/// `{"en":"Custom Pantone requires GSM ≥ 250.","hi":"कस्टम पैंटोन …"}`.
/// Pass it as [messageByLocale] and the picked [locale]; the widget falls
/// back to [fallbackLocale] (default `'en'`) and finally to the first
/// available entry.
class AerosConstraintErrorAlert extends StatelessWidget {
  const AerosConstraintErrorAlert({
    super.key,
    required this.messageByLocale,
    required this.locale,
    this.title,
    this.severity = AerosSeverity.error,
    this.fallbackLocale = 'en',
    this.onDismiss,
    this.onResolve,
    this.resolveLabel,
  });

  final Map<String, String> messageByLocale;
  final String locale;

  /// Optional override title; if null, defaults to a severity-appropriate
  /// localized title (currently English-only — pass [title] for full i18n).
  final String? title;

  final AerosSeverity severity;
  final String fallbackLocale;

  final VoidCallback? onDismiss;

  /// Optional inline action (e.g. "Pick a thicker paper") that re-opens the
  /// offending input.
  final VoidCallback? onResolve;
  final String? resolveLabel;

  String _resolve() {
    final m = messageByLocale;
    if (m.containsKey(locale)) return m[locale]!;
    if (m.containsKey(fallbackLocale)) return m[fallbackLocale]!;
    if (m.isNotEmpty) return m.values.first;
    return '';
  }

  String _title() {
    if (title != null) return title!;
    switch (severity) {
      case AerosSeverity.info:
        return 'Heads up';
      case AerosSeverity.warn:
        return 'Check this';
      case AerosSeverity.error:
        return 'Not allowed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _resolve();
    if (body.isEmpty) return const SizedBox.shrink();
    final palette = AerosSeverityPalette.of(severity);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AerosSpacing.s4,
        AerosSpacing.s3,
        AerosSpacing.s3,
        AerosSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AerosRadii.brLg,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(palette.icon, size: 18, color: palette.foreground),
          const SizedBox(width: AerosSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title(),
                  style: AerosTypography.bodySm(color: palette.foreground)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AerosTypography.caption(color: palette.foreground),
                ),
                if (onResolve != null && resolveLabel != null) ...[
                  const SizedBox(height: AerosSpacing.s2),
                  TextButton(
                    onPressed: onResolve,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      resolveLabel!,
                      style: AerosTypography.bodySm(color: palette.foreground)
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              tooltip: 'Dismiss',
              icon: Icon(Icons.close, size: 16, color: palette.foreground),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
