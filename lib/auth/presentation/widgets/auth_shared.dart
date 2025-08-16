import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class AuthShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final List<Widget> formChildren;
  final String helperText; // “or log in with”
  final String footerText; // “Don’t have an account?”
  final String footerActionText; // “Get started!”
  final VoidCallback onFooterTap;
  final bool loading;

  const AuthShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.formChildren,
    required this.helperText,
    required this.footerText,
    required this.footerActionText,
    required this.onFooterTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // page content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _AuthHeader(),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),
                      ...formChildren,
                      const SizedBox(height: 24),
                      SizedBox(
                        child: FilledButton(
                          onPressed: loading ? null : onPrimaryPressed,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child:
                              loading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    primaryButtonText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        helperText,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      const _SocialRow(),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: loading ? null : onFooterTap,
                        child: Text.rich(
                          TextSpan(
                            text: '$footerText ',
                            style: TextStyle(color: cs.onSurfaceVariant),
                            children: [
                              TextSpan(
                                text: footerActionText,
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Positioned(
        //   right: 0,
        //   bottom: 0,
        //   child: Container(
        //     width: 200,
        //     height: 200,
        //     decoration: BoxDecoration(
        //       color: AppColor.primary.withOpacity(.3),
        //       borderRadius: const BorderRadius.only(
        //         topLeft: Radius.circular(200),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// replace your current _AuthHeader with this animated version
class _AuthHeader extends StatefulWidget {
  const _AuthHeader({super.key});

  @override
  State<_AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<_AuthHeader>
    with TickerProviderStateMixin {
  late final AnimationController _bob; // bob + tilt
  late final AnimationController _ring; // orbit dots
  late final AnimationController _sheen; // diagonal shine sweep

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

    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    _ring.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final box = MediaQuery.of(context).size.width * 0.25; // square size
    final r = box * 0.62; // ring radius for dots

    return AnimatedBuilder(
      animation: Listenable.merge([_bob, _ring, _sheen]),
      builder: (context, _) {
        final tBob = _bob.value * 2 * math.pi;
        final y = math.sin(tBob) * 6; // bob amount
        final tilt = math.sin(tBob) * 0.06; // ~3.4°
        final glow = 0.22 + 0.10 * math.sin(tBob).abs();

        final rot = _ring.value * 2 * math.pi; // orbit angle
        final pulse = 1 + 0.03 * math.sin(rot); // subtle radius pulse

        return SizedBox(
          width: box * 1.6,
          height: box * 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // --- main tile with bob + tilt + glow ---
              Transform.translate(
                offset: Offset(0, y),
                child: Transform.rotate(
                  angle: tilt,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // glow halo
                      Container(
                        width: box + 28,
                        height: box + 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withOpacity(glow),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      // tile + sheen + icon
                      Container(
                        width: box,
                        height: box,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(box * 0.19),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            // diagonal sheen sweep
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(box * 0.19),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform:
                                      Matrix4.identity()
                                        ..translate(
                                          // move the sheen left->right
                                          ((_sheen.value * 2 - 0.5) *
                                              (box * 1.2)),
                                        )
                                        ..rotateZ(-0.6),
                                  child: Container(
                                    width: box * 0.7,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0),
                                          Colors.white.withOpacity(.25),
                                          Colors.white.withOpacity(0),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- orbiting confetti dots (animated) ---
              _dotAt(
                angle: _deg(25) + rot,
                radius: r * pulse,
                size: box * 0.075,
                color: cs.tertiary,
              ),
              _dotAt(
                angle: _deg(155) + rot,
                radius: r * pulse,
                size: box * 0.095,
                color: cs.primary,
              ),
              _dotAt(
                angle: _deg(230) + rot,
                radius: r * 0.88 * pulse,
                size: box * 0.065,
                color: cs.secondary,
              ),
              _dotAt(
                angle: _deg(335) + rot,
                radius: r * 0.92 * pulse,
                size: box * 0.085,
                color: cs.error,
              ),
            ],
          ),
        );
      },
    );
  }

  // helpers
  double _deg(double d) => d * math.pi / 180.0;

  Widget _dotAt({
    required double angle,
    required double radius,
    required double size,
    required Color color,
  }) {
    return Transform.translate(
      offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ---- helpers ----

class _dotPolar extends StatelessWidget {
  final double angleDeg;
  final double radius;
  final double size;
  final Color color;
  const _dotPolar({
    required this.angleDeg,
    required this.radius,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rad = angleDeg * math.pi / 180.0;
    return Transform.translate(
      offset: Offset(radius * math.cos(rad), radius * math.sin(rad)),
      child: _dot(size, color),
    );
  }
}

Widget _dot(double s, Color c) => Container(
  width: s,
  height: s,
  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
);

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure; // initial state
  final String? Function(String?)? validator;
  final Widget? trailing;
  final bool canToggleObscure; // show eye when obscure
  final bool isLogin; // true for login screens
  final VoidCallback?
  onForgotPassword; // shown next to label when isLogin+obscure

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator,
    this.trailing,
    this.canToggleObscure = true,
    this.isLogin = false,
    this.onForgotPassword,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  void didUpdateWidget(covariant AuthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      _obscure = widget.obscure;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPassword = widget.obscure;

    // suffix: your trailing widget + eye toggle
    Widget? suffix;
    final canToggle = widget.canToggleObscure && isPassword;
    if (widget.trailing != null || canToggle) {
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: widget.trailing!,
            ),
          if (canToggle)
            IconButton(
              tooltip: _obscure ? 'Show' : 'Hide',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: cs.onSurfaceVariant.withOpacity(0.3),
                size: 20,
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL ROW: "Password" .... "Forgot password?"
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.isLogin &&
                  isPassword &&
                  widget.onForgotPassword != null)
                TextButton(
                  onPressed: widget.onForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          obscuringCharacter: '•',
          enableSuggestions: !isPassword,
          autocorrect: !isPassword,
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainerHighest.withOpacity(.25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: cs.primary, width: 1.4),
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget circle(dynamic child, Color color, {VoidCallback? onTap}) => InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child:
            child is IconData
                ? Icon(child, color: color)
                : DefaultTextStyle(
                  style: TextStyle(fontSize: 18, color: color),
                  child: child as Widget,
                ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circle(
          const Text(
            'f',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          AppColor.primary,
        ), // Facebook placeholder
        const SizedBox(width: 16),
        circle(
          const Text(
            'G',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Colors.red,
        ), // Google placeholder
        const SizedBox(width: 16),
        circle(
          const Text(
            'A',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Colors.black,
        ), // Apple glyph
      ],
    );
  }
}
