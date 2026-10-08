import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/aeros_theme_extension.dart';
import '../tokens/motion.dart';

/// The Aeros "thinking" loader: a slowly turning sphere of dots with a wave
/// folding through it.
///
/// Use it where the app is genuinely working and there is nothing to show
/// yet: the startup splash, or an agent composing a reply. It is not a
/// progress bar — pair it with [AerosProgress] when progress is known.
///
/// The dots sit on a latitude/longitude grid, the sphere is tilted toward the
/// viewer and spins about its axis, and every dot is
/// depth-shaded: near dots are larger and solid, far dots small and faint,
/// which is what makes a flat point cloud read as a globe. A ripple travels
/// pole to pole, pushing each latitude band in and out — the "thinking" fold.
///
/// Every motion completes whole cycles per [period], so the loop is seamless.
/// With the platform "reduce motion" setting on, it renders one static frame
/// and never ticks.
///
/// `web/index.html` in the apps carries a canvas twin of this painter (same
/// lattice, tilt, wave and shading) so the HTML splash hands off seamlessly —
/// change both together.
class AerosThinkingOrb extends StatefulWidget {
  const AerosThinkingOrb({
    super.key,
    this.size = 96,
    this.color,
    this.period = const Duration(seconds: 8),
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
                  painter: _DotSpherePainter(t: _loop.value, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotSpherePainter extends CustomPainter {
  _DotSpherePainter({required this.t, required this.color});

  /// Phase in [0, 1); every motion below completes whole cycles over it.
  final double t;
  final Color color;

  static const double _tau = math.pi * 2;
  static const double _tilt = 0.32; // top pole leans toward the viewer (~18°)

  // Unit-sphere lattices, cached per (meridians, rings).
  static final Map<int, List<_P3>> _lattices = {};

  /// A latitude/longitude grid: dots line up in meridian columns, which is
  /// what gives the globe its striped texture as it turns. Density scales
  /// with size — sparse enough to read as dots at 24px, a globe at 160px.
  static List<_P3> _lattice(double size) {
    final meridians = (size / 4).round().clamp(12, 40);
    final rings = (size / 7.5).round().clamp(7, 21);
    return _lattices.putIfAbsent(meridians * 100 + rings, () {
      final pts = <_P3>[];
      for (var r = 0; r < rings; r++) {
        // Latitudes from just below one pole to just above the other.
        final lat = (r + 0.5) / rings * math.pi - math.pi / 2;
        final y = math.sin(lat), ring = math.cos(lat);
        // Near the poles keep only every k-th meridian, so rings thin out
        // instead of piling up — while the survivors stay in their columns.
        final every = (1 / ring).round().clamp(1, meridians ~/ 4);
        for (var m = 0; m < meridians; m += every) {
          final lon = m / meridians * _tau;
          pts.add(_P3(math.cos(lon) * ring, y, math.sin(lon) * ring));
        }
      }
      return pts;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final radius = s * 0.42;
    final dotR = math.max(0.5, s * 0.0095);
    final phase = t * _tau;

    final spin = phase; // one turn per period
    final cs = math.cos(spin), sn = math.sin(spin);
    final ct = math.cos(_tilt), st = math.sin(_tilt);
    final breath = 1 + 0.02 * math.sin(phase * 2);

    final paint = Paint()..isAntiAlias = true;
    for (final p in _lattice(s)) {
      // The fold: a narrow band that sinks into the sphere, riding the
      // sphere's own latitude (p.y) so it sweeps pole to pole (twice per turn)
      // while the sphere spins under it. Seen through the tilt it reads as a
      // crescent seam; the silhouette elsewhere stays round.
      final band = math.pow((math.sin(p.y * 2.4 - phase * 2) + 1) / 2, 10);
      final fold = 1 - 0.15 * band;
      final px = p.x * fold * breath;
      final py = p.y * fold * breath;
      final pz = p.z * fold * breath;

      // Spin about the vertical axis, then tilt toward the viewer.
      final x1 = px * cs + pz * sn;
      final z1 = -px * sn + pz * cs;
      final y2 = py * ct - z1 * st;
      final z2 = py * st + z1 * ct;

      // Depth 0 (far) → 1 (near).
      final depth = ((z2 / 1.1) + 1) / 2;
      final a = 0.08 + 0.92 * depth * depth;
      paint.color = color.withValues(alpha: color.a * a.clamp(0.0, 1.0));
      canvas.drawCircle(
        c + Offset(x1, -y2) * radius,
        dotR * (0.45 + 0.75 * depth),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotSpherePainter old) => old.t != t || old.color != color;
}

class _P3 {
  const _P3(this.x, this.y, this.z);
  final double x, y, z;
}
