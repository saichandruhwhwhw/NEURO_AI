import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';

class EmotionalStabilityAnalytics extends StatelessWidget {
  const EmotionalStabilityAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final burnout = studentProvider.burnoutData;
    final double cgpa = studentProvider.studentProfile?['cgpa']?.toDouble() ?? 9.2;
    final double burnoutProb = burnout['burnoutProbability']?.toDouble() ?? 0.35;
    final double studyMinutes = burnout['studyDurationMinutes']?.toDouble() ?? 90.0;

    double confidence = (cgpa / 10.0) * (1.0 - (burnoutProb * 0.15));
    double frustration = burnoutProb * 1.1;
    double overload = (studyMinutes / 480.0).clamp(0.1, 1.0);

    confidence = confidence.clamp(0.0, 1.0);
    frustration = frustration.clamp(0.0, 1.0);

    return HolographicCard(
      glowColor: AppColors.secondaryNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves, color: AppColors.secondaryNeon),
              const SizedBox(width: 8),
              const Text("Emotional Stability", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildEmotionAura("Confidence Level", confidence, confidence > 0.75 ? Colors.greenAccent : Colors.orangeAccent),
          const SizedBox(height: 16),
          _buildEmotionAura("Frustration Pattern", frustration, frustration > 0.6 ? Colors.redAccent : Colors.orangeAccent),
          const SizedBox(height: 16),
          _buildEmotionAura("Mental Overload", overload, overload > 0.7 ? Colors.redAccent : Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildEmotionAura(String label, double value, Color glowColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: glowColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        NeonProgressBar(progress: value, color: glowColor, height: 10),
      ],
    );
  }
}
