import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/glass_container.dart';

class SkillGapScreen extends StatefulWidget {
  const SkillGapScreen({super.key});

  @override
  State<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends State<SkillGapScreen> {
  bool _isGenerating = false;
  List<String> _generatedSteps = [];

  void _generateRoadmap(List<String> missingSkills) async {
    setState(() {
      _isGenerating = true;
      _generatedSteps.clear();
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generatedSteps = missingSkills.map((skill) {
          return "Complete module: Advanced Training for $skill (Duration: 2 weeks)";
        }).toList();
      });
      FuturisticToast.show(context, message: "AI Roadmap generated based on missing core skills.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    
    // Extract current student skills
    List<dynamic> currentSkillsRaw = studentProvider.skillsData['skillsList'] ?? ['Python', 'SQL', 'TensorFlow', 'Data Visualizations'];
    List<String> currentSkills = currentSkillsRaw.map((s) => s.toString()).toList();

    // Extract missing skills
    List<dynamic> missingSkillsRaw = studentProvider.skillsData['missingSkills'] ?? ['Machine Learning Deployment', 'Cloud Architecture', 'Big Data Engineering'];
    List<String> missingSkills = missingSkillsRaw.map((s) => s.toString()).toList();

    String targetRole = studentProvider.studentProfile?['targetRole'] ?? 'Data Scientist';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF1F4068), Colors.black],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
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
                        "AI Skill Gap Analyzer",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Targets Header
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TARGET ROLE PROFILE", style: TextStyle(color: AppColors.primaryNeon, fontSize: 10, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(targetRole.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Skill comparisons grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: HolographicCard(
                          glowColor: Colors.greenAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Current Skills", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...currentSkills.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: HolographicCard(
                          glowColor: Colors.redAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Missing Skills", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...missingSkills.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : () => _generateRoadmap(missingSkills),
                      icon: const Icon(Icons.route, color: Colors.black),
                      label: const Text("GENERATE UPLINK ROADMAP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNeon,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Roadmap steps
                  if (_isGenerating)
                    const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
                  else if (_generatedSteps.isNotEmpty)
                    FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ROADMAP BLUEPRINT", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                          const SizedBox(height: 16),
                          ..._generatedSteps.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: AppColors.primaryNeon, shape: BoxShape.circle),
                                    child: Text("${idx + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GlassContainer(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(step, style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
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
}
