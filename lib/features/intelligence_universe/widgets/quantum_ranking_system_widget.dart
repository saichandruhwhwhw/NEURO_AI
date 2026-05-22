import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class QuantumRankingSystemWidget extends StatelessWidget {
  const QuantumRankingSystemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRankRow("1", "Alex Chen", 9850, true),
        _buildRankRow("2", "You (Digital Twin)", 9420, false),
        _buildRankRow("3", "Sarah J.", 8900, true),
        _buildRankRow("4", "Neural_Student_X", 8450, true),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryNeon.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryNeon),
              SizedBox(width: 8),
              Expanded(child: Text("Quantum Intelligence score increasing by 45 points/hr.", style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(String rank, String name, int score, bool isOther) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FadeInLeft(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isOther ? Colors.transparent : AppColors.secondaryNeon.withValues(alpha: 0.2),
            border: Border.all(color: isOther ? Colors.white24 : AppColors.secondaryNeon),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text("#$rank", style: TextStyle(color: isOther ? Colors.white54 : AppColors.secondaryNeon, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 16),
              Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
              Text(score.toString(), style: TextStyle(color: isOther ? Colors.white70 : AppColors.secondaryNeon, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
