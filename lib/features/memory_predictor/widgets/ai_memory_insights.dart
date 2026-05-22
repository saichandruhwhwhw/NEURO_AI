import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/widgets/glass_container.dart';

class AiMemoryInsights extends StatelessWidget {
  const AiMemoryInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1100),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppColors.primaryNeon),
                const SizedBox(width: 10),
                const Text(
                  'AI MEMORY INSIGHTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome, color: AppColors.accentPink, size: 18),
              ],
            ),
            const SizedBox(height: 20),
            _buildInsight(
              text: 'Retention stability improved by 40% after your last spaced repetition session.',
              icon: Icons.trending_up,
              delay: 200,
            ),
            const SizedBox(height: 12),
            _buildInsight(
              text: 'Frequent recall quizzes are increasing your overall memory strength score to A+.',
              icon: Icons.score,
              delay: 400,
            ),
            const SizedBox(height: 12),
            _buildInsight(
              text: 'Topic understanding in "Algorithms" is highly stable (94% recall rate).',
              icon: Icons.check_circle_outline,
              delay: 600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsight({required String text, required IconData icon, required int delay}) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryNeon.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: AppColors.primaryNeon.withValues(alpha: 0.5), width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryNeon, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
