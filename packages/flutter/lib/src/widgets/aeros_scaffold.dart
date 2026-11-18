import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/aeros_viewport_scope.dart';
import '../tokens/breakpoints.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_sidenav.dart';

/// Wraps a [Scaffold] with optional [AerosTopnav] and [AerosSidenav], styled
/// from Aeros tokens.
///
/// The sidenav sits inline, behind a 1px hairline, from the `md` breakpoint up
/// ([AerosBreakpoints.md], 768) and moves into a drawer below it. The width
/// that decides is the real viewport width: an [AerosViewportScope] above the
/// scaffold wins over `MediaQuery`, exactly as for [AerosBreakpoints.of].
///
/// Inline it is [sidenavWidth] wide ([AerosMetricTokens.layoutSidebar], 240) —
/// or [AerosMetricTokens.layoutSidebarRail] (56) when the sidenav is
/// [AerosSidenav.collapsed]. The drawer is
/// [AerosMetricTokens.layoutSidebarMobile] wide and always shows the full rail.
///
/// The top bar is one app header high ([AerosSizeTokens.header] for the
/// density: 48 for a mouse, 56 for fingers) — the same height as the sidenav's
/// header block, so the two line up.
class AerosScaffold extends StatelessWidget {
  const AerosScaffold({
    super.key,
    required this.body,
    this.topnav,
    this.sidenav,
    this.floatingActionButton,
    this.sidenavBreakpoint = AerosBreakpoints.md,
    this.sidenavWidth = AerosMetricTokens.layoutSidebar,
    this.backgroundColor,
  });

  final Widget body;
  final AerosTopnav? topnav;
  final AerosSidenav? sidenav;
  final FloatingActionButton? floatingActionButton;

  /// The viewport width from which the sidenav is inline. Defaults to the
  /// `md` breakpoint token.
  final double sidenavBreakpoint;

  /// Width of the inline, expanded sidenav.
  final double sidenavWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    // The same lookup as AerosBreakpoints.of: a web shell that clamps
    // MediaQuery to a phone width publishes the real width in a scope.
    final width = AerosViewportScope.of(context)?.width ?? MediaQuery.sizeOf(context).width;
    final sidenav = this.sidenav;
    final inline = sidenav != null && width >= sidenavBreakpoint;
    final drawer = sidenav != null && !inline;
    final topnav = this.topnav;

    return Scaffold(
      backgroundColor: backgroundColor ?? a.bgCanvas,
      appBar: topnav == null
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(topnav.height ?? AerosDensity.of(context).sizes.header),
              child: topnav,
            ),
      drawer: drawer
          ? Drawer(
              width: AerosMetricTokens.layoutSidebarMobile,
              backgroundColor: a.bgSurface,
              // A sheet over a scrim: square, and flat like every surface.
              elevation: 0,
              shape: const RoundedRectangleBorder(),
              child: AerosSidenavExpanded(child: sidenav),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: inline
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: sidenav.collapsed ? AerosMetricTokens.layoutSidebarRail : sidenavWidth,
                  decoration: BoxDecoration(
                    color: a.bgSurface,
                    border: BorderDirectional(
                      end: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
                    ),
                  ),
                  child: sidenav,
                ),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

/// Application top bar — title on the left, optional trailing actions.
///
/// A `bgSurface` bar over a 1px hairline, one app header high
/// ([AerosSizeTokens.header] for the density) with an `h4` title.
class AerosTopnav extends StatelessWidget implements PreferredSizeWidget {
  const AerosTopnav({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.height,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;

  /// Null (the default) is the header height for the nearest
  /// [AerosDensityScope].
  final double? height;
  final Color? backgroundColor;

  /// Without a build context the density is unknown: this is the explicit
  /// [height], or the touch header height. [AerosScaffold] sizes the bar for
  /// the actual density.
  @override
  Size get preferredSize => Size.fromHeight(height ?? AerosSizeTokens.touch.header);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final height = this.height ?? AerosDensity.of(context).sizes.header;
    return Material(
      color: backgroundColor ?? a.bgSurface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline),
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AerosSpacing.s3),
              ],
              Expanded(
                child: titleWidget ??
                    Semantics(
                      header: true,
                      child: Text(
                        title ?? '',
                        style: AerosTypography.h4(color: a.fgPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
