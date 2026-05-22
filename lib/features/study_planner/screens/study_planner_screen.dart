import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  String _selectedDay = "Monday";
  bool _isOptimizing = false;

  void _optimizeSchedule(StudentProvider provider) async {
    setState(() {
      _isOptimizing = true;
    });

    // Simulate AI algorithmic rescheduling
    await Future.delayed(const Duration(seconds: 2));

    // Dynamic schedule updates
    final Map<String, List<Map<String, String>>> optimizedSchedule = {
      'Monday': [
        {'time': '08:00 - 09:30', 'subject': 'AI Capstone Project (Peak Energy Slot)', 'room': 'Virtual Sandbox'},
        {'time': '10:00 - 11:30', 'subject': 'Quantum Computing', 'room': 'Lab Alpha'},
        {'time': '13:00 - 14:30', 'subject': 'Neural Networks', 'room': 'Lecture Hall B'},
      ],
      'Tuesday': [
        {'time': '09:00 - 10:30', 'subject': 'Memory Consolidation Recap', 'room': 'Library Quiet Zone'},
        {'time': '11:00 - 12:30', 'subject': 'Cloud Engineering', 'room': 'Sandbox Space'},
      ],
      'Wednesday': [
        {'time': '08:30 - 10:00', 'subject': 'Quantum Computing', 'room': 'Lab Alpha'},
        {'time': '13:30 - 15:00', 'subject': 'AI Capstone Project', 'room': 'Nexus Room'},
      ],
      'Thursday': [
        {'time': '10:00 - 11:30', 'subject': 'Neural Networks', 'room': 'Lecture Hall B'},
        {'time': '14:00 - 15:30', 'subject': 'Cognitive Science Seminar', 'room': 'Auditorium C'},
      ],
      'Friday': [
        {'time': '09:00 - 10:30', 'subject': 'Big Data Engineering', 'room': 'Lab Beta'},
        {'time': '13:00 - 15:00', 'subject': 'Career Placement Mock Tests', 'room': 'Placement Nexus'},
      ],
    };

    await provider.updateTimetable(optimizedSchedule);

    if (mounted) {
      setState(() {
        _isOptimizing = false;
      });
      FuturisticToast.show(context, message: "AI Optimizer generated balanced learning schedule.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final rawSchedule = studentProvider.timetableData['schedule'];
    
    // Fallback if no timetable is loaded yet
    Map<String, dynamic> schedule = rawSchedule != null 
        ? Map<String, dynamic>.from(rawSchedule) 
        : {
            'Monday': [
              {'time': '09:00 - 10:30', 'subject': 'Quantum Computing', 'room': 'Lab Alpha'},
            ]
          };

    List<dynamic> daySessions = schedule[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B0B2E), Color(0xFF0F0C29), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                        "AI Study Planner & Optimizer",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Day Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day) {
                        bool isSelected = _selectedDay == day;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedDay = day),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondaryNeon.withValues(alpha: 0.2) : Colors.white10,
                                border: Border.all(color: isSelected ? AppColors.secondaryNeon : Colors.transparent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(day, style: TextStyle(color: isSelected ? AppColors.secondaryNeon : Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Optimize Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isOptimizing ? null : () => _optimizeSchedule(studentProvider),
                      icon: _isOptimizing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.bolt, color: Colors.black),
                      label: const Text("GENERATE COGNITIVE-OPTIMIZED SCHEDULE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryNeon,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text("CURRENT SESSIONS", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  
                  if (daySessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: Text("No academic tracks recorded for this day.", style: TextStyle(color: Colors.white38))),
                    )
                  else
                    ...daySessions.map((session) {
                      var sessionMap = Map<String, dynamic>.from(session);
                      bool isPeak = sessionMap['subject'].toString().contains('Peak');
                      return FadeInUp(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: HolographicCard(
                            glowColor: isPeak ? AppColors.primaryNeon : AppColors.secondaryNeon,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (isPeak ? AppColors.primaryNeon : AppColors.secondaryNeon).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.access_time_filled,
                                    color: isPeak ? AppColors.primaryNeon : AppColors.secondaryNeon,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sessionMap['subject'] ?? 'Self Study Block',
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${sessionMap['time']} | Room: ${sessionMap['room']}",
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
