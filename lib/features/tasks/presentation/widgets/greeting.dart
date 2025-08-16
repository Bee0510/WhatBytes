import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GreetingBanner extends StatefulWidget {
  const GreetingBanner();

  @override
  State<GreetingBanner> createState() => GreetingBannerState();
}

class GreetingBannerState extends State<GreetingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  Timer? _minuteTick;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    // Update greeting/time every minute
    _minuteTick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteTick?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final now = DateTime.now();
    final hour = now.hour;

    late final String greet;
    late final IconData icon;
    late final Color accent;

    if (hour >= 5 && hour < 12) {
      greet = 'Good morning';
      icon = Icons.wb_sunny_rounded;
      accent = Colors.amberAccent;
    } else if (hour >= 12 && hour < 18) {
      greet = 'Good afternoon';
      icon = Icons.wb_twilight_rounded;
      accent = Colors.orangeAccent;
    } else {
      greet = 'Good evening';
      icon = Icons.nights_stay_rounded;
      accent = Colors.indigoAccent;
    }

    String _time() {
      final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final m = now.minute.toString().padLeft(2, '0');
      final ampm = now.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(.25),
                  Colors.white.withOpacity(.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: AnimatedBuilder(
              animation: _spin,
              builder: (_, __) {
                final turns = 0.02 * math.sin(_spin.value * 2 * math.pi);
                return AnimatedRotation(
                  turns: turns,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(icon, color: Colors.white, size: 24),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Column(
                key: ValueKey(greet), // animate when greeting changes
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greet,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hour < 12
                        ? 'Let’s plan a productive day.'
                        : (hour < 18
                            ? 'Keep the momentum going.'
                            : 'Wrap up important tasks.'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(.85),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tiny time pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.14)),
            ),
            child: Text(
              _time(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
