import 'package:flutter/widgets.dart';
import '../tokens/breakpoints.dart';
import '../tokens/spacing.dart';

/// Side-by-side primary/aside layout that collapses to stacked columns
/// below [breakpoint].
///
/// Use for detail pages where desktop should show primary content next
/// to a metadata sidebar (status, timeline, related actions), and
/// mobile should fall back to vertical stacking.
///
/// ```dart
/// AerosTwoColumn(
///   primary: OrderItems(...),
///   aside:   OrderStatusPanel(...),
/// )
/// ```
class AerosTwoColumn extends StatelessWidget {
  const AerosTwoColumn({
    super.key,
    required this.primary,
    required this.aside,
    this.breakpoint = AerosBreakpoint.md,
    this.primaryFlex = 2,
    this.asideFlex = 1,
    this.gap = AerosSpacing.s6,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.asideFirst = false,
  });

  final Widget primary;
  final Widget aside;

  /// Below this breakpoint, primary and aside stack vertically.
  final AerosBreakpoint breakpoint;

  final int primaryFlex;
  final int asideFlex;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  /// On desktop, render `aside` to the left of `primary`.
  /// On mobile (stacked), aside still appears below primary unless
  /// `asideFirst` is true.
  final bool asideFirst;

  @override
  Widget build(BuildContext context) {
    final wide = AerosBreakpoints.isAtLeast(context, breakpoint);
    if (!wide) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: asideFirst
            ? [aside, SizedBox(height: gap), primary]
            : [primary, SizedBox(height: gap), aside],
      );
    }
    final left = Expanded(
        flex: asideFirst ? asideFlex : primaryFlex,
        child: asideFirst ? aside : primary);
    final right = Expanded(
        flex: asideFirst ? primaryFlex : asideFlex,
        child: asideFirst ? primary : aside);
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [left, SizedBox(width: gap), right],
    );
  }
}
