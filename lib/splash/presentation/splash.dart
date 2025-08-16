import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:whatbytes/core/theme/app_color.dart';
import 'package:whatbytes/auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _bg; // gradient drift (loops)
  late final AnimationController _reveal; // logo + burst timeline
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();

    _bg = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // Auto navigate after a short delight window (can still tap to skip)
    _routeTimer = Timer(const Duration(milliseconds: 2200), _goNext);
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    _bg.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;

    context.go('/'); // home
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _goNext, // tap to skip
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ---------- Animated Gradient Background ----------
            AnimatedBuilder(
              animation: _bg,
              builder: (_, __) {
                final t = _bg.value * 2 * math.pi;
                final a = Alignment(math.sin(t) * .6, math.cos(t) * .6);
                final b = Alignment(math.cos(t) * .6, -math.sin(t) * .6);
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: a,
                      end: b,
                      colors: [
                        AppColor.primary,
                        AppColor.primary.withOpacity(.85),
                        cs.tertiary.withOpacity(.75),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ---------- Centerpiece: logo reveal + confetti ----------
            Center(
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) {
                  final t = Curves.easeOutBack.transform(
                    (_reveal.value).clamp(0, .7) / .7,
                  ); // 0..0.7 segment for logo bounce
                  final scale = 0.8 + 0.2 * t;
                  final rot = (1 - t) * .08; // small tilt-in

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow halo
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(.15),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      // Confetti burst: runs from 0.3..1.0 of timeline
                      IgnorePointer(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: CustomPaint(
                            painter: _ConfettiBurstPainter(
                              progress: ((_reveal.value - .30) / .70).clamp(
                                0.0,
                                1.0,
                              ),
                              baseColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Logo tile
                      Transform.rotate(
                        angle: rot,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.12),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withOpacity(.18),
                                width: 1.2,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(.16),
                                  Colors.white.withOpacity(.04),
                                ],
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ---------- App name fade-in ----------
            Align(
              alignment: Alignment(0, .55),
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (_, __) {
                  final o = Curves.easeOut.transform(
                    ((_reveal.value - .45) / .55).clamp(0.0, 1.0),
                  );
                  return Opacity(
                    opacity: o,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'whatbytes',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get things done beautifully',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(.85)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ---------- Skip hint ----------
            Positioned(
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(.14)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Tap to skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== Confetti burst painter ===============
class _ConfettiBurstPainter extends CustomPainter {
  final double progress; // 0..1
  final Color baseColor;

  _ConfettiBurstPainter({required this.progress, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .45 * Curves.easeOut.transform(progress);
    final rnd = math.Random(7); // deterministic for consistent look

    // Draw ~28 pieces flying outward with slight rotation
    for (int i = 0; i < 28; i++) {
      final ang = (i / 28.0) * 2 * math.pi + rnd.nextDouble() * .2;
      final dist = radius * (0.75 + rnd.nextDouble() * .35);
      final pos = center + Offset(math.cos(ang), math.sin(ang)) * dist;

      // vary sizes/colors
      final sz = 4.0 + rnd.nextDouble() * 6.0;
      final hue = i % 4;
      final c = switch (hue) {
        0 => Colors.white,
        1 => Colors.amberAccent,
        2 => Colors.cyanAccent,
        _ => Colors.pinkAccent,
      }.withOpacity(1.0 - (progress * .6));

      final paint = Paint()..color = c;
      final rot = ang + progress * 6.0;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rot);
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: sz, height: sz * .55),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, paint);
      canvas.restore();
    }

    // subtle ring
    final ringPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withOpacity(.35 * (1 - progress));
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.baseColor != baseColor;
}
