import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'internet_cubit.dart';

class InternetBanner extends StatelessWidget {
  /// Put this once at the top of the app (e.g., in MaterialApp.builder)
  const InternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetState>(
      buildWhen:
          (p, n) => p.status != n.status, // repaint only on status changes
      builder: (context, state) {
        final visible = state.status != NetHealth.online;
        final (color, text, icon) = switch (state.status) {
          NetHealth.offline => (
            Colors.red,
            'No Internet connection',
            Icons.wifi_off_rounded,
          ),
          NetHealth.unstable => (
            Colors.orange,
            'Internet is unstable',
            Icons.wifi_tethering_error_rounded,
          ),
          NetHealth.online => (Colors.green, 'Online', Icons.wifi_rounded),
        };

        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0, -1.2),
          child: Material(
            color: color,
            elevation: 6,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (state.status != NetHealth.online) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed:
                            () => context.read<InternetCubit>().pingNow(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
