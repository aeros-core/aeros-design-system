import 'package:flutter/widgets.dart';

import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// The one size ladder for every Aeros control — buttons, fields, pickers.
///
/// A button and a field of the same size are the same height, so they sit on
/// one line. The height follows the input density of the nearest
/// [AerosDensityScope]: 24 / 28 / 32 / 36 / 40 for a mouse
/// ([AerosSizeTokens.pointer]) and 32 / 36 / 40 / 44 / 48 for fingers
/// ([AerosSizeTokens.touch]). Every size shares one corner radius
/// ([AerosShapeTokens.control]).
///
/// `AerosButtonSize` and `AerosFieldSize` are deprecated aliases of this enum.
enum AerosControlSize {
  xs,
  sm,
  md,
  lg,
  xl;

  /// The size set by the nearest [AerosControlSizeScope]; [md] when there is none.
  static AerosControlSize of(BuildContext context) => AerosControlSizeScope.maybeOf(context) ?? AerosControlSize.md;

  /// Control height at [density].
  double heightFor(AerosDensity density) {
    final sizes = density.sizes;
    return switch (this) {
      AerosControlSize.xs => sizes.controlXs,
      AerosControlSize.sm => sizes.controlSm,
      AerosControlSize.md => sizes.controlMd,
      AerosControlSize.lg => sizes.controlLg,
      AerosControlSize.xl => sizes.controlXl,
    };
  }

  /// Control height for the density of the nearest [AerosDensityScope].
  double resolveHeight(BuildContext context) => heightFor(AerosDensity.of(context));

  /// Control height with no density scope (touch, like [AerosDensity.of]).
  /// Inside a widget prefer [resolveHeight].
  double get height => heightFor(AerosDensity.touch);

  /// Horizontal content padding.
  double get padH => switch (this) {
        AerosControlSize.xs => AerosSpacing.s2,
        AerosControlSize.sm => AerosSpacing.s2_5,
        AerosControlSize.md => AerosSpacing.s3,
        AerosControlSize.lg => AerosSpacing.s3_5,
        AerosControlSize.xl => AerosSpacing.s4,
      };

  /// Space between an icon and the label, or between two parts of a control.
  double get gap => switch (this) {
        AerosControlSize.xs => AerosSpacing.s1,
        AerosControlSize.sm || AerosControlSize.md => AerosSpacing.s1_5,
        AerosControlSize.lg || AerosControlSize.xl => AerosSpacing.s2,
      };

  /// Leading / trailing glyph size.
  double get iconSize => switch (this) {
        AerosControlSize.xs || AerosControlSize.sm => AerosSizeTokens.iconSm,
        AerosControlSize.md || AerosControlSize.lg => AerosSizeTokens.iconMd,
        AerosControlSize.xl => AerosSizeTokens.iconLg,
      };

  /// Corner radius — the same for every size.
  BorderRadius get radius => const BorderRadius.all(Radius.circular(AerosShapeTokens.control));

  bool get _small => this == AerosControlSize.xs || this == AerosControlSize.sm;

  /// A button label at this size: `labelSm` for xs / sm, `labelMd` above.
  TextStyle labelStyle({Color? color}) =>
      _small ? AerosTypography.labelSm(color: color) : AerosTypography.labelMd(color: color);

  /// Typed-value / hint text at this size — `w500`, line height 1.3.
  TextStyle valueStyle({Color? color}) {
    final base = _small ? AerosTypography.bodySm(color: color) : AerosTypography.bodyMd(color: color);
    return base.copyWith(height: 1.3).withWeight(FontWeight.w500);
  }

  /// Vertical padding that centres one line of [valueStyle] in [height].
  /// Fields centre their content themselves now; nothing in the package reads this.
  @Deprecated('Fields centre their content; use resolveHeight(context) for the control height.')
  double get padV {
    final style = valueStyle();
    return (height - style.fontSize! * style.height!) / 2;
  }
}

/// Sets the default [AerosControlSize] for the controls below it that were not
/// given a size of their own.
class AerosControlSizeScope extends InheritedWidget {
  const AerosControlSizeScope({super.key, required this.size, required super.child});

  final AerosControlSize size;

  /// The nearest scope's size, or null when there is no scope.
  static AerosControlSize? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AerosControlSizeScope>()?.size;

  @override
  bool updateShouldNotify(AerosControlSizeScope oldWidget) => oldWidget.size != size;
}
