import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';

class DigitalTwinSimulationScreen extends StatelessWidget {
  const DigitalTwinSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF0F0C29)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                      const Text(
                        "Digital Twin Simulation",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Holographic Twin Visual
                  Center(
                    child: FadeIn(
                      duration: const Duration(seconds: 2),
                      child: Pulse(
                        infinite: true,
                        child: Container(
                          width: 180,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5), width: 2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.2), blurRadius: 40)
                            ],
                            gradient: LinearGradient(
                              colors: [AppColors.primaryNeon.withValues(alpha: 0.2), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, color: AppColors.primaryNeon, size: 100),
                              SizedBox(height: 16),
                              Text("SYNCED: 98%", style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: HolographicCard(
                      glowColor: AppColors.secondaryNeon,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Future Performance Forecast", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildForecastRow("Projected GPA", 0.92, Colors.greenAccent),
                          const SizedBox(height: 12),
                          _buildForecastRow("Burnout Risk", 0.35, Colors.orangeAccent),
                          const SizedBox(height: 12),
                          _buildForecastRow("Skill Evolution Rate", 0.88, AppColors.accentPink),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: HolographicCard(
                      glowColor: Colors.redAccent,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI Simulation Alert", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Text("Current study habits predict a 15% drop in Advanced Algorithms retention by next week. Adjust neural focus.", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        NeonProgressBar(progress: value, color: color, height: 8),
      ],
    );
  }
}
