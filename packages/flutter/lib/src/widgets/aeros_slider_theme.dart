import 'package:flutter/material.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';

/// The one look for Material's `Slider` and `RangeSlider` inside the design
/// system. Not exported.
///
/// A 2px track, a 14px thumb (`bgSurface` with a `brandPrimary` hairline), no
/// tick marks, no value bubble and no halo: hover and drag draw nothing extra,
/// keyboard focus draws the focus ring around the thumb.
class AerosSliderTheme extends StatelessWidget {
  const AerosSliderTheme({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  static const double _thumbRadius = AerosSizeTokens.iconSm / 2;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final thumb = _ThumbPainter(fill: a.bgSurface, border: a.brandPrimary);
    final slider = SliderTheme(
      data: SliderThemeData(
        trackHeight: AerosMetricTokens.borderThick,
        trackShape: const RectangularSliderTrackShape(),
        rangeTrackShape: const RectangularRangeSliderTrackShape(),
        activeTrackColor: a.brandPrimary,
        inactiveTrackColor: a.borderStrong,
        // A disabled slider is dimmed as a whole, below; its parts keep their colours.
        disabledActiveTrackColor: a.brandPrimary,
        disabledInactiveTrackColor: a.borderStrong,
        thumbShape: _AerosThumbShape(thumb),
        rangeThumbShape: _AerosRangeThumbShape(thumb),
        overlayShape: const _FocusRingOverlayShape(_thumbRadius),
        overlayColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused) ? a.focusRing : Colors.transparent,
        ),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        disabledActiveTickMarkColor: Colors.transparent,
        disabledInactiveTickMarkColor: Colors.transparent,
        showValueIndicator: ShowValueIndicator.never,
      ),
      // The density's minimum target, so the thumb is easy to grab.
      child: SizedBox(height: AerosDensity.of(context).sizes.minTarget, child: child),
    );
    return enabled ? slider : Opacity(opacity: AerosMetricTokens.opacityDisabled, child: slider);
  }
}

/// The value readout in a slider's label row. It dims with the slider — to
/// [AerosMetricTokens.opacityDisabled] — when the slider is disabled. Not
/// exported.
class AerosSliderValue extends StatelessWidget {
  const AerosSliderValue({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      enabled ? child : Opacity(opacity: AerosMetricTokens.opacityDisabled, child: child);
}

class _ThumbPainter {
  const _ThumbPainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  void paint(Canvas canvas, Offset center) {
    const radius = AerosSliderTheme._thumbRadius;
    const hairline = AerosMetricTokens.borderHairline;
    canvas.drawCircle(center, radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      radius - hairline / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hairline
        ..color = border,
    );
  }
}

class _AerosThumbShape extends SliderComponentShape {
  const _AerosThumbShape(this.painter);

  final _ThumbPainter painter;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(AerosSliderTheme._thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) =>
      painter.paint(context.canvas, center);
}

class _AerosRangeThumbShape extends RangeSliderThumbShape {
  const _AerosRangeThumbShape(this.painter);

  final _ThumbPainter painter;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(AerosSliderTheme._thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) =>
      painter.paint(context.canvas, center);
}

/// Draws the focus ring where Material draws its halo. It reports no size of
/// its own, so the track runs from thumb edge to thumb edge.
class _FocusRingOverlayShape extends SliderComponentShape {
  const _FocusRingOverlayShape(this.thumbRadius);

  final double thumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final color = sliderTheme.overlayColor;
    if (color == null || color.a == 0) return;
    context.canvas.drawCircle(
      center,
      thumbRadius + AerosMetricTokens.focusOffset + AerosMetricTokens.focusWidth / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AerosMetricTokens.focusWidth
        ..color = color.withValues(alpha: color.a * activationAnimation.value),
    );
  }
}
