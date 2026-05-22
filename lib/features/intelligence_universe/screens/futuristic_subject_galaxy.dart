import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math';

class FuturisticSubjectGalaxy extends StatelessWidget {
  const FuturisticSubjectGalaxy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Galaxy Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                radius: 2.0,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "3D Subject Galaxy",
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildGalaxyNode("Quantum Physics", 0.9, -100, -150, Colors.cyanAccent),
                      _buildGalaxyNode("AI Ethics", 0.6, 120, -80, AppColors.accentPink),
                      _buildGalaxyNode("Data Structures", 0.85, -80, 100, Colors.greenAccent),
                      _buildGalaxyNode("Advanced Calc", 0.4, 100, 150, Colors.redAccent),
                      _buildGalaxyNode("Cybersecurity", 0.75, 0, 0, AppColors.secondaryNeon), // Center
                    ],
                  ),
                ),
                
                FadeInUp(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      "Navigate your knowledge universe. Larger, brighter stars indicate higher mastery levels. Red dwarfs require immediate study focus.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalaxyNode(String name, double mastery, double dx, double dy, Color color) {
    // Mastery determines size and glow
    double size = 40 + (mastery * 40);
    
    return Positioned(
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: FadeIn(
          duration: const Duration(seconds: 2),
          child: Pulse(
            infinite: true,
            duration: Duration(milliseconds: 2000 + Random().nextInt(1000)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: size, spreadRadius: size * 0.2),
                      BoxShadow(color: Colors.white, blurRadius: size * 0.5),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "${(mastery * 100).toInt()}%",
                  style: TextStyle(color: color, fontSize: 10),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
