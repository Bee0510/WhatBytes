// lib/auth/presentation/pages/get_started_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with WidgetsBindingObserver {
  static const _autoScrollInterval = Duration(seconds: 3);
  final _controller = PageController();
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
    _startAuto();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAuto();
    } else {
      _ticker?.cancel();
    }
  }

  void _startAuto() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || _userInteracting) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(240),
                ),
              ),
            ),
          ),

          // content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Listener(
                    onPointerDown: (_) => _userInteracting = true,
                    onPointerUp: (_) {
                      _userInteracting = false;
                      _startAuto();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .3,
                          child: PageView.builder(
                            controller: _controller,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemCount: _slides.length,
                            itemBuilder:
                                (_, i) => _SlideView(slide: _slides[i]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Dots(active: _index, total: _slides.length),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // bottom-right arrow CTA
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColor.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- slide widgets ----------

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

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _HeroIcon(icon: slide.icon),
        const SizedBox(height: 20),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
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
    );
  }
}

class _HeroIcon extends StatelessWidget {
  final IconData icon;
  const _HeroIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.width * .3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 44),
          ),
          // confetti dots
          Positioned(top: 16, right: 78, child: _dot(6, cs.tertiary)),
          Positioned(
            top: 12,
            left: 78,
            child: _dot(8, cs.primary.withOpacity(.5)),
          ),
          Positioned(bottom: 12, left: 74, child: _dot(5, cs.secondary)),
          Positioned(bottom: 16, right: 74, child: _dot(7, cs.error)),
        ],
      ),
    );
  }

  Widget _dot(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _Dots extends StatelessWidget {
  final int active;
  final int total;
  const _Dots({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 16 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
