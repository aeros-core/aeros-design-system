import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

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
    this.sidenavWidth = 260,
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

/// Single navigation entry — leaf or expandable parent.
class AerosNavItem {
  const AerosNavItem({
    required this.label,
    this.icon,
    this.children,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final List<AerosNavItem>? children;
  final VoidCallback? onTap;
  final bool selected;

  bool get hasChildren => children != null && children!.isNotEmpty;
}

/// Vertical navigation panel rendered inline on wide layouts or inside a Drawer.
class AerosSidenav extends StatelessWidget {
  const AerosSidenav({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.symmetric(vertical: AerosSpacing.s4),
  });

  final List<AerosNavItem> items;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Container(
      color: a.bgSurface,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: padding,
              children: [
                for (final item in items) _NavEntry(item: item, depth: 0),
              ],
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _NavEntry extends StatefulWidget {
  const _NavEntry({required this.item, required this.depth});

  final AerosNavItem item;
  final int depth;

  @override
  State<_NavEntry> createState() => _NavEntryState();
}

class _NavEntryState extends State<_NavEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final indent = AerosSpacing.s4 + widget.depth * AerosSpacing.s5;
    final item = widget.item;

    if (!item.hasChildren) {
      return InkWell(
        onTap: item.onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            indent,
            AerosSpacing.s3,
            AerosSpacing.s4,
            AerosSpacing.s3,
          ),
          color: item.selected ? a.brandPrimaryMuted : Colors.transparent,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18, color: a.fgPrimary),
                const SizedBox(width: AerosSpacing.s3),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: AerosTypography.bodyMd(color: a.fgPrimary).copyWith(
                    fontWeight: item.selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              indent,
              AerosSpacing.s3,
              AerosSpacing.s4,
              AerosSpacing.s3,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18, color: a.fgPrimary),
                  const SizedBox(width: AerosSpacing.s3),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: AerosTypography.bodyMd(color: a.fgPrimary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: a.fgPrimary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final child in item.children!)
            _NavEntry(item: child, depth: widget.depth + 1),
      ],
    );
  }
}
