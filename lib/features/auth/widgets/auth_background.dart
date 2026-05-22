import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF04080F),
                Color(0xFF071526),
                Color(0xFF101930),
                Color(0xFF0A0F1F),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _NeuralPulsePainter(_controller.value),
              );
            },
          ),
        ),
        const Positioned.fill(
          child: _GlowingParticles(),
        ),
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderBadge(label: 'AI-DRIVEN INTELLIGENCE', accent: AppColors.primaryNeon),
              _HeaderBadge(label: 'CYBERPUNK OS 2035', accent: AppColors.accentPurple),
            ],
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final Color accent;

  const _HeaderBadge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          letterSpacing: 1.2,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GlowingParticles extends StatelessWidget {
  const _GlowingParticles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(top: 120, left: 40, child: _Particle(size: 16, opacity: 0.18)),
        Positioned(top: 90, right: 50, child: _Particle(size: 10, opacity: 0.22)),
        Positioned(bottom: 180, left: 90, child: _Particle(size: 14, opacity: 0.14)),
        Positioned(bottom: 80, right: 60, child: _Particle(size: 20, opacity: 0.16)),
        Positioned(bottom: 220, right: 180, child: _Particle(size: 12, opacity: 0.20)),
      ],
    );
  }
}

class _Particle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Particle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyan.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: opacity * 2),
            blurRadius: size * 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _NeuralPulsePainter extends CustomPainter {
  final double progress;

  _NeuralPulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F2FE), Color(0xFF8A2BE2), Color(0xFF38D9FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final offset = Offset(size.width * 0.15, size.height * 0.35);
    for (var i = 0; i < 5; i++) {
      final radius = 60.0 + (i * 46) + sin((progress * pi * 2) + i) * 10;
      canvas.drawCircle(offset, radius, paint);
    }

    final connector = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;

    canvas.drawLine(offset.translate(0, 5), Offset(size.width * 0.5, size.height * 0.2), connector);
    canvas.drawLine(offset.translate(0, -8), Offset(size.width * 0.9, size.height * 0.44), connector);
    canvas.drawLine(offset.translate(0, 8), Offset(size.width * 0.72, size.height * 0.78), connector);
  }

  @override
  bool shouldRepaint(covariant _NeuralPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
