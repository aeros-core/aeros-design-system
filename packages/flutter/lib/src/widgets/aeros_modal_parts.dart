import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/aeros_control_size.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_button.dart';

/// The header / scrolling body / footer every modal surface shares
/// (`AerosDialog`, `AerosSheet`). Not exported.
///
/// The header holds the title, an optional description and the close button.
/// The close button keeps the density's minimum hit target without making the
/// header taller: only its painted box counts towards the header's height.
/// The body scrolls when it is taller than the space left. The footer is
/// separated by a top hairline and has no fill of its own.
class AerosModalLayout extends StatelessWidget {
  const AerosModalLayout({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions = const <Widget>[],
    this.showClose = true,
    this.scrollable = true,
    this.contentPadding,
    this.top,
    this.fill = false,
  });

  final String? title;
  final String? description;
  final Widget? content;
  final List<Widget> actions;
  final bool showClose;

  /// False hands [content] the remaining height to lay out (and scroll)
  /// itself, with no padding unless [contentPadding] is given.
  final bool scrollable;
  final EdgeInsetsGeometry? contentPadding;

  /// Above the header — a sheet's drag handle.
  final Widget? top;

  /// The body takes all the height left, pinning the footer to the bottom —
  /// for a surface with a fixed height (a side sheet).
  final bool fill;

  static const double _inset = AerosSpacing.s5;

  /// The close button is one small control: its painted box.
  static const AerosControlSize _closeSize = AerosControlSize.sm;

  Widget _header(BuildContext context) {
    final a = context.aerosColors;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Semantics(
            header: true,
            child: Text(title!, style: AerosTypography.h3(color: a.fgPrimary)),
          ),
        if (description != null) ...[
          if (title != null) const SizedBox(height: AerosSpacing.s1),
          Text(description!, style: AerosTypography.bodySm(color: a.fgSecondary)),
        ],
      ],
    );
    if (!showClose) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(_inset, _inset, _inset, AerosSpacing.s3),
        child: text,
      );
    }

    // The header is as tall as its text, and never shorter than the close
    // button's painted box. The button's tappable box is larger at touch
    // density (the minimum target); it is positioned over the header's own
    // padding instead of being laid out in the row, so it adds no height.
    final visual = _closeSize.resolveHeight(context);
    final target = math.max(visual, AerosDensity.of(context).sizes.minTarget);
    final overhang = (target - visual) / 2;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            _inset,
            AerosSpacing.s3,
            AerosSpacing.s3 + visual + AerosSpacing.s2,
            AerosSpacing.s3,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: visual),
            child: Padding(
              // With the close button the header starts higher, so the title
              // is pushed back down to the same place.
              padding: const EdgeInsets.only(top: AerosSpacing.s2),
              child: text,
            ),
          ),
        ),
        PositionedDirectional(
          top: AerosSpacing.s3 - overhang,
          end: AerosSpacing.s3 - overhang,
          child: AerosButton.icon(
            icon: const Icon(Icons.close),
            semanticLabel: MaterialLocalizations.of(context).closeButtonLabel,
            size: _closeSize,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final hasHeader = title != null || description != null || showClose;
    final bodyPadding = contentPadding ??
        (scrollable
            ? EdgeInsets.fromLTRB(_inset, hasHeader ? AerosSpacing.s0 : _inset, _inset, _inset)
            : EdgeInsets.zero);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (top != null) top!,
        if (hasHeader) _header(context),
        if (content == null && fill) const Spacer(),
        if (content != null)
          Flexible(
            fit: fill ? FlexFit.tight : FlexFit.loose,
            child: scrollable
                ? SingleChildScrollView(padding: bodyPadding, child: content)
                : Padding(padding: bodyPadding, child: content),
          ),
        if (actions.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: _inset, vertical: AerosSpacing.s3),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: a.borderDefault, width: AerosMetricTokens.borderHairline)),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: AerosSpacing.s2,
              runSpacing: AerosSpacing.s2,
              children: actions,
            ),
          ),
      ],
    );
  }
}
