import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';

class CognitiveEnergyScanner extends StatelessWidget {
  const CognitiveEnergyScanner({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final double focusLevel = studentProvider.studentProfile?['focusLevel']?.toDouble() ?? 88.0;
    final double burnoutProb = studentProvider.burnoutData['burnoutProbability']?.toDouble() ?? 0.35;

    return HolographicCard(
      glowColor: AppColors.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: AppColors.accentPurple),
              const SizedBox(width: 8),
              const Text("Cognitive Energy Scanner", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(15, (index) {
                return _buildAnimatedWave(index, focusLevel, burnoutProb);
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalysisPoint("Focus Drop", focusLevel < 70 ? "Detected" : "None", focusLevel < 70 ? Colors.redAccent : Colors.greenAccent),
              _buildAnalysisPoint("Learning Fatigue", burnoutProb > 0.7 ? "Critical" : (burnoutProb > 0.4 ? "Active" : "Stable"), burnoutProb > 0.7 ? Colors.redAccent : (burnoutProb > 0.4 ? Colors.orangeAccent : Colors.greenAccent)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedWave(int index, double focusLevel, double burnoutProb) {
    // Generate a pseudo-random wave that simulates cognitive instability
    double baseHeight = (index % 3 == 0) ? 80.0 : ((index % 2 == 0) ? 40.0 : 60.0);
    // Scale height by focus and fatigue
    double scale = (focusLevel / 100.0) * (1.0 - (burnoutProb * 0.4));
    double adjustedHeight = baseHeight * scale - (index * 0.5); 
    if (adjustedHeight < 10) adjustedHeight = 10;

    Color waveColor = adjustedHeight < 30 ? Colors.redAccent : AppColors.accentPurple;

    return ElasticInUp(
      delay: Duration(milliseconds: index * 50),
      child: Container(
        width: 8,
        height: adjustedHeight,
        decoration: BoxDecoration(
          color: waveColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: waveColor.withValues(alpha: 0.6),
              blurRadius: 8,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisPoint(String label, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text(status, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
