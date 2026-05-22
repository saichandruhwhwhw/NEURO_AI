import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';

class ResumeIntelligenceAnalyzer extends StatefulWidget {
  const ResumeIntelligenceAnalyzer({super.key});

  @override
  State<ResumeIntelligenceAnalyzer> createState() => _ResumeIntelligenceAnalyzerState();
}

class _ResumeIntelligenceAnalyzerState extends State<ResumeIntelligenceAnalyzer> {
  bool _isProcessing = false;

  void _showUpdateModal(BuildContext context, StudentProvider provider) {
    List<dynamic> currentSkillsRaw = provider.skillsData['skillsList'] ?? ['Python', 'SQL', 'TensorFlow', 'Data Visualizations'];
    List<String> userSkills = List<String>.from(currentSkillsRaw.map((s) => s.toString()));

    String currentRole = provider.skillsData['targetRole'] ?? provider.studentProfile?['targetRole'] ?? 'Data Scientist';
    double aptitude = (provider.placementData['aptitudeScore'] ?? 85).toDouble();
    String fileName = provider.placementData['resumeUrl'] ?? 'sample_resume.pdf';

    final List<String> availableSkills = [
      'Python', 'SQL', 'TensorFlow', 'Data Visualizations', 'Machine Learning Deployment',
      'Cloud Architecture', 'React', 'HTML', 'CSS', 'C++', 'Java'
    ];
    final List<String> availableRoles = ['Data Scientist', 'AI Specialist', 'Software Engineer', 'Cloud Architect'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF141235),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AppColors.secondaryNeon, width: 2),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.document_scanner, color: AppColors.secondaryNeon),
                        const SizedBox(width: 8),
                        Text(
                          "AI Profile & Resume Simulator",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Update core metrics to run predictive recruitment forecasting",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Target Role
                    const Text("TARGET PATHWAY", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentRole,
                          dropdownColor: const Color(0xFF141235),
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: availableRoles.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                currentRole = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Aptitude Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("APTITUDE RATING", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        Text("${aptitude.toInt()}/100", style: const TextStyle(color: AppColors.secondaryNeon, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: aptitude,
                      min: 0,
                      max: 100,
                      activeColor: AppColors.secondaryNeon,
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setModalState(() {
                          aptitude = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Resume Filename
                    const Text("RESUME DOCUMENT FILE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: fileName),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        prefixIcon: const Icon(Icons.file_present_rounded, color: AppColors.secondaryNeon),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.secondaryNeon), borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) {
                        fileName = val;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Skills Checklist
                    const Text("CORE CAPABILITIES", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: availableSkills.map((skill) {
                        bool hasSkill = userSkills.contains(skill);
                        return ChoiceChip(
                          label: Text(skill),
                          selected: hasSkill,
                          selectedColor: AppColors.secondaryNeon.withValues(alpha: 0.3),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          labelStyle: TextStyle(color: hasSkill ? AppColors.secondaryNeon : Colors.white70, fontSize: 12),
                          side: BorderSide(color: hasSkill ? AppColors.secondaryNeon : Colors.transparent),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                userSkills.add(skill);
                              } else {
                                userSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() {
                            _isProcessing = true;
                          });
                          await provider.submitResumeDetails(fileName, userSkills, aptitude);
                          await provider.updateTargetRole(currentRole);
                          if (mounted) {
                            setState(() {
                              _isProcessing = false;
                            });
                            FuturisticToast.show(context, message: "AI Engine recalculation complete.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryNeon,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("EXECUTE PROFILE ANALYSIS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final List<dynamic> missingSkillsRaw = provider.skillsData['missingSkills'] ?? ['Machine Learning Deployment', 'Cloud Architecture', 'Big Data Engineering'];
        final List<String> missingSkills = missingSkillsRaw.map((s) => s.toString()).toList();
        final double placementProb = (provider.placementData['placementProbability']?.toDouble() ?? 0.82) * 100;
        final String fileName = provider.placementData['resumeUrl'] ?? 'sample_resume.pdf';

        return HolographicCard(
          glowColor: AppColors.secondaryNeon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.document_scanner, color: AppColors.secondaryNeon),
                      const SizedBox(width: 8),
                      const Text("Resume Intelligence", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_isProcessing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryNeon),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("CURRENT DOCUMENT:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(fileName, style: const TextStyle(color: AppColors.secondaryNeon, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              if (placementProb < 80 && missingSkills.isNotEmpty) ...[
                _buildAlert(Icons.warning_amber_rounded, "Profile Optimization Advised", "Acquire missing skills: ${missingSkills.take(2).join(', ')}", Colors.orangeAccent),
              ] else ...[
                _buildAlert(Icons.check_circle_outline, "Recruitment Vector Aligned", "No critical skills missing for target path.", Colors.greenAccent),
              ],
              _buildAlert(Icons.tips_and_updates, "Ecosystem Analytics", "Target skills are processed dynamically through the neural scanner.", AppColors.primaryNeon),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateModal(context, provider),
                  icon: const Icon(Icons.settings, color: Colors.white, size: 18),
                  label: const Text("UPDATE METRICS & RESUME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    side: const BorderSide(color: AppColors.secondaryNeon),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlert(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
