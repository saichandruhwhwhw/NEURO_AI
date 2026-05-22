import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/glass_container.dart';

class CareerDnaScreen extends StatefulWidget {
  const CareerDnaScreen({super.key});

  @override
  State<CareerDnaScreen> createState() => _CareerDnaScreenState();
}

class _CareerDnaScreenState extends State<CareerDnaScreen> {
  String _selectedInterest = "Data Science";
  bool _isProcessing = false;

  final Map<String, List<String>> _interestRoles = {
    'Data Science': ['Data Scientist', 'AI Research Engineer', 'Quantitative Analyst'],
    'Software Engineering': ['Backend Cloud Developer', 'Systems Engineer', 'Fullstack Architect'],
    'Cyber Security': ['Penetration Tester', 'Security Operations Analyst', 'Cryptographer'],
    'Product Management': ['Technical Product Manager', 'EdTech Solutions Lead', 'Product Owner'],
  };

  void _triggerScan(StudentProvider provider, String interest) async {
    setState(() {
      _isProcessing = true;
      _selectedInterest = interest;
    });

    await Future.delayed(const Duration(seconds: 2));

    // Choose primary role
    String targetRole = _interestRoles[interest]?.first ?? 'Data Scientist';
    await provider.updateTargetRole(targetRole);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      FuturisticToast.show(context, message: "Career DNA Scanned. Core pathway updated: $targetRole");
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    String targetRole = studentProvider.studentProfile?['targetRole'] ?? 'Data Scientist';
    double cgpa = studentProvider.studentProfile?['cgpa']?.toDouble() ?? 9.2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1B263B), Colors.black],
                center: Alignment.center,
                radius: 1.5,
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
                        "AI Career DNA Scanner",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Scanning visualization
                  Center(
                    child: Pulse(
                      infinite: true,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentPink.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.accentPink, width: 2),
                        ),
                        child: Icon(Icons.fingerprint, size: 64, color: AppColors.accentPink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text("MAP YOUR NEURAL INTERESTS", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  
                  // Interest chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _interestRoles.keys.map((interest) {
                      bool isSelected = _selectedInterest == interest;
                      return ChoiceChip(
                        label: Text(interest),
                        selected: isSelected,
                        selectedColor: AppColors.accentPink.withValues(alpha: 0.3),
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(color: isSelected ? AppColors.accentPink : Colors.white),
                        side: BorderSide(color: isSelected ? AppColors.accentPink : Colors.transparent),
                        onSelected: (val) {
                          if (val) _triggerScan(studentProvider, interest);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (_isProcessing)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.accentPink),
                          SizedBox(height: 12),
                          Text("ANALYZING RECRUITMENT GENES...", style: TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else
                    FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HolographicCard(
                            glowColor: AppColors.accentPink,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Career Trajectory Summary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                _buildDnaRow("Primary Target Role", targetRole),
                                const SizedBox(height: 12),
                                _buildDnaRow("Academic Score Alignment", "${(cgpa * 10).toInt()}%"),
                                const SizedBox(height: 12),
                                _buildDnaRow("Uplink Match Confidence", "89%"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          const Text("RECOMMENDED JOBS", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                          const SizedBox(height: 12),
                          
                          ...(_interestRoles[_selectedInterest] ?? []).map((role) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const Text("90% Match", style: TextStyle(color: AppColors.accentPink)),
                                  ],
                                ),
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

  Widget _buildDnaRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
