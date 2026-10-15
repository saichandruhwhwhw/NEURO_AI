import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import 'glass_container.dart';

class BrainMirrorPanel extends StatelessWidget {
  const BrainMirrorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final profile = studentProvider.studentProfile;
    final burnoutData = studentProvider.burnoutData;
    
    double cognitiveScore = profile?['cognitiveScore']?.toDouble() ?? 94.2;
    double focusLevel = profile?['focusLevel']?.toDouble() ?? 88.0;
    
    double confidence = cognitiveScore > 0 ? (cognitiveScore / 100.0).clamp(0.0, 1.0) : 0.85;
    double concentration = (focusLevel / 100.0).clamp(0.0, 1.0);
    double overload = burnoutData['burnoutProbability']?.toDouble() ?? 0.35;
    double emotionalStability = ((confidence * 0.6) + (concentration * 0.4)).clamp(0.0, 1.0);

    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppColors.accentPink),
                const SizedBox(width: 8),
                const Text(
                  'BRAIN MIRROR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'LIVE SYNC',
                    style: TextStyle(color: AppColors.accentPink, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 500;
                return isWide 
                  ? Row(
                      children: [
                        Expanded(child: _buildBrainHologram()),
                        Expanded(child: _buildStatsList(confidence, concentration, overload, emotionalStability)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildBrainHologram(),
                        const SizedBox(height: 24),
                        _buildStatsList(confidence, concentration, overload, emotionalStability),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainHologram() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Pulse(
            infinite: true,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPink.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Icon(
            Icons.psychology_alt,
            size: 100,
            color: AppColors.primaryNeon.withValues(alpha: 0.8),
            shadows: const [
              Shadow(color: AppColors.primaryNeon, blurRadius: 20),
              Shadow(color: AppColors.accentPink, blurRadius: 40),
            ],
          ),
          // Simulate neural nodes
          Positioned(
            top: 20,
            right: 40,
            child: Pulse(
              infinite: true,
              duration: const Duration(milliseconds: 1500),
              child: const CircleAvatar(radius: 4, backgroundColor: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 50,
            child: Pulse(
              infinite: true,
              duration: const Duration(milliseconds: 1200),
              child: const CircleAvatar(radius: 5, backgroundColor: AppColors.secondaryNeon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(double confidence, double concentration, double overload, double emotionalStability) {
    return Column(
      children: [
        _buildStatRow('Confidence Level', confidence, AppColors.primaryNeon),
        const SizedBox(height: 16),
        _buildStatRow('Concentration', concentration, AppColors.secondaryNeon),
        const SizedBox(height: 16),
        _buildStatRow('Mental Overload', overload, Colors.orangeAccent),
        const SizedBox(height: 16),
        _buildStatRow('Emotional Stability', emotionalStability, AppColors.accentPink),
      ],
    );
  }

  Widget _buildStatRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  height: 4,
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
