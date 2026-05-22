import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math' as math;

class HolographicBrainScan extends StatefulWidget {
  const HolographicBrainScan({super.key});

  @override
  State<HolographicBrainScan> createState() => _HolographicBrainScanState();
}

class _HolographicBrainScanState extends State<HolographicBrainScan> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(seconds: 1),
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing Base
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryNeon.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
              
              // Brain Icon as the holographic core
              Pulse(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Icon(
                  Icons.psychology,
                  size: 160,
                  color: AppColors.primaryNeon.withValues(alpha: 0.7),
                  shadows: const [
                    Shadow(color: AppColors.primaryNeon, blurRadius: 30),
                    Shadow(color: AppColors.secondaryNeon, blurRadius: 60),
                  ],
                ),
              ),

              // Scanning Laser
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return Positioned(
                    top: 20 + (200 * _scanController.value),
                    child: Container(
                      width: 180,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.8),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.primaryNeon.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Neural particles (simulated with tiny dots)
              ...List.generate(15, (index) {
                return _buildFloatingParticle(index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final math.Random random = math.Random(index);
    final double initialX = (random.nextDouble() * 200) - 100;
    final double initialY = (random.nextDouble() * 200) - 100;
    final double size = random.nextDouble() * 4 + 2;
    
    return Positioned(
      left: 125 + initialX,
      top: 125 + initialY,
      child: Pulse(
        infinite: true,
        duration: Duration(milliseconds: 1000 + random.nextInt(2000)),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: index % 2 == 0 ? AppColors.primaryNeon : AppColors.accentPink,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
