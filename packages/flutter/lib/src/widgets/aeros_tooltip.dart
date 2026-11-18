import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A tooltip: an inverse chip (`bgInverse` / `fgInverse`) with
/// [AerosShapeTokens.item] corners and `caption` text. Long-press on touch,
/// hover on desktop/web; the message is exposed to assistive tech.
///
/// The look is set here as well as in `AerosTheme.tooltipTheme`, so it holds
/// under any theme.
class AerosTooltip extends StatelessWidget {
  const AerosTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
  });

  final String message;
  final Widget child;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: AerosMotion.slow,
      // Material's default is 32 high on touch platforms: far taller than a caption.
      constraints: BoxConstraints(minHeight: AerosSizeTokens.pointer.controlXs),
      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2, vertical: AerosSpacing.s1),
      textStyle: AerosTypography.caption(color: a.fgInverse),
      decoration: BoxDecoration(
        color: a.bgInverse,
        borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.item)),
      ),
      child: child,
    );
  }
}
