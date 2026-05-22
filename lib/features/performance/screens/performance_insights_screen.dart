import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../dashboard/widgets/subject_universe_panel.dart';
import '../../dashboard/widgets/learning_activity_graph.dart';
import '../../dashboard/widgets/ai_prediction_section.dart';

class PerformanceInsightsScreen extends StatelessWidget {
  const PerformanceInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              "Performance Insights",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Academic performance & AI trend predictions",
              style: TextStyle(
                color: AppColors.secondaryNeon.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Subject Universe Panel for Weak/Strong Subjects
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: const SubjectUniversePanel(),
          ),
          
          const SizedBox(height: 24),
          
          // Activity Graph
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: const LearningActivityGraph(),
          ),
          
          const SizedBox(height: 24),
          
          // AI Predictions
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: const AiPredictionSection(),
          ),
          
          const SizedBox(height: 24),
          
          // Attendance Hologram Placeholder
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: HolographicCard(
              glowColor: AppColors.accentPink,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.co_present_rounded, color: AppColors.accentPink, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Attendance Prediction", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Currently at 92%. AI predicts 95% by end of term.", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
