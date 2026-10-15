import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/holographic_brain_scan.dart';
import '../widgets/memory_stability_meter.dart';
import '../widgets/topic_decay_prediction.dart';
import '../widgets/smart_revision_engine.dart';
import '../widgets/neural_memory_graph.dart';
import '../widgets/ai_memory_insights.dart';

class MemoryPredictorScreen extends StatelessWidget {
  const MemoryPredictorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cyberpunk/Neural Background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0xFF2B1055), // Deep space purple
                AppColors.background,
              ],
              center: Alignment.topCenter,
              radius: 1.5,
            ),
          ),
        ),
        // Scrollable Content
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_alt, color: AppColors.primaryNeon, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI LABORATORY',
                            style: TextStyle(
                              color: AppColors.primaryNeon.withValues(alpha: 0.7),
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const Text(
                            'MEMORY SCANNER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const HolographicBrainScan(),
                const SizedBox(height: 30),
                const MemoryStabilityMeter(),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    if (isWide) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: TopicDecayPrediction()),
                          SizedBox(width: 24),
                          Expanded(child: SmartRevisionEngine()),
                        ],
                      );
                    }
                    return const Column(
                      children: [
                        TopicDecayPrediction(),
                        SizedBox(height: 24),
                        SmartRevisionEngine(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const NeuralMemoryGraph(),
                const SizedBox(height: 24),
                const AiMemoryInsights(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
