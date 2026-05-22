import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../dashboard/widgets/ai_recommendation_widget.dart';


import '../../placement_predictor/screens/placement_readiness_screen.dart';

class AiRecommendationScreen extends StatelessWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 800),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlacementReadinessScreen()),
            );
          },
          backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
          icon: const Icon(Icons.rocket_launch, color: Colors.greenAccent),
          label: const Text("Run Placement Analyzer", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.greenAccent),
          ),
        ),
      ),
      body: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              "AI Recommendations",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Personalized study plans & learning paths",
              style: TextStyle(
                color: AppColors.primaryNeon.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Floating AI Assistant Orb
          Center(
            child: FadeIn(
              duration: const Duration(seconds: 2),
              child: _buildFloatingOrb(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Original AI Recommendations
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: const AiRecommendationWidget(),
          ),
          
          const SizedBox(height: 24),
          
          // Smart Path Generator
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: HolographicCard(
              glowColor: AppColors.secondaryNeon,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.route, color: AppColors.secondaryNeon),
                      const SizedBox(width: 8),
                      const Text("Smart Learning Path", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPathStep("1", "Review Quantum Physics notes", true),
                  _buildPathStep("2", "Take simulated mock exam", false),
                  _buildPathStep("3", "Read new article on AI ethics", false),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryNeon.withValues(alpha: 0.2),
                        side: BorderSide(color: AppColors.secondaryNeon),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Generate New Path", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget _buildFloatingOrb() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)), // simple float
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryNeon.withValues(alpha: 0.8),
                  AppColors.primaryNeon.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNeon.withValues(alpha: 0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.smart_toy, color: Colors.white, size: 50),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPathStep(String step, String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.secondaryNeon : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryNeon),
            ),
            child: Center(child: Text(step, style: TextStyle(color: isCompleted ? Colors.black : Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.white54 : Colors.white,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
