import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/radii.dart';
import '../tokens/typography.dart';

/// 2.0: tones renamed to intent (was blue/grey/dark).
enum AerosTagTone { info, neutral, inverse }

class AerosTag extends StatelessWidget {
  const AerosTag({
    super.key,
    required this.label,
    this.tone = AerosTagTone.neutral,
    this.onRemove,
    this.pill = false,
  });

  final String label;
  final AerosTagTone tone;

  /// When non-null the chip renders a trailing close affix and the whole chip
  /// becomes tappable to remove it (used by [AerosTagField]).
  final VoidCallback? onRemove;

  /// Fully-rounded ("pill") shape instead of the default [AerosRadii.brMd].
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    Color bg, fg;
    Color? borderColor;
    switch (tone) {
      case AerosTagTone.info:
        bg = a.brandPrimaryMuted;
        fg = a.fgPrimary;
        break;
      case AerosTagTone.neutral:
        bg = a.bgSubtle;
        fg = a.fgSecondary;
        borderColor = a.borderDefault;
        break;
      case AerosTagTone.inverse:
        bg = a.bgInverse;
        fg = a.fgInverse;
        break;
    }

    final removable = onRemove != null;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AerosTypography.labelXs(color: fg)),
        if (removable) ...[
          const SizedBox(width: 4),
          Icon(Icons.close, size: 12, color: fg.withValues(alpha: 0.7)),
        ],
      ],
    );

    final container = Container(
      padding: EdgeInsets.fromLTRB(pill ? 9 : 8, 2, removable ? 6 : (pill ? 9 : 8), 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: pill ? AerosRadii.brFull : AerosRadii.brMd,
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: child,
    );

    if (!removable) return container;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRemove,
      child: container,
    );
  }
}
