import 'package:flutter/widgets.dart';

import 'typography.dart';

/// How tightly a surface packs its content, by the pointer that will use it.
///
/// The rule: **[pointer] on desktop web, [touch] on phones and tablets.** A mouse can hit a 28px
/// chip; a thumb needs more, and a desktop window has the room to show twice the rows. WhatsApp
/// Desktop and Apple Mail are the reference for [pointer]; [touch] keeps the phone's type sizes and
/// only tightens line heights.
///
/// Put an [AerosDensityScope] around the surfaces that should change and read the metrics with
/// [AerosDensity.of]. With no scope everything resolves to [touch], so a screen that never opts in
/// renders exactly as before.
///
/// Same vocabulary as [AerosSidenavDensity], which sizes the sidebar rail on its own.
enum AerosDensity {
  /// Mouse and trackpad: 28px controls, 48px header bars, 40px list avatars, 14px titles.
  pointer(
    controlHeight: 28,
    headerHeight: 48,
    rowPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    listAvatar: 40,
    inlineAvatar: 26,
    iconButton: 32,
    iconSize: 18,
    badgeHeight: 18,
    titleSize: 14,
    titleHeight: 1.3,
    bodyHeight: 1.4,
    metaHeight: 1.25,
    labelSize: 12,
  ),

  /// Fingers: 32px controls (with a taller hit area), 56px header bars, 48px list avatars, the
  /// phone's 16px titles.
  touch(
    controlHeight: 32,
    headerHeight: 56,
    rowPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    listAvatar: 48,
    inlineAvatar: 30,
    iconButton: 44,
    iconSize: 22,
    badgeHeight: 20,
    titleSize: 16,
    titleHeight: 1.25,
    bodyHeight: 1.45,
    metaHeight: 1.3,
    labelSize: 13,
  );

  const AerosDensity({
    required this.controlHeight,
    required this.headerHeight,
    required this.rowPadding,
    required this.listAvatar,
    required this.inlineAvatar,
    required this.iconButton,
    required this.iconSize,
    required this.badgeHeight,
    required double titleSize,
    required double titleHeight,
    required double bodyHeight,
    required double metaHeight,
    required double labelSize,
  })  : _titleSize = titleSize,
        _titleHeight = titleHeight,
        _bodyHeight = bodyHeight,
        _metaHeight = metaHeight,
        _labelSize = labelSize;

  /// Chips, segmented filters and other inline controls.
  final double controlHeight;

  /// App bars and pane headers.
  final double headerHeight;

  /// Inside a list row (a conversation, a mail, a record).
  final EdgeInsets rowPadding;

  /// The leading avatar of a list row.
  final double listAvatar;

  /// An avatar set inline with content — beside a chat bubble, in a pane header.
  final double inlineAvatar;

  /// Square icon-only buttons.
  final double iconButton;

  /// Icons in headers and buttons.
  final double iconSize;

  /// Count badges ([AerosCountBadge]).
  final double badgeHeight;

  final double _titleSize;
  final double _titleHeight;
  final double _bodyHeight;
  final double _metaHeight;
  final double _labelSize;

  /// The density of the nearest [AerosDensityScope]; [touch] when there is none.
  static AerosDensity of(BuildContext context) => AerosDensityScope.maybeOf(context) ?? AerosDensity.touch;

  /// Whether a precise pointer is assumed (the mouse sizes).
  bool get isPointer => this == AerosDensity.pointer;

  // ─── The density type ramp ───
  //
  // Weights go through `withWeight`: every Aeros style pins Inter's `wght` axis, so a plain
  // `copyWith(fontWeight:)` would not change the glyphs.

  /// A row's name, a pane title: 14/1.3 (pointer) or 16/1.25 (touch), w600.
  TextStyle titleStyle({Color? color, FontWeight weight = FontWeight.w600}) =>
      AerosTypography.bodyLg(color: color).copyWith(fontSize: _titleSize, height: _titleHeight).withWeight(weight);

  /// Reading text — a message, a description: 14px, line height 1.4 (pointer) or 1.45 (touch).
  TextStyle bodyStyle({Color? color, FontWeight weight = FontWeight.w400}) =>
      AerosTypography.bodyMd(color: color).copyWith(height: _bodyHeight).withWeight(weight);

  /// A row's second line, a preview: 13/1.35.
  TextStyle secondaryStyle({Color? color, FontWeight weight = FontWeight.w400}) =>
      AerosTypography.bodySm(color: color).copyWith(height: 1.35).withWeight(weight);

  /// Times, tags, sub-lines: 12px, line height 1.25 (pointer) or 1.3 (touch).
  TextStyle metaStyle({Color? color, FontWeight weight = FontWeight.w500}) =>
      AerosTypography.caption(color: color).copyWith(height: _metaHeight).withWeight(weight);

  /// Control labels — chips, tabs: 12px (pointer) or 13px (touch), w600.
  TextStyle labelStyle({Color? color, FontWeight weight = FontWeight.w600}) =>
      AerosTypography.labelSm(color: color).copyWith(fontSize: _labelSize, height: 1.2).withWeight(weight);

  /// The smallest text — a timestamp inside a bubble: 11/1.2.
  TextStyle microStyle({Color? color, FontWeight weight = FontWeight.w500}) =>
      AerosTypography.caption(color: color).copyWith(fontSize: 11, height: 1.2, letterSpacing: 0.1).withWeight(weight);
}

/// Sets the [AerosDensity] for everything below it. See [AerosDensity] for when to use which.
class AerosDensityScope extends InheritedWidget {
  const AerosDensityScope({super.key, required this.density, required super.child});

  final AerosDensity density;

  /// The nearest scope's density, or null when there is no scope.
  static AerosDensity? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AerosDensityScope>()?.density;

  @override
  bool updateShouldNotify(AerosDensityScope oldWidget) => oldWidget.density != density;
}
