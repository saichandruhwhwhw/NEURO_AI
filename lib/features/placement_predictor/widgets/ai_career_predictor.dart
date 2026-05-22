import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/providers/student_provider.dart';

class AiCareerPredictor extends StatelessWidget {
  const AiCareerPredictor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final String targetRole = provider.skillsData['targetRole'] ?? provider.studentProfile?['targetRole'] ?? 'Data Scientist';
        final List<dynamic> suggestionsRaw = provider.placementData['careerSuggestions'] ?? ['AI Research Associate', 'Quantitative Analyst', 'Data Engineer'];
        final List<String> suggestions = suggestionsRaw.map((s) => s.toString()).toList();
        final double placementProb = (provider.placementData['placementProbability']?.toDouble() ?? 0.82) * 100;

        return HolographicCard(
          glowColor: Colors.purpleAccent,
          child: Column(
            crossAxisAlignment: SystemMouseCursors.click == null ? CrossAxisAlignment.start : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.work_outline, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  const Text("AI Career Prediction", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: FadeIn(
                  duration: const Duration(seconds: 2),
                  child: _buildHolographicGlobe(targetRole),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Target Career Pathway", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              _buildRoleCard(targetRole, "${placementProb.toInt()}% Match", Colors.purpleAccent, true),
              const SizedBox(height: 16),
              if (suggestions.isNotEmpty) ...[
                const Text("Alternative AI Recommendations", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                ...suggestions.map((role) {
                  // Generate minor variance in match %
                  double matchVal = (placementProb - 5 - (suggestions.indexOf(role) * 7)).clamp(40.0, 99.0);
                  return _buildRoleCard(role, "${matchVal.toInt()}% Match", AppColors.primaryNeon, false);
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHolographicGlobe(String role) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.purpleAccent.withValues(alpha: 0.8),
            Colors.purpleAccent.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.6),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 40),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                role.split(' ').first,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String match, Color color, bool isPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.08),
          border: Border.all(color: isPrimary ? color : color.withValues(alpha: 0.3), width: isPrimary ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                role,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(match, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
