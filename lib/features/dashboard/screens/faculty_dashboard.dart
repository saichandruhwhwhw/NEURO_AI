import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/faculty_provider.dart';
import '../widgets/glass_container.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  void _showAssignmentModal(BuildContext context, FacultyProvider provider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141235),
                  border: Border.all(color: AppColors.accentPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_add, color: AppColors.accentPurple),
                          SizedBox(width: 8),
                          Text("Deploy Assignment", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      const Text("ASSIGNMENT TITLE", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g., Quantum Computing Basics",
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accentPurple), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("DESCRIPTION", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter objective metrics & guidelines...",
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accentPurple), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("DUE DATE: ${selectedDate.toLocal().toString().substring(0, 10)}", style: const TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Text("CHOOSE", style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) return;
                            Navigator.pop(context);
                            await provider.createAssignment(titleController.text, descController.text, selectedDate);
                            if (context.mounted) {
                              FuturisticToast.show(context, message: "Assignment uploaded & student alerts dispatched.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("BROADCAST TO CLASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChallengeModal(BuildContext context, FacultyProvider provider) {
    final titleController = TextEditingController();
    String selectedSubject = "Artificial Intelligence";
    final subjects = [
      "Artificial Intelligence",
      "Coding & Logic",
      "Quantitative Aptitude",
      "Cognitive Reasoning",
      "Systems Engineering"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141235),
                  border: Border.all(color: Colors.greenAccent, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.hub, color: Colors.greenAccent),
                          SizedBox(width: 8),
                          Text("Deploy Arena Challenge", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      const Text("CHALLENGE TITLE / CODE", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g., Quantum Computing 101",
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.greenAccent), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("SELECT STUDY FOCUS", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSubject,
                            dropdownColor: const Color(0xFF141235),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setStateDialog(() {
                                  selectedSubject = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) return;
                            Navigator.pop(context);
                            await provider.createFacultyChallenge(selectedSubject, titleController.text);
                            if (context.mounted) {
                              FuturisticToast.show(context, message: "Arena Challenge uploaded & broadcast alerts sent.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("LAUNCH CHALLENGE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGradingModal(BuildContext context, FacultyProvider provider, String studentId, String studentName) {
    double score = 85.0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141235),
                  border: Border.all(color: Colors.greenAccent, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Grade $studentName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("QUIZ SCORE", style: TextStyle(color: Colors.white70)),
                        Text("${score.toInt()}/100", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: score,
                      min: 0,
                      max: 100,
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.white10,
                      onChanged: (val) {
                        setStateDialog(() {
                          score = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await provider.submitStudentGrades(studentId, score);
                          if (context.mounted) {
                            FuturisticToast.show(context, message: "Quiz marks saved. Dynamic CGPA updated.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("SUBMIT MARKS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAttendanceModal(BuildContext context, FacultyProvider provider, String studentId, String studentName) {
    String status = "Present";
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141235),
                  border: Border.all(color: AppColors.primaryNeon, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Attendance: $studentName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 24),
                    ListTile(
                      title: const Text("Present", style: TextStyle(color: Colors.white)),
                      leading: Radio<String>(
                        value: "Present",
                        groupValue: status,
                        activeColor: AppColors.primaryNeon,
                        onChanged: (value) => setStateDialog(() => status = value!),
                      ),
                    ),
                    ListTile(
                      title: const Text("Absent", style: TextStyle(color: Colors.white)),
                      leading: Radio<String>(
                        value: "Absent",
                        groupValue: status,
                        activeColor: AppColors.primaryNeon,
                        onChanged: (value) => setStateDialog(() => status = value!),
                      ),
                    ),
                    ListTile(
                      title: const Text("Late", style: TextStyle(color: Colors.white)),
                      leading: Radio<String>(
                        value: "Late",
                        groupValue: status,
                        activeColor: AppColors.primaryNeon,
                        onChanged: (value) => setStateDialog(() => status = value!),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await provider.logStudentAttendance(studentId, studentName, status);
                          if (context.mounted) {
                            FuturisticToast.show(context, message: "Attendance logged as: $status.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNeon,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("LOG ATTENDANCE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAdvisoryModal(BuildContext context, FacultyProvider provider, String studentId, String studentName) {
    final alertController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141235),
              border: Border.all(color: Colors.orangeAccent, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Advisory Alert: $studentName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                const Text("WARNING MESSAGE", style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                TextField(
                  controller: alertController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter warning or academic advice...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.orangeAccent), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (alertController.text.trim().isEmpty) return;
                      Navigator.pop(context);
                      await provider.sendStudentNotificationAlert(studentId, alertController.text);
                      if (context.mounted) {
                        FuturisticToast.show(context, message: "Faculty warning dispatched to student node.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("DISPATCH WARNING", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cyberpunk purple/blue matrix hint
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1B003A), Color(0xFF0F0C29), Colors.black],
                center: Alignment.topRight,
                radius: 1.2,
              ),
            ),
          ),

          SafeArea(
            child: Consumer<FacultyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accentPurple));
                }

                // Filter students
                final List<Map<String, dynamic>> filteredStudents = provider.students.where((student) {
                  final name = (student['fullName'] ?? '').toString().toLowerCase();
                  final sid = (student['studentId'] ?? '').toString().toLowerCase();
                  final searchLower = _searchQuery.toLowerCase();
                  return name.contains(searchLower) || sid.contains(searchLower);
                }).toList();

                // Compute class stats
                double totalCGPA = 0.0;
                double totalCog = 0.0;
                for (var s in provider.students) {
                  totalCGPA += (s['cgpa']?.toDouble() ?? 0.0);
                  totalCog += (s['cognitiveScore']?.toDouble() ?? 0.0);
                }
                double avgCGPA = provider.students.isNotEmpty ? totalCGPA / provider.students.length : 0.0;
                double avgCog = provider.students.isNotEmpty ? totalCog / provider.students.length : 0.0;

                // Heatmap counters
                int countAtRisk = provider.students.where((s) => (s['cognitiveScore']?.toDouble() ?? 0.0) < 65).length;
                int countStable = provider.students.where((s) => (s['cognitiveScore']?.toDouble() ?? 0.0) >= 65 && (s['cognitiveScore']?.toDouble() ?? 0.0) < 85).length;
                int countOptimal = provider.students.where((s) => (s['cognitiveScore']?.toDouble() ?? 0.0) >= 85).length;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Faculty Monitor Node",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Academic control portal and student analytics console",
                                style: TextStyle(color: AppColors.accentPurple, fontSize: 14),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Classroom Insights Card
                      FadeInUp(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.query_stats, color: AppColors.primaryNeon),
                                  SizedBox(width: 8),
                                  Text("AI Classroom Diagnostic", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                provider.calculateClassInsights(),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: HolographicCard(
                              glowColor: AppColors.accentPurple,
                              child: Column(
                                children: [
                                  const Text("Class Size", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text("${provider.students.length}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HolographicCard(
                              glowColor: Colors.greenAccent,
                              child: Column(
                                children: [
                                  const Text("Class Avg CGPA", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text(avgCGPA.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HolographicCard(
                              glowColor: AppColors.primaryNeon,
                              child: Column(
                                children: [
                                  const Text("Class Avg Cog", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text("${avgCog.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action bar: Deploy assignment
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAssignmentModal(context, provider),
                          icon: const Icon(Icons.assignment_add, color: Colors.white),
                          label: const Text("DEPLOY DYNAMIC CLASS ASSIGNMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple.withValues(alpha: 0.3),
                            side: const BorderSide(color: AppColors.accentPurple),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showChallengeModal(context, provider),
                          icon: const Icon(Icons.hub, color: Colors.white),
                          label: const Text("DISPATCH COGNITIVE BATTLE CHALLENGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                            side: const BorderSide(color: Colors.greenAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Heatmap representation
                      const Text("CLASSROOM COGNITIVE DISTRIBUTION", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: countOptimal,
                            child: countOptimal > 0
                                ? Container(
                                    height: 12,
                                    decoration: const BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Expanded(
                            flex: countStable,
                            child: countStable > 0
                                ? Container(height: 12, color: Colors.orangeAccent)
                                : const SizedBox.shrink(),
                          ),
                          Expanded(
                            flex: countAtRisk,
                            child: countAtRisk > 0
                                ? Container(
                                    height: 12,
                                    decoration: const BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Optimal (>=85%): $countOptimal", style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          Text("Stable (65-85%): $countStable", style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                          Text("Risk (<65%): $countAtRisk", style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Student list header & Search
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("STUDENT DIRECTORY", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                          Text("${filteredStudents.length} matches", style: const TextStyle(color: AppColors.primaryNeon, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search students by name or ID...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: AppColors.accentPurple),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accentPurple), borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Student cards
                      if (filteredStudents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(child: Text("No student nodes detected.", style: TextStyle(color: Colors.white38))),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, idx) {
                            final s = filteredStudents[idx];
                            final String studentName = s['fullName'] ?? 'Unknown Student';
                            final String studentId = s['studentId'] ?? 'ID-000';
                            final double cgpa = s['cgpa']?.toDouble() ?? 0.0;
                            final double cog = s['cognitiveScore']?.toDouble() ?? 0.0;
                            final double att = s['attendanceRate']?.toDouble() ?? 0.0;
                            final String uid = s['uid'] ?? '';

                            Color scoreColor = Colors.greenAccent;
                            if (cog < 65) {
                              scoreColor = Colors.redAccent;
                            } else if (cog < 85) {
                              scoreColor = Colors.orangeAccent;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text("Student ID: $studentId", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                                          child: Text("Cog: ${cog.toStringAsFixed(1)}%", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white12, height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("CGPA: ${cgpa.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                        Text("Attendance: ${att.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _showAttendanceModal(context, provider, uid, studentName),
                                          icon: const Icon(Icons.co_present, size: 14, color: Colors.black),
                                          label: const Text("ATTENDANCE", style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryNeon,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _showGradingModal(context, provider, uid, studentName),
                                          icon: const Icon(Icons.grade, size: 14, color: Colors.black),
                                          label: const Text("GRADE", style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _showAdvisoryModal(context, provider, uid, studentName),
                                          icon: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.black),
                                          label: const Text("ALERT", style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orangeAccent,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
