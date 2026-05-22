import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'glass_container.dart';
import 'dart:math' as math;

class SubjectUniversePanel extends StatefulWidget {
  const SubjectUniversePanel({super.key});

  @override
  State<SubjectUniversePanel> createState() => _SubjectUniversePanelState();
}

class _SubjectUniversePanelState extends State<SubjectUniversePanel> with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub, color: AppColors.secondaryNeon),
                const SizedBox(width: 8),
                const Text(
                  'SUBJECT UNIVERSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                const Text(
                  'AI AURA MAPPING',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 250,
                width: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center Core
                    Pulse(
                      infinite: true,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryNeon.withValues(alpha: 0.2),
                          boxShadow: const [
                            BoxShadow(color: AppColors.primaryNeon, blurRadius: 20),
                          ],
                        ),
                        child: const Icon(Icons.school, color: AppColors.primaryNeon, size: 30),
                      ),
                    ),
                    
                    // Orbit 1
                    _buildOrbitCircle(100),
                    // Orbit 2
                    _buildOrbitCircle(180),

                    // Planets
                    _buildPlanet(
                      radius: 100,
                      angleOffset: 0,
                      color: Colors.blueAccent, // Strong
                      label: 'DSA',
                      speedMultiplier: 1.0,
                    ),
                    _buildPlanet(
                      radius: 100,
                      angleOffset: math.pi,
                      color: Colors.redAccent, // Weak
                      label: 'Math',
                      speedMultiplier: 1.0,
                    ),
                    _buildPlanet(
                      radius: 180,
                      angleOffset: math.pi / 2,
                      color: Colors.blueAccent, // Strong
                      label: 'OS',
                      speedMultiplier: 0.6,
                    ),
                    _buildPlanet(
                      radius: 180,
                      angleOffset: 3 * math.pi / 2,
                      color: AppColors.accentPurple, // Neutral/Good
                      label: 'AI',
                      speedMultiplier: 0.6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Strong', Colors.blueAccent),
                const SizedBox(width: 16),
                _buildLegendItem('Focus Required', Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitCircle(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildPlanet({
    required double radius,
    required double angleOffset,
    required Color color,
    required String label,
    required double speedMultiplier,
  }) {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        double angle = (_orbitController.value * 2 * math.pi * speedMultiplier) + angleOffset;
        double x = (radius / 2) * math.cos(angle);
        double y = (radius / 2) * math.sin(angle);

        return Transform.translate(
          offset: Offset(x, y),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(color: color, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
