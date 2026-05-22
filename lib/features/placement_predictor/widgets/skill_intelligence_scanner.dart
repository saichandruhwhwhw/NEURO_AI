import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/providers/student_provider.dart';

class SkillIntelligenceScanner extends StatelessWidget {
  const SkillIntelligenceScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        List<dynamic> currentSkillsRaw = provider.skillsData['skillsList'] ?? ['Python', 'SQL', 'TensorFlow', 'Data Visualizations'];
        List<String> currentSkills = currentSkillsRaw.map((s) => s.toString()).toList();

        // Compute strengths based on skill presence
        double codingStrength = currentSkills.contains('Python') || currentSkills.contains('Java') || currentSkills.contains('C++') ? 0.92 : 0.60;
        double aiStrength = currentSkills.contains('TensorFlow') || currentSkills.contains('Machine Learning') ? 0.88 : 0.40;
        double databaseStrength = currentSkills.contains('SQL') ? 0.85 : 0.50;
        double cloudStrength = currentSkills.contains('Cloud Architecture') ? 0.90 : 0.30;

        return HolographicCard(
          glowColor: AppColors.primaryNeon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, color: AppColors.primaryNeon),
                  const SizedBox(width: 8),
                  const Text("Skill Intelligence Scanner", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              const Text("NEURAL SKILL METRICS", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _buildSkillRing("Software Engineering / Coding", codingStrength, AppColors.primaryNeon),
              const SizedBox(height: 16),
              _buildSkillRing("Artificial Intelligence / ML", aiStrength, Colors.greenAccent),
              const SizedBox(height: 16),
              _buildSkillRing("Data Engineering / DB", databaseStrength, Colors.orangeAccent),
              const SizedBox(height: 16),
              _buildSkillRing("Cloud & Systems Architecture", cloudStrength, Colors.purpleAccent),
              const SizedBox(height: 24),
              
              const Text("ACTIVE DOMAIN SKILLS", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentSkills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Colors.greenAccent, size: 12),
                        const SizedBox(width: 4),
                        Text(s, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillRing(String label, double value, Color glowColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: glowColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        NeonProgressBar(progress: value, color: glowColor, height: 8),
      ],
    );
  }
}
