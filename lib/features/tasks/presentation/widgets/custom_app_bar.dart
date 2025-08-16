import 'package:flutter/material.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? subtitle;
  final List<Widget>? actions;
  const CustomAppBar({super.key, this.subtitle, this.actions});

  // a bit taller so content never clips
  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: AppColor.primary,
      elevation: 0,
      clipBehavior: Clip.none, // allow floating search pill
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Header (purple)
          Container(
            height: preferredSize.height,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      ...?actions,
                    ],
                  ),
                  const SizedBox(height: 10),
                  if ((subtitle ?? '').isNotEmpty)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(.85),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating search pill
          Positioned(
            left: 16,
            right: 16,
            bottom: -24, // float below curved header
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(Icons.search, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Search', style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
