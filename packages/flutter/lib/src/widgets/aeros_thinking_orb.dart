import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';

/// The Aeros "thinking" loader: a finely dotted sphere with a soft pulse of
/// thought sweeping through it.
///
/// Use it where the app is genuinely working and there is nothing to show
/// yet: the startup splash, or an agent composing a reply. It is not a
/// progress bar — pair it with [AerosProgress] when progress is known.
///
/// The dots are spread evenly over the sphere (a Fibonacci lattice: no
/// seams, no pole clumps), the sphere is tilted toward the viewer and turns
/// once per [period], and every dot is depth-shaded — near dots larger and
/// solid, far dots small and faint — so the point cloud reads as a globe.
/// A pulse travels back and forth along a slanted axis: the dots it passes
/// swell, brighten and lift off the surface, while the whole surface ripples
/// gently. That pulse is the "thinking".
///
/// Every motion completes whole cycles per [period], so the loop is seamless.
/// With the platform "reduce motion" setting on, it renders one static frame
/// and never ticks.
///
/// `web/index.html` in the apps carries a canvas twin of this painter (same
/// lattice, tilt, pulse and shading) so the HTML splash hands off seamlessly —
/// change both together.
class AerosThinkingOrb extends StatefulWidget {
  const AerosThinkingOrb({
    super.key,
    this.size = 96,
    this.color,
    this.period = const Duration(seconds: 10),
    this.semanticLabel = 'Loading',
  });

  /// Edge length of the square the sphere paints into.
  final double size;

  /// Dot colour. Defaults to the theme's `fgPrimary` — ink on the light
  /// canvas, pearl on the dark one.
  final Color? color;

  /// One full turn of the sphere. Shorter reads as busier.
  final Duration period;

  /// Announced by screen readers in place of the (purely visual) orb.
  final String semanticLabel;

  @override
  State<AerosThinkingOrb> createState() => _AerosThinkingOrbState();
}

class _AerosThinkingOrbState extends State<AerosThinkingOrb>
    with TickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: widget.period);
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: AerosMotion.slow);
  late final Animation<double> _entranceCurve =
      CurvedAnimation(parent: _entrance, curve: AerosMotion.entrance);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _loop.stop();
      _entrance.value = 1;
    } else {
      if (!_loop.isAnimating) _loop.repeat();
      if (_entrance.isDismissed) _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(AerosThinkingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loop.duration = widget.period;
      if (_loop.isAnimating) _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.aerosColors.fgPrimary;
    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.semanticLabel,
      child: FadeTransition(
        opacity: _entranceCurve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(_entranceCurve),
          child: RepaintBoundary(
            child: SizedBox.square(
              dimension: widget.size,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) => CustomPaint(
                  painter: _PulseSpherePainter(t: _loop.value, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseSpherePainter extends CustomPainter {
  _PulseSpherePainter({required this.t, required this.color});

  /// Phase in [0, 1); every motion below completes whole cycles over it.
  final double t;
  final Color color;

  static const double _tau = math.pi * 2;
  static const double _tilt = 0.38; // top pole leans toward the viewer (~22°)

  // The pulse travels along this slanted unit axis (normalised (.45,.8,.35)).
  static const double _ax = 0.4581, _ay = 0.8144, _az = 0.3563;

  // Unit-sphere lattices, cached per dot count.
  static final Map<int, List<_P3>> _lattices = {};

  /// Dot count scales with area-ish: ~560 at 128px — fine enough to read as
  /// a surface, sparse enough to stay crisp at 48px.
  static int dotCount(double size) => (size * 4.4).round().clamp(120, 900);

  static List<_P3> _lattice(int n) => _lattices.putIfAbsent(n, () {
        final golden = math.pi * (3 - math.sqrt(5));
        return List.generate(n, (i) {
          final y = 1 - 2 * (i + 0.5) / n;
          final r = math.sqrt(1 - y * y);
          final phi = i * golden;
          return _P3(math.cos(phi) * r, y, math.sin(phi) * r);
        });
      });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final radius = s * 0.4;
    final dotR = math.max(0.5, s * 0.0074);
    final phase = t * _tau;

    final cs = math.cos(phase), sn = math.sin(phase); // one turn per period
    final ct = math.cos(_tilt), st = math.sin(_tilt);
    // Where the pulse is along its axis: sweeps -1.15 → 1.15 and back, twice
    // per period, so it fully clears the sphere at each end.
    final pulseAt = math.sin(phase * 2) * 1.15;

    final paint = Paint()..isAntiAlias = true;
    for (final p in _lattice(dotCount(s))) {
      final along = p.x * _ax + p.y * _ay + p.z * _az;
      final d2 = along - pulseAt;
      final pulse = math.exp(-(d2 * d2) / 0.018); // 0..1, narrow band
      final lift = 1 +
          0.02 * math.sin(3 * p.x + phase * 2) * math.sin(2 * p.y - phase) +
          0.07 * pulse;
      final px = p.x * lift, py = p.y * lift, pz = p.z * lift;

      // Spin about the vertical axis, then tilt toward the viewer.
      final x1 = px * cs + pz * sn;
      final z1 = -px * sn + pz * cs;
      final y2 = py * ct - z1 * st;
      final z2 = py * st + z1 * ct;

      // Depth 0 (far) → 1 (near).
      final depth = ((z2 / 1.1) + 1) / 2;
      final a = 0.09 + 0.85 * math.pow(depth, 1.4) + 0.4 * pulse;
      paint.color = color.withValues(alpha: color.a * a.clamp(0.0, 1.0));
      canvas.drawCircle(
        c + Offset(x1, -y2) * radius,
        dotR * (0.5 + 0.7 * depth) * (1 + 1.1 * pulse),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PulseSpherePainter old) =>
      old.t != t || old.color != color;
}

class _P3 {
  const _P3(this.x, this.y, this.z);
  final double x, y, z;
}
