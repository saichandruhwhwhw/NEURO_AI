import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/providers/student_provider.dart';

class PlacementScoreMeter extends StatelessWidget {
  const PlacementScoreMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final double placementProb = (provider.placementData['placementProbability']?.toDouble() ?? 0.82) * 100;
        final int aptitudeScore = provider.placementData['aptitudeScore']?.toInt() ?? 85;
        final double cgpa = provider.studentProfile?['cgpa']?.toDouble() ?? 9.2;
        
        String probabilityText = "High Probability";
        Color probabilityColor = Colors.greenAccent;
        if (placementProb < 50) {
          probabilityText = "Low Probability";
          probabilityColor = Colors.redAccent;
        } else if (placementProb < 80) {
          probabilityText = "Moderate Probability";
          probabilityColor = Colors.orangeAccent;
        }

        return HolographicCard(
          glowColor: probabilityColor,
          child: Column(
            crossAxisAlignment: SystemMouseCursors.click == null ? CrossAxisAlignment.center : CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars_rounded, color: probabilityColor, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "Placement Readiness",
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
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: probabilityColor.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: placementProb / 100.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, double value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          backgroundColor: probabilityColor.withValues(alpha: 0.1),
                          color: probabilityColor,
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${placementProb.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                      Text(probabilityText, style: TextStyle(color: probabilityColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildStatRow("AI Recommendation Index", "${(placementProb * 1.08).clamp(0, 100).toInt()}%", probabilityColor),
              const SizedBox(height: 16),
              _buildStatRow("Aptitude Test Score", "$aptitudeScore/100", AppColors.primaryNeon),
              const SizedBox(height: 16),
              _buildStatRow("Academic Performance (CGPA)", "$cgpa/10.0", Colors.purpleAccent),
            ],
          ),
        );
      },
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
