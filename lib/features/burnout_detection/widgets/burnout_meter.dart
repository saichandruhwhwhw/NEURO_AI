import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';

class BurnoutMeter extends StatelessWidget {
  const BurnoutMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final burnout = studentProvider.burnoutData;
    final double prob = burnout['burnoutProbability']?.toDouble() ?? 0.35;
    final double scorePercent = prob * 100;
    
    Color glowColor = Colors.greenAccent;
    String riskLevel = "Low Risk";
    if (scorePercent > 70) {
      glowColor = Colors.redAccent;
      riskLevel = "Critical Risk";
    } else if (scorePercent > 40) {
      glowColor = Colors.orangeAccent;
      riskLevel = "Moderate Risk";
    }

    // Dynamic stats
    String fatigueText = scorePercent > 70 ? "Critical" : (scorePercent > 40 ? "High" : "Nominal");
    double prodScore = burnout['productivityScore']?.toDouble() ?? 85.0;
    String prodStability = prodScore > 75 ? "Stable" : "Declining";
    double focusLevel = studentProvider.studentProfile?['focusLevel']?.toDouble() ?? 88.0;
    String energyText = focusLevel > 75 ? "Optimal" : (focusLevel > 50 ? "Balanced" : "Low");

    return HolographicCard(
      glowColor: glowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: glowColor, size: 28),
              const SizedBox(width: 8),
              const Text(
                "AI Burnout Risk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              Pulse(
                infinite: true,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: prob),
                  duration: const Duration(seconds: 2),
                  builder: (context, double value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: glowColor.withValues(alpha: 0.1),
                      color: glowColor,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Column(
                children: [
                  Text("${scorePercent.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  Text(riskLevel, style: TextStyle(color: glowColor, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatRow("Mental Fatigue", fatigueText, glowColor),
          const SizedBox(height: 12),
          _buildStatRow("Productivity Stability", "$prodStability (${prodScore.toInt()}%)", prodScore > 75 ? Colors.greenAccent : Colors.orangeAccent),
          const SizedBox(height: 12),
          _buildStatRow("Cognitive Energy", "$energyText (${focusLevel.toInt()}%)", focusLevel > 75 ? Colors.cyanAccent : Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
