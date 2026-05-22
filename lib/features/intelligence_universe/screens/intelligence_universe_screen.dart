import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'digital_twin_simulation_screen.dart';
import '../widgets/quantum_ranking_system_widget.dart';
import '../widgets/viva_lie_detection_scanner.dart';
import 'holographic_attendance_scanner.dart';
import 'brainwave_study_recommendation.dart';
import 'real_time_cognitive_heatmap.dart';
import 'futuristic_subject_galaxy.dart';
import '../../career_dna/screens/career_dna_screen.dart';
import '../../skill_gap/screens/skill_gap_screen.dart';
import '../../focus_detection/screens/focus_detection_screen.dart';
import '../../study_planner/screens/study_planner_screen.dart';
import '../../cognitive_battle/screens/cognitive_battle_arena_screen.dart';

class IntelligenceUniverseScreen extends StatelessWidget {
  const IntelligenceUniverseScreen({super.key});

  final List<String> _featureNames = const [
    "AI Lie Detection During Viva", "Holographic Attendance Scanner", "Brainwave Study Recommendation",
    "AI Voice Mood Analyzer", "Smart Anti-Procrastination Engine", "Quantum Intelligence Ranking",
    "AI Exam Fear Detector", "Neural Collaboration Rooms", "Real-Time Cognitive Heatmap",
    "AI Confidence Stability Meter", "Future Skill Simulator", "Intelligent Distraction Blocker",
    "Knowledge Compression Engine", "Brain Energy Recovery", "Academic Risk Warning",
    "Futuristic 3D Subject Galaxy", "AI Habit Formation Tracker", "Weekly Performance Map",
    "Smart Learning Path Generator", "Career DNA Scanner", "Neural Focus Bubble Mode",
    "Deep Concentration Env", "Curiosity Intelligence Tracker", "Real-Time Motivation Booster",
    "Exam Preparation Simulator", "AI Adaptive Difficulty", "Memory Reinforcement System",
    "AI Skill Gap Analyzer", "Cognitive Performance Timeline", "Productivity Forecast",
    "Learning Pattern Detector", "Sleep vs Productivity Analyzer", "Classroom Behavior Monitor",
    "Digital Twin Simulation", "Communication Skill Analyzer", "Intelligent Coding Tracker",
    "Neural Notification System", "Academic Recovery Planner", "Achievement Showcase",
    "Focus Recovery Mode", "Brain Stability Analytics", "Intelligence Growth Tracker",
    "Mental Load Balancer", "Cognitive Security Shield", "Team Collaboration Analyzer",
    "Research Recommendation Engine", "Project Quality Evaluator", "Learning Efficiency Scanner",
    "Academic Success Meter", "Holographic Intelligence Universe"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Deep galaxy background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1B003A), Color(0xFF0F0C29), Colors.black],
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
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Intelligence Universe",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [BoxShadow(color: AppColors.primaryNeon, blurRadius: 10)],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // The Holographic Grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      return _buildFeatureNode(context, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureNode(BuildContext context, int index) {
    final String featureName = _featureNames[index];
    final bool isFlagship = featureName.contains("Digital Twin") || 
                            featureName.contains("Quantum") || 
                            featureName.contains("Lie Detection") ||
                            featureName.contains("Attendance Scanner") ||
                            featureName.contains("Brainwave Study") ||
                            featureName.contains("Cognitive Heatmap") ||
                            featureName.contains("Subject Galaxy") ||
                            featureName.contains("Career DNA") ||
                            featureName.contains("Skill Gap") ||
                            featureName.contains("Focus Bubble") ||
                            featureName.contains("Neural Collaboration Rooms") ||
                            featureName.contains("Learning Path Generator");

    final Color nodeColor = isFlagship ? AppColors.primaryNeon : AppColors.secondaryNeon;
    
    return FadeInUp(
      delay: Duration(milliseconds: (index % 10) * 50),
      child: GestureDetector(
        onTap: () {
          if (featureName.contains("Digital Twin")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalTwinSimulationScreen()));
          } else if (featureName.contains("Quantum")) {
            _showFlagshipDialog(context, const QuantumRankingSystemWidget(), "Quantum Intelligence Ranking");
          } else if (featureName.contains("Lie Detection")) {
            _showFlagshipDialog(context, const VivaLieDetectionScanner(), "AI Lie Detection During Viva");
          } else if (featureName.contains("Attendance Scanner")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HolographicAttendanceScanner()));
          } else if (featureName.contains("Brainwave Study")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BrainwaveStudyRecommendation()));
          } else if (featureName.contains("Cognitive Heatmap")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RealTimeCognitiveHeatmap()));
          } else if (featureName.contains("Subject Galaxy")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FuturisticSubjectGalaxy()));
          } else if (featureName.contains("Career DNA")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerDnaScreen()));
          } else if (featureName.contains("Skill Gap")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillGapScreen()));
          } else if (featureName.contains("Focus Bubble")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusDetectionScreen()));
          } else if (featureName.contains("Neural Collaboration Rooms")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CognitiveBattleArenaScreen()));
          } else if (featureName.contains("Learning Path Generator")) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlannerScreen()));
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("$featureName module initializing... (Phase 2)")),
             );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: nodeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor.withValues(alpha: isFlagship ? 0.8 : 0.3), width: isFlagship ? 2 : 1),
            boxShadow: isFlagship ? [BoxShadow(color: nodeColor.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFlagship ? Icons.auto_awesome : Icons.science, 
                color: isFlagship ? Colors.white : nodeColor.withValues(alpha: 0.8),
                size: 28,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  featureName,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFlagship ? Colors.white : Colors.white70,
                    fontSize: 10,
                    fontWeight: isFlagship ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFlagshipDialog(BuildContext context, Widget child, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.2), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
