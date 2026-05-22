import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/placement_score_meter.dart';
import '../widgets/skill_intelligence_scanner.dart';
import '../widgets/ai_career_predictor.dart';
import '../widgets/resume_intelligence_analyzer.dart';
import '../widgets/interview_simulation_engine.dart';
import '../widgets/smart_placement_insights.dart';

class PlacementReadinessScreen extends StatelessWidget {
  const PlacementReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Holographic dark background with cyan/purple hints
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF1B263B), Color(0xFF0F0C29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                      Expanded(
                        child: Text(
                          "AI Recruitment Engine",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Text(
                      "Next-generation placement analyzer",
                      style: TextStyle(
                        color: Colors.greenAccent.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Smart Insights
                  const SmartPlacementInsights(),
                  const SizedBox(height: 32),
                  
                  // Score Meter
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: const PlacementScoreMeter(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Skill Scanner
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: const SkillIntelligenceScanner(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Career Predictor
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: const AiCareerPredictor(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resume Analyzer
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: const ResumeIntelligenceAnalyzer(),
                  ),
                  const SizedBox(height: 24),

                  // Interview Simulation
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: const InterviewSimulationEngine(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
