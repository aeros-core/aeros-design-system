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
                // Beside the title where they fit, under it where they do not.
                actions: actions,
                padding: EdgeInsets.zero,
              ),
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
