import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/glass_container.dart';

class MemoryStabilityMeter extends StatelessWidget {
  const MemoryStabilityMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final topics = studentProvider.memoryTopics;

    double avgRetention = 78.0;
    if (topics.isNotEmpty) {
      double total = 0.0;
      for (var t in topics) {
        total += t['retentionPercent']?.toDouble() ?? 78.0;
      }
      avgRetention = total / topics.length;
    }

    double decayRisk = 100.0 - avgRetention;
    
    // Determine Strength Grade
    String grade = 'B';
    String status = 'MODERATE';
    Color statusColor = Colors.orangeAccent;
    String encodingText = 'Partially Encoded';

    if (avgRetention > 88.0) {
      grade = 'A+';
      status = 'STABLE';
      statusColor = Colors.greenAccent;
      encodingText = 'Highly Encoded';
    } else if (avgRetention > 78.0) {
      grade = 'A';
      status = 'STABLE';
      statusColor = Colors.greenAccent;
      encodingText = 'Strong Encoding';
    } else if (avgRetention < 60.0) {
      grade = 'C';
      status = 'DECAY RISK';
      statusColor = Colors.redAccent;
      encodingText = 'Weak Encoding';
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: AppColors.primaryNeon),
                const SizedBox(width: 10),
                const Text(
                  'MEMORY STABILITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Pulse(
                  infinite: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularMeter(
                  value: avgRetention / 100.0,
                  label: 'Retention',
                  color: AppColors.primaryNeon,
                  subtitle: 'Overall Avg',
                ),
                _buildCircularMeter(
                  value: decayRisk / 100.0,
                  label: 'Decay Risk',
                  color: Colors.orangeAccent,
                  subtitle: 'Probability',
                ),
                _buildScoreIndicator(grade, encodingText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMeter({required double value, required String label, required Color color, required String subtitle}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutCubic,
                builder: (context, double val, child) {
                  return CircularProgressIndicator(
                    value: val,
                    strokeWidth: 6,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                  );
                },
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 15, spreadRadius: 2),
                ],
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: color, blurRadius: 10)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildScoreIndicator(String grade, String subtitle) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Pulse(
              infinite: true,
              child: const Icon(Icons.hexagon_outlined, color: AppColors.accentPurple, size: 90),
            ),
            Text(
              grade,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: AppColors.accentPurple, blurRadius: 15)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Strength Score', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
