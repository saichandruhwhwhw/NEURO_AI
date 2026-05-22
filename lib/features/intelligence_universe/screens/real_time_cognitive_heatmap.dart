import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';

class RealTimeCognitiveHeatmap extends StatelessWidget {
  const RealTimeCognitiveHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Thermal gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2A0800), Color(0xFF0F0C29)],
                radius: 1.5,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.orangeAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Cognitive Heatmap",
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                // The Heatmap Grid
                Expanded(
                  child: Center(
                    child: FadeIn(
                      duration: const Duration(seconds: 2),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.1), blurRadius: 40)
                          ],
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 36,
                          itemBuilder: (context, index) {
                            return _buildHeatmapCell(index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Analytics Card
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: HolographicCard(
                      glowColor: Colors.orangeAccent,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thermostat, color: Colors.orangeAccent),
                              SizedBox(width: 8),
                              Text("Thermal Cognitive Load", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("Prefrontal cortex zones (Top-Right) show high thermal load indicating intense problem-solving. Consider a 5-minute cooldown.", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(int index) {
    // Generate a heat value based on index to simulate a hot zone
    double heatValue = 0.2;
    if (index == 10 || index == 11 || index == 16 || index == 17) {
      heatValue = 0.9; // Hot zone
    } else if (index == 4 || index == 5 || index == 9 || index == 22) {
      heatValue = 0.6; // Warm zone
    }

    Color cellColor;
    if (heatValue > 0.8) {
      cellColor = Colors.redAccent;
    } else if (heatValue > 0.5) {
      cellColor = Colors.orangeAccent;
    } else {
      cellColor = AppColors.primaryNeon.withValues(alpha: 0.5);
    }

    return Pulse(
      infinite: true,
      duration: Duration(milliseconds: 1500 + (index * 100)),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor.withValues(alpha: heatValue),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: cellColor.withValues(alpha: heatValue * 0.5), blurRadius: 10)
          ],
        ),
      ),
    );
  }
}
