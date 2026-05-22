import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';

class AiRecoveryEngine extends StatelessWidget {
  const AiRecoveryEngine({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final burnout = studentProvider.burnoutData;
    final String recommendation = burnout['recoveryRecommended'] ?? "System balanced. Continue pacing your study cycles.";

    return HolographicCard(
      glowColor: AppColors.primaryNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa, color: AppColors.primaryNeon),
              const SizedBox(width: 8),
              const Text("AI Recovery Engine", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recommendation,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildRecoveryTask(Icons.self_improvement, "5 Min Guided Breathing", "Reset focus levels"),
          _buildRecoveryTask(Icons.water_drop, "Hydration Break", "Cognitive refresh"),
          _buildRecoveryTask(Icons.nature_people, "Disconnect & Walk", "Physical reset"),
          const SizedBox(height: 20),
          Pulse(
            infinite: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await studentProvider.triggerRecovery();
                  if (context.mounted) {
                    FuturisticToast.show(context, message: "Wellness mode activated: Fatigue parameters flushed.");
                  }
                },
                icon: const Icon(Icons.power_settings_new, color: Colors.white),
                label: const Text("ACTIVATE CALM MODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon.withValues(alpha: 0.3),
                  side: BorderSide(color: AppColors.primaryNeon),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecoveryTask(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryNeon.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryNeon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
