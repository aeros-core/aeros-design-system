import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_sidenav.dart';

/// Wraps a [Scaffold] with optional [AerosTopnav] and [AerosSidenav], styled
/// from Aeros tokens. The sidenav renders inline on wide layouts (>= 720px)
/// and as a drawer on narrow layouts.
class AerosScaffold extends StatelessWidget {
  const AerosScaffold({
    super.key,
    required this.body,
    this.topnav,
    this.sidenav,
    this.floatingActionButton,
    this.sidenavBreakpoint = 720,
    this.sidenavWidth = 240,
    this.backgroundColor,
  });

  final Widget body;
  final AerosTopnav? topnav;
  final AerosSidenav? sidenav;
  final FloatingActionButton? floatingActionButton;
  final double sidenavBreakpoint;
  final double sidenavWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final width = MediaQuery.of(context).size.width;
    final inlineSidenav = sidenav != null && width >= sidenavBreakpoint;
    final drawerSidenav = sidenav != null && width < sidenavBreakpoint;

    return Scaffold(
      backgroundColor: backgroundColor ?? a.bgCanvas,
      appBar: topnav == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: topnav!,
            ),
      drawer: drawerSidenav
          ? Drawer(
              backgroundColor: a.bgSurface,
              child: SizedBox(width: sidenavWidth, child: sidenav),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: inlineSidenav
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: sidenavWidth, child: sidenav),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

/// Application top bar — title on the left, optional trailing actions.
class AerosTopnav extends StatelessWidget implements PreferredSizeWidget {
  const AerosTopnav({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.height = 60,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Material(
      color: backgroundColor ?? a.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: a.borderDefault)),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AerosSpacing.s3),
              ],
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      style: AerosTypography.h3(color: a.fgPrimary),
                      overflow: TextOverflow.ellipsis,
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
