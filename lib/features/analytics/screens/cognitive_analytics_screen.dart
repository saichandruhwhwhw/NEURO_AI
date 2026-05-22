import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/brain_mirror_panel.dart';
import '../../dashboard/widgets/ai_metrics_grid.dart';
import '../../focus_detection/screens/focus_detection_screen.dart';

class CognitiveAnalyticsScreen extends StatelessWidget {
  const CognitiveAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final profile = studentProvider.studentProfile;
    
    // Dynamic values
    final double focusLevel = (profile?['focusLevel']?.toDouble() ?? 88.0) / 100.0;
    
    double avgRetention = 0.78;
    if (studentProvider.memoryTopics.isNotEmpty) {
      double totalRetention = 0.0;
      for (var topic in studentProvider.memoryTopics) {
        totalRetention += (topic['retentionPercent']?.toDouble() ?? 78.0);
      }
      avgRetention = (totalRetention / studentProvider.memoryTopics.length) / 100.0;
    }

    double emotionalStability = 0.92;
    if (profile != null) {
      double cog = profile['cognitiveScore']?.toDouble() ?? 94.2;
      emotionalStability = ((cog * 0.6) + (focusLevel * 100.0 * 0.4)) / 100.0;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 800),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FocusDetectionScreen()),
            );
          },
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
          icon: const Icon(Icons.psychology, color: Colors.cyanAccent),
          label: const Text("Run Cognitive Scan", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                "Cognitive Analytics",
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
                "Real-time AI scanning of your cognitive states",
                style: TextStyle(
                  color: AppColors.primaryNeon.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // AI Brain Hologram and Cognitive Load
            const BrainMirrorPanel(),
            
            const SizedBox(height: 24),
            
            // Cognitive Scores
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: const AiMetricsGrid(), // Reusing this for general metrics
            ),
            
            const SizedBox(height: 24),
            
            // Emotional Stability & Focus Tracker
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: HolographicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: AppColors.secondaryNeon),
                        const SizedBox(width: 8),
                        const Text(
                          "Focus & Emotional Stability",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTrackRow("Current Focus Level", focusLevel, AppColors.primaryNeon),
                    const SizedBox(height: 16),
                    _buildTrackRow("Emotional Stability", emotionalStability, AppColors.secondaryNeon),
                    const SizedBox(height: 16),
                    _buildTrackRow("Memory Retention", avgRetention, AppColors.accentPink),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackRow(String title, double progress, Color glow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text("${(progress * 100).toInt()}%", style: TextStyle(color: glow, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        NeonProgressBar(progress: progress, color: glow),
      ],
    );
  }
}
