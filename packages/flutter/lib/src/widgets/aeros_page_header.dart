import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_breadcrumb.dart';

/// Compound page header used at the top of every admin screen.
/// Composes: optional breadcrumbs row, then a title row (leading +
/// title + subtitle + action buttons).
///
/// The title row is at least one app header high ([AerosSizeTokens.header]
/// for the density — the height of `AerosTopnav` and of the sidenav's header
/// block), with the title centred in it. With the default padding (horizontal
/// only) a page header at the top of the content therefore sits level with
/// the rail's header beside it.
///
/// ```dart
/// AerosPageHeader(
///   breadcrumbs: [
///     AerosBreadcrumbItem('Home', onTap: ...),
///     AerosBreadcrumbItem('Masters', onTap: ...),
///     AerosBreadcrumbItem('Industries'),
///   ],
///   title: 'Industries',
///   subtitle: 'Manage the industries available to organisations',
///   actions: [
///     AerosButton(label: 'Export', onPressed: ..., variant: AerosButtonVariant.secondary),
///     AerosButton(label: 'Add', onPressed: ...),
///   ],
/// );
/// ```
class AerosPageHeader extends StatelessWidget {
  const AerosPageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.breadcrumbs,
    this.leading,
    this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: AerosSpacing.s4),
  }) : assert(title != null || titleWidget != null, 'Provide either title or titleWidget');

  /// Title string. If you need richer content, use [titleWidget] instead.
  final String? title;

  /// Custom title widget. Takes precedence over [title].
  final Widget? titleWidget;

  /// One-line description shown below the title.
  final String? subtitle;

  /// Custom subtitle widget. Takes precedence over [subtitle].
  final Widget? subtitleWidget;

  /// Optional breadcrumb trail rendered above the title row.
  final List<AerosBreadcrumbItem>? breadcrumbs;

  /// Optional widget shown to the left of the title (e.g. back button).
  final Widget? leading;

  /// Right-aligned action buttons.
  final List<Widget>? actions;

  /// Around the header. Horizontal only by default: the title row brings its
  /// own height.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    final titleNode = titleWidget ??
        Semantics(
          header: true,
          child: Text(title!, style: AerosTypography.h2(color: a.fgPrimary)),
        );

    final subtitleNode = subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                style: AerosTypography.bodySm(color: a.fgSecondary),
              )
            : null);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: AerosSpacing.s2),
              child: AerosBreadcrumb(items: breadcrumbs!),
            ),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: AerosDensity.of(context).sizes.header),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AerosSpacing.s3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      titleNode,
                      if (subtitleNode != null) subtitleNode,
                    ],
                  ),
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(width: AerosSpacing.s4),
                  Wrap(
                    spacing: AerosSpacing.s2,
                    runSpacing: AerosSpacing.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
