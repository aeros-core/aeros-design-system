import 'package:flutter/material.dart';
import '../tokens/motion.dart';

/// Themed tooltip (visuals come from `AerosTheme.tooltipTheme`). Long-press on
/// touch, hover on desktop/web; the message is exposed to assistive tech.
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
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      waitDuration: AerosMotion.slow,
      child: child,
    );
  }
}
