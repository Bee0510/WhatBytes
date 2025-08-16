import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const _autoScrollInterval = Duration(seconds: 3);

  late final PageController _controller;
  late final AnimationController _bgCtrl; // loops background blobs
  double _page = 0.0;

  final _slides = const <_Slide>[
    _Slide(
      icon: Icons.check_rounded,
      title: 'Get things done.',
      subtitle: 'Just a click away from\nplanning your tasks.',
    ),
    _Slide(
      icon: Icons.calendar_month_rounded,
      title: 'Plan & prioritize.',
      subtitle: 'Set due dates and priorities\nthat fit your day.',
    ),
    _Slide(
      icon: Icons.flash_on_rounded,
      title: 'Stay on track.',
      subtitle: 'Mark complete and filter tasks\nwithout the clutter.',
    ),
  ];

  int _index = 0;
  Timer? _ticker;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = PageController(viewportFraction: .86)..addListener(() {
      if (!mounted) return;
      setState(() => _page = _controller.page ?? _index.toDouble());
    });

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _startAuto();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _bgCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAuto();
      _bgCtrl.repeat();
    } else {
      _ticker?.cancel();
      _bgCtrl.stop();
    }
  }

  void _startAuto() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || _userInteracting) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => _AnimatedBlobs(progress: _bgCtrl.value),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: const SizedBox.shrink(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: Listener(
                        onPointerDown: (_) => _userInteracting = true,
                        onPointerUp: (_) {
                          _userInteracting = false;
                          _startAuto();
                        },
                        child: SizedBox(
                          height: size.height * .44,
                          child: PageView.builder(
                            controller: _controller,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemCount: _slides.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (_, i) {
                              final delta = (i - _page).clamp(-1.0, 1.0);
                              final scale = 1 - (delta.abs() * 0.07);
                              final opacity = 1 - (delta.abs() * 0.25);
                              final yParallax = 16 * delta;

                              return Transform.translate(
                                offset: Offset(0, yParallax),
                                child: Opacity(
                                  opacity: opacity,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: _SlideCard(
                                      slide: _slides[i],
                                      active: i == _index,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _FancyDots(active: _index, total: _slides.length),

                  const SizedBox(height: 24),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: _PrimaryCtaButton(
                      label: 'Get started',
                      onPressed: () => context.go('/login'),
                    ),
                  ),

                  SizedBox(height: bottom + 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Animated background blobs ----------
class _AnimatedBlobs extends StatelessWidget {
  final double progress; // 0..1 loop
  const _AnimatedBlobs({required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = progress * 2 * math.pi;
    final a1 = Alignment(math.sin(t) * .8, math.cos(t) * .8);
    final a2 = Alignment(math.cos(t * .8) * .9, math.sin(t * .8) * .9);

    return Stack(
      children: [
        // blob 1
        Align(
          alignment: a1,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        // blob 2
        Align(
          alignment: a2,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Slide card ----------
class _SlideCard extends StatelessWidget {
  final _Slide slide;
  final bool active;
  const _SlideCard({required this.slide, required this.active});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
      ),
      child: Column(
        children: [
          _HeroIcon(icon: slide.icon, active: active),
          const SizedBox(height: 16),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------- slide model ----------
class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// ---------- lively hero icon with confetti ring ----------
class _HeroIcon extends StatefulWidget {
  final IconData icon;
  final bool active;
  const _HeroIcon({required this.icon, required this.active});

  @override
  State<_HeroIcon> createState() => _HeroIconState();
}

class _HeroIconState extends State<_HeroIcon> with TickerProviderStateMixin {
  late final AnimationController _bob; // bob + tilt
  late final AnimationController _ring; // rotate confetti

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mag = widget.active ? 1.0 : .5; // smaller motion when inactive

    return SizedBox(
      height: 140,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bob, _ring]),
        builder: (_, __) {
          final y = (math.sin(_bob.value * 2 * math.pi) * 6) * mag;
          final tilt = (math.sin(_bob.value * 2 * math.pi) * .05) * mag;

          return Transform.translate(
            offset: Offset(0, y),
            child: Transform.rotate(
              angle: tilt,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // confetti ring
                  Transform.rotate(
                    angle: _ring.value * 2 * math.pi,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(painter: _ConfettiRingPainter()),
                    ),
                  ),
                  // icon tile
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(.28),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 44),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .44;
    final rnd = math.Random(9);
    for (int i = 0; i < 18; i++) {
      final ang = (i / 18) * 2 * math.pi;
      final pos = center + Offset(math.cos(ang), math.sin(ang)) * r;
      final len = 6.0 + rnd.nextDouble() * 6.0;
      final paint =
          Paint()
            ..color =
                [
                  Colors.amberAccent,
                  Colors.cyanAccent,
                  Colors.pinkAccent,
                  Colors.white,
                ][i % 4];
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(ang);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: len, height: 3),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------- fancy page dots ----------
class _FancyDots extends StatelessWidget {
  final int active;
  final int total;
  const _FancyDots({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
        );
      }),
    );
  }
}

// ---------- CTA button ----------
class _PrimaryCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryCtaButton({required this.label, required this.onPressed});

  @override
  State<_PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<_PrimaryCtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _hover,
          builder: (_, __) {
            final lift = 2 + 2 * _hover.value;
            return Transform.translate(
              offset: Offset(0, -lift),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary,
                      AppColor.primary.withOpacity(.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
