import 'package:flutter/material.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/states.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

/// Pill that surfaces one [AerosRoutingSignal] from the
/// `cart.preview.routing_signals` array. Severity drives colour; the icon is
/// inferred from severity but can be overridden via [iconOverride].
///
/// For multiple signals, render a [Wrap] of these.
class AerosRoutingSignalBadge extends StatelessWidget {
  const AerosRoutingSignalBadge({
    super.key,
    required this.signal,
    this.iconOverride,
    this.dense = false,
    this.onTap,
  });

  final AerosRoutingSignal signal;

  /// Override the auto-picked icon (info / warning / error).
  final IconData? iconOverride;

  /// `true` ⇒ smaller pill suitable for inline use next to a button.
  final bool dense;

  /// Tap callback (e.g. open a sheet with the [AerosRoutingSignal.detail]).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AerosSeverityPalette.of(_mapSeverity(signal.severity));
    final pad = dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(
            horizontal: AerosSpacing.s3,
            vertical: 6,
          );

    final pill = Container(
      padding: pad,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AerosRadii.brSm,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconOverride ?? palette.icon,
            size: dense ? 12 : 14,
            color: palette.foreground,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              signal.label,
              style: AerosTypography.caption(color: palette.foreground)
                  .copyWith(
                    fontSize: dense ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AerosRadii.brSm,
        child: pill,
      ),
    );
  }

  AerosSeverity _mapSeverity(AerosRoutingSeverity s) {
    switch (s) {
      case AerosRoutingSeverity.info:
        return AerosSeverity.info;
      case AerosRoutingSeverity.warn:
        return AerosSeverity.warn;
      case AerosRoutingSeverity.error:
        return AerosSeverity.error;
    }
  }
}
