import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

/// A scrolling gallery page: an [AerosPageHeader] over a column of
/// [Section]s, centred and capped at the content width.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.summary,
    required this.children,
    this.breadcrumbs,
    this.actions,
  });

  final String title;
  final String summary;
  final List<AerosBreadcrumbItem>? breadcrumbs;
  final List<Widget>? actions;
  final List<Widget> children;

  /// The page gutter: tighter on a phone.
  static double gutterOf(BuildContext context) =>
      const AerosResponsiveValue<double>(xs: AerosSpacing.s4, md: AerosSpacing.s8).resolve(context);

  @override
  Widget build(BuildContext context) {
    final gutter = gutterOf(context);
    // AerosPageHeader keeps its actions beside the title. On a phone there is
    // no room for both, so they go on a row of their own under the header.
    final wide = AerosBreakpoints.isAtLeast(context, AerosBreakpoint.md);
    final actions = this.actions;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(gutter, AerosSpacing.s3, gutter, AerosSpacing.s16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AerosMetricTokens.layoutDialogXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AerosPageHeader(
                title: title,
                subtitle: summary,
                breadcrumbs: breadcrumbs,
                actions: wide ? actions : null,
                padding: EdgeInsets.zero,
              ),
              if (!wide && actions != null) ...[
                const SizedBox(height: AerosSpacing.s2),
                Wrap(spacing: AerosSpacing.s2, runSpacing: AerosSpacing.s2, children: actions),
              ],
              const SizedBox(height: AerosSpacing.s6),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled block of a page. [note] is one line on when to use what it shows.
class Section extends StatelessWidget {
  const Section(this.title, {super.key, this.note, required this.child});

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AerosSpacing.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(title, style: AerosTypography.h3(color: a.fgPrimary))),
          if (note != null) ...[
            const SizedBox(height: AerosSpacing.s0_5),
            Text(note!, style: AerosTypography.bodySm(color: a.fgSecondary)),
          ],
          const SizedBox(height: AerosSpacing.s4),
          child,
        ],
      ),
    );
  }
}

/// Examples side by side, wrapping when they run out of room.
class Examples extends StatelessWidget {
  const Examples({super.key, required this.children, this.spacing = AerosSpacing.s3});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: spacing,
        runSpacing: spacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
}

/// Examples stacked, each no wider than [maxWidth] — for fields and other
/// things that fill the width they are given.
class Stacked extends StatelessWidget {
  const Stacked({
    super.key,
    required this.children,
    this.maxWidth = AerosMetricTokens.layoutDialogSm,
    this.spacing = AerosSpacing.s5,
  });

  final List<Widget> children;
  final double maxWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          ),
        ),
      );
}

/// Tiles of equal width that take their own height: as many columns as fit
/// at [minWidth]. (`AerosResponsiveGrid` is for tiles of a fixed aspect ratio.)
class Tiles extends StatelessWidget {
  const Tiles({
    super.key,
    required this.children,
    this.minWidth = 260,
    this.spacing = AerosSpacing.s3,
    this.equalHeights = false,
  });

  final List<Widget> children;
  final double minWidth;
  final double spacing;

  /// Makes the tiles of a row as tall as the tallest — for rows of cards.
  final bool equalHeights;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = ((constraints.maxWidth + spacing) / (minWidth + spacing)).floor().clamp(1, children.length);
          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          if (equalHeights) {
            return Column(
              children: [
                for (var start = 0; start < children.length; start += columns) ...[
                  if (start > 0) SizedBox(height: spacing),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = start; i < start + columns; i++) ...[
                          if (i > start) SizedBox(width: spacing),
                          // An empty cell keeps the last row's tiles the same width.
                          Expanded(child: i < children.length ? children[i] : const SizedBox.shrink()),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          }
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [for (final child in children) SizedBox(width: width.floorToDouble(), child: child)],
          );
        },
      );
}

/// A caption under an example.
class Captioned extends StatelessWidget {
  const Captioned(this.caption, {super.key, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: AerosSpacing.s1_5),
          Text(caption, style: AerosTypography.caption(color: context.aerosColors.fgMuted)),
        ],
      );
}

/// A control with its label beside it — for checkboxes, radios and switches,
/// which draw no label of their own.
class LabelledControl extends StatelessWidget {
  const LabelledControl(this.label, {super.key, required this.control, this.enabled = true});

  final String label;
  final Widget control;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        const SizedBox(width: AerosSpacing.s2),
        Flexible(child: Text(label, style: AerosTypography.bodySm(color: enabled ? a.fgPrimary : a.fgDisabled))),
      ],
    );
  }
}
