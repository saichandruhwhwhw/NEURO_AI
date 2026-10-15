import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/student_provider.dart';
import 'glass_container.dart';
import '../../../core/theme/app_colors.dart';

class AiRecommendationWidget extends StatelessWidget {
  const AiRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final recs = provider.recommendations.isNotEmpty 
        ? provider.recommendations.take(3).toList() 
        : [
            {'recommendationText': 'Revise Operating Systems (High probability of upcoming quiz topics).', 'type': 'academic'},
            {'recommendationText': 'Focus level dropping. Recommend a 10-minute neural reset break.', 'type': 'wellness'},
            {'recommendationText': 'Practice more DSA problems. Your current mastery is 68%. Goal is 85%.', 'type': 'skill'},
          ];

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
                const Expanded(
                  child: Text(
                    'AI RECOMMENDATION ENGINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryNeon,
                  child: Icon(Icons.smart_toy, size: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...recs.map((rec) {
              String text = rec['recommendationText'] ?? '';
              String type = rec['type'] ?? 'academic';
              IconData icon = Icons.info_outline;
              Color color = AppColors.primaryNeon;
              
              if (type == 'wellness') {
                icon = Icons.warning_amber_rounded;
                color = Colors.orangeAccent;
              } else if (type == 'skill') {
                icon = Icons.code;
                color = AppColors.accentPurple;
              } else if (type == 'academic') {
                icon = Icons.menu_book_rounded;
                color = AppColors.secondaryNeon;
              }

              return Column(
                children: [
                  _RecommendationItem(
                    text: type.toUpperCase(),
                    subtext: text,
                    icon: icon,
                    color: color,
                  ),
                  if (rec != recs.last) const Divider(color: Colors.white10),
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
