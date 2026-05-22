import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';

class AiRecommendationWidget extends StatelessWidget {
  const AiRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final recommendations = studentProvider.recommendations;

    return FadeInUp(
      duration: const Duration(milliseconds: 1100),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pulse(
                  infinite: true,
                  child: const Icon(Icons.auto_awesome, color: AppColors.primaryNeon),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI RECOMMENDATION ENGINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryNeon,
                  child: Icon(Icons.smart_toy, size: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recommendations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "Calibrating neural inputs... No recommendations currently.",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              )
            else
              ...List.generate(recommendations.length, (index) {
                final rec = recommendations[index];
                final text = rec['recommendationText'] ?? '';
                final type = rec['type'] ?? 'academic';
                
                IconData icon;
                Color color;
                String categoryTitle;
                
                if (type == 'wellness') {
                  icon = Icons.spa_rounded;
                  color = Colors.orangeAccent;
                  categoryTitle = 'Wellness Recommendation';
                } else if (type == 'career') {
                  icon = Icons.work_outline;
                  color = Colors.greenAccent;
                  categoryTitle = 'Career Growth';
                } else {
                  icon = Icons.psychology;
                  color = AppColors.secondaryNeon;
                  categoryTitle = 'Academic Focus';
                }

                return Column(
                  children: [
                    if (index > 0) const Divider(color: Colors.white10),
                    _RecommendationItem(
                      text: categoryTitle,
                      subtext: text,
                      icon: icon,
                      color: color,
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;
  final String subtext;
  final IconData icon;
  final Color color;

  const _RecommendationItem({
    required this.text,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.2), size: 14),
        ],
      ),
    );
  }
}
