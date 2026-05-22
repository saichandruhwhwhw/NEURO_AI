import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';

class BrainwaveStudyRecommendation extends StatelessWidget {
  const BrainwaveStudyRecommendation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Neuro-gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C0B40), Color(0xFF0F0C29)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Brainwave Analytics",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Brainwave Visualizer
                  Center(
                    child: FadeIn(
                      duration: const Duration(seconds: 2),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentPurple.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.4), blurRadius: 60, spreadRadius: 10)
                          ],
                          border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.psychology, color: AppColors.accentPurple, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  const Text("Real-Time EEG Feed", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  // Simulated EEG Waves
                  _buildWaveRow("Alpha Waves (Relaxed)", AppColors.secondaryNeon, 40),
                  const SizedBox(height: 12),
                  _buildWaveRow("Beta Waves (Active)", AppColors.primaryNeon, 80),
                  const SizedBox(height: 12),
                  _buildWaveRow("Gamma Waves (Peak)", AppColors.accentPurple, 60),
                  
                  const SizedBox(height: 40),
                  
                  // Recommendation Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: HolographicCard(
                      glowColor: AppColors.accentPurple,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppColors.accentPurple),
                              SizedBox(width: 8),
                              Text("Neural Recommendation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            "High Beta wave activity detected. Your brain is highly active. AI recommends tackling complex mathematical or logical problem-solving tasks right now.",
                            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveRow(String label, Color color, double baseAmplitude) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(40, (index) {
              return ElasticIn(
                duration: Duration(milliseconds: 1000 + (index * 20)),
                child: Container(
                  width: 3,
                  height: (index % 3 == 0) ? baseAmplitude : baseAmplitude * 0.4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
