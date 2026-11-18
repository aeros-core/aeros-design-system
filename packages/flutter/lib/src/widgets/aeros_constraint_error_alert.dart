import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
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
///
/// Looks like `AerosAlert`: a tinted fill, a 1px border in the severity's
/// border colour, [AerosShapeTokens.surface] corners, a `labelSm` title and a
/// `bodySm` body.
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
    this.dismissLabel = 'Dismiss',
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

  /// Tooltip and screen-reader name of the dismiss button.
  final String dismissLabel;

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
    final a = context.aerosColors;
    final palette = AerosSeverityPalette.of(context, severity);
    final titleStyle = AerosTypography.labelSm(color: palette.foreground);
    const item = BorderRadius.all(Radius.circular(AerosShapeTokens.item));

    return Container(
      padding: const EdgeInsets.all(AerosSpacing.s3 - AerosMetricTokens.borderHairline),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.surface)),
        border: Border.all(color: palette.border, width: AerosMetricTokens.borderHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: titleStyle.fontSize! * titleStyle.height!,
            child: Icon(palette.icon, size: AerosSizeTokens.iconMd, color: palette.foreground),
          ),
          const SizedBox(width: AerosSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_title(), style: titleStyle),
                const SizedBox(height: AerosSpacing.s0_5),
                Text(body, style: AerosTypography.bodySm(color: palette.foreground)),
                if (onResolve != null && resolveLabel != null) ...[
                  const SizedBox(height: AerosSpacing.s1),
                  AerosPressable(
                    onPressed: onResolve,
                    builder: (context, state) => AerosFocusRing(
                      focused: state.focused,
                      radius: item,
                      child: Text(
                        resolveLabel!,
                        style: titleStyle.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: palette.foreground,
                          decorationThickness:
                              state.hovered || state.pressed ? AerosMetricTokens.borderThick : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AerosSpacing.s2),
            AerosPressable(
              onPressed: onDismiss,
              semanticLabel: dismissLabel,
              excludeSemantics: true,
              builder: (context, state) {
                const size = AerosControlSize.xs;
                final side = size.resolveHeight(context);
                return AerosFocusRing(
                  focused: state.focused,
                  radius: size.radius,
                  child: AerosStateFill(
                    color: AerosStateLayer.resolve(
                      a,
                      palette.background,
                      hovered: state.hovered,
                      pressed: state.pressed,
                    ),
                    radius: size.radius,
                    constraints: BoxConstraints.tightFor(width: side, height: side),
                    child: Icon(Icons.close, size: size.iconSize, color: palette.foreground),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
