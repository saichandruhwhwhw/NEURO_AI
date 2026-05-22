import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/providers/admin_provider.dart';
import '../../auth/screens/role_selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _activeTab = 0; // 0: Telemetry, 1: Registry, 2: Security, 3: Reports
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  int _userTypeToggle = 0; // 0: Students, 1: Faculty

  // Simulated live telemetry state
  double _cpuLoad = 0.14;
  double _memLoad = 0.22;
  double _dbLatency = 34.0;
  bool _aiModelSynced = true;

  @override
  void initState() {
    super.initState();
    // Simulate real-time fluctuating telemetry
    _simulateTelemetry();
  }

  void _simulateTelemetry() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          // Subtle fluctuations
          _cpuLoad = (0.10 + (DateTime.now().second % 15) / 100.0).clamp(0.0, 1.0);
          _memLoad = (0.20 + (DateTime.now().second % 8) / 100.0).clamp(0.0, 1.0);
          _dbLatency = 30.0 + (DateTime.now().second % 12);
        });
      }
    }
  }

  // A. Create User Modal Form
  void _showAddUserModal(BuildContext context, AdminProvider provider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final specificIdController = TextEditingController();

    String selectedRole = "student"; // Default
    String selectedDept = "Computer Science";

    final depts = [
      "Computer Science",
      "Data Analytics",
      "Robotics Engineering",
      "Cyber Security",
      "Bio-Medical Engineering"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final accentColor = selectedRole == 'student' ? AppColors.primaryNeon : AppColors.accentPurple;
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: const Color(0xFF100C2A),
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_add_alt_1, color: accentColor, size: 28),
                          const SizedBox(width: 10),
                          const Text(
                            "Deploy Neural Node",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      
                      // Role Selection (Student vs Faculty)
                      const Text("NODE CLASSIFICATION", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setStateDialog(() => selectedRole = "student"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == "student" ? AppColors.primaryNeon.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(color: selectedRole == "student" ? AppColors.primaryNeon : Colors.white12, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text("STUDENT", style: TextStyle(color: selectedRole == "student" ? AppColors.primaryNeon : Colors.white70, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => setStateDialog(() => selectedRole = "faculty"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == "faculty" ? AppColors.accentPurple.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(color: selectedRole == "faculty" ? AppColors.accentPurple : Colors.white12, width: 1.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text("FACULTY", style: TextStyle(color: selectedRole == "faculty" ? AppColors.accentPurple : Colors.white70, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fields
                      _buildDialogField(nameController, "FULL NAME", "e.g., Sarah Connor", Icons.person, accentColor),
                      const SizedBox(height: 16),
                      _buildDialogField(emailController, "OFFICIAL EMAIL", "e.g., sarah@neurolearn.edu", Icons.email, accentColor),
                      const SizedBox(height: 16),
                      _buildDialogField(
                        specificIdController, 
                        selectedRole == "student" ? "STUDENT ID" : "FACULTY ID", 
                        selectedRole == "student" ? "e.g., ST-8829" : "e.g., FC-2018", 
                        Icons.badge, 
                        accentColor
                      ),
                      const SizedBox(height: 16),

                      // Dept Dropdown
                      const Text("DEPARTMENT MATRIX", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
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
                            value: selectedDept,
                            dropdownColor: const Color(0xFF100C2A),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            items: depts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setStateDialog(() => selectedDept = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final specId = specificIdController.text.trim();
                            
                            if (name.isEmpty || email.isEmpty || specId.isEmpty) {
                              FuturisticToast.show(context, message: "Please fill all details.", isError: true);
                              return;
                            }

                            Navigator.pop(context);
                            FuturisticToast.show(context, message: "Deploying profile to node cluster...");
                            
                            try {
                              await provider.createUserProfile(email, name, selectedRole, specId, selectedDept);
                              if (context.mounted) {
                                FuturisticToast.show(context, message: "Profile successfully written to Firestore.");
                              }
                            } catch (e) {
                              if (context.mounted) {
                                FuturisticToast.show(context, message: "Error: ${e.toString()}", isError: true);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            shadowColor: accentColor.withValues(alpha: 0.4),
                            elevation: 10,
                          ),
                          child: const Text(
                            "INITIALIZE CORE PROFILE",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
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

  Widget _buildDialogField(TextEditingController controller, String label, String hint, IconData icon, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: accentColor, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // B. Delete Confirm Modal
  void _confirmDeleteUser(BuildContext context, AdminProvider provider, String uid, String name, String role) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF150B1B),
              border: Border.all(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                    SizedBox(width: 8),
                    Text("Decommission Node", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                Text(
                  "Are you sure you want to completely wipe user profile data for $name? This will erase all cognitive states, placement profiles, and Firestore databases linked with this UID.",
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("ABORT", style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        FuturisticToast.show(context, message: "Wiping user node from Firestore cluster...");
                        try {
                          await provider.deleteUserProfile(uid, role);
                          if (context.mounted) {
                            FuturisticToast.show(context, message: "Wipe completed. Audit log updated.");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            FuturisticToast.show(context, message: "Wipe failed: ${e.toString()}", isError: true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text("CONFIRM WIPE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // C. Simulated Diagnostic Run
  void _runCoreDiagnostic(AdminProvider provider) async {
    FuturisticToast.show(context, message: "Starting Neural Telemetry Scan...");
    setState(() {
      _aiModelSynced = false;
    });
    
    // Add fake log
    provider.auditLogs.insert(0, {
      'event': 'Initiated full database sharding and CPU health diagnostic',
      'status': 'In Progress',
      'timestamp': 'Just Now'
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _aiModelSynced = true;
        _dbLatency = 24.0; // improved latency
      });
      
      provider.auditLogs.insert(0, {
        'event': 'Telemetry scan finalized: 15 collections synchronized. Status: Optimal',
        'status': 'Secured',
        'timestamp': 'Just Now'
      });
      
      FuturisticToast.show(context, message: "Core Telemetry Sync: 100% Optimal.");
    }
  }

  // D. Excel / PDF Report Simulator Modal
  void _showReportDownloadModal(BuildContext context, AdminProvider provider, String format) {
    double progress = 0.0;
    String status = "Connecting to Database Hub...";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            // Run report simulation in background
            if (progress == 0.0) {
              Future.microtask(() async {
                // Stage 1
                await Future.delayed(const Duration(milliseconds: 600));
                if (context.mounted) setStateDialog(() { progress = 0.25; status = "Vectorizing Student Cognitive Scores..."; });
                
                // Stage 2
                await Future.delayed(const Duration(milliseconds: 700));
                if (context.mounted) setStateDialog(() { progress = 0.55; status = "Simulating Neural Career Alignments..."; });

                // Stage 3
                await Future.delayed(const Duration(milliseconds: 700));
                if (context.mounted) setStateDialog(() { progress = 0.85; status = "Compiling Cryptographic Verification Shield..."; });

                // Final
                String path = await provider.exportPerformanceReport(format);
                if (context.mounted) setStateDialog(() { progress = 1.0; status = "Report File Successfully Written."; });

                await Future.delayed(const Duration(milliseconds: 400));
                if (context.mounted) {
                  Navigator.pop(context);
                  FuturisticToast.show(context, message: "Report generated! saved to:\n$path");
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0B24),
                  border: Border.all(color: AppColors.primaryNeon, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("CYBER COMPILER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        Text("${(progress * 100).toInt()}%", style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    const SizedBox(height: 10),
                    NeonProgressBar(progress: progress, height: 10),
                    const SizedBox(height: 20),
                    Text(status, style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryNeon),
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
    final provider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Tech Grid / Radial Glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1E0C2D), Colors.black],
                center: Alignment.topLeft,
                radius: 1.8,
              ),
            ),
          ),
          
          SafeArea(
            child: Row(
              children: [
                // 1. Sidebar Navigation (Desktop / Tablet view)
                NavigationRail(
                  backgroundColor: const Color(0xFF0B091D).withValues(alpha: 0.6),
                  selectedIndex: _activeTab,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (idx) {
                    setState(() {
                      _activeTab = idx;
                    });
                  },
                  unselectedIconTheme: const IconThemeData(color: Colors.white30),
                  selectedIconTheme: const IconThemeData(color: AppColors.primaryNeon),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics, color: AppColors.primaryNeon),
                      label: Text("TELEMETRY"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people, color: AppColors.primaryNeon),
                      label: Text("REGISTRY"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shield_outlined),
                      selectedIcon: Icon(Icons.shield, color: AppColors.primaryNeon),
                      label: Text("SECURITY"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.summarize_outlined),
                      selectedIcon: Icon(Icons.summarize, color: AppColors.primaryNeon),
                      label: Text("REPORTS"),
                    ),
                  ],
                ),
                const VerticalDivider(color: Colors.white12, width: 1),

                // 2. Main Content Window
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
                      : Column(
                          children: [
                            _buildHeader(context),
                            const Divider(color: Colors.white12, height: 1),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _buildActiveTabContent(provider),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER BAR
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF0F0B24).withValues(alpha: 0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Pulse(
                infinite: true,
                child: const Icon(Icons.circle, color: Colors.redAccent, size: 10),
              ),
              const SizedBox(width: 8),
              const Text(
                "SYSTEM AI COMMAND CORE",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.redAccent, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "CLEARANCE: ADMIN LEVEL 1",
                      style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                tooltip: "De-authenticate Command Session",
                icon: const Icon(Icons.power_settings_new, color: Colors.white70),
                onPressed: () async {
                  await Provider.of<AdminProvider>(context, listen: false).exportPerformanceReport("temp"); // register action
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                    FuturisticToast.show(context, message: "Clearance Key Revoked. Session Terminated.");
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTIONS SWITCHER
  Widget _buildActiveTabContent(AdminProvider provider) {
    switch (_activeTab) {
      case 0:
        return _buildTelemetryTab(provider);
      case 1:
        return _buildRegistryTab(provider);
      case 2:
        return _buildSecurityTab(provider);
      case 3:
        return _buildReportsTab(provider);
      default:
        return _buildTelemetryTab(provider);
    }
  }

  // --- TAB 1: TELEMETRY & SYSTEM CORE ---
  Widget _buildTelemetryTab(AdminProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeInDown(
          child: const Text(
            "CORE TELEMETRY MONITOR",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid layout of metrics
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = (constraints.maxWidth - 24) / 2;
            if (constraints.maxWidth < 650) {
              cardWidth = constraints.maxWidth;
            }
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetricCard(
                  width: cardWidth,
                  title: "COGNITIVE CLOUD CPU LOAD",
                  value: "${(_cpuLoad * 100).toStringAsFixed(1)}%",
                  statusText: _cpuLoad > 0.4 ? "High Activity" : "Stable Syncing",
                  color: _cpuLoad > 0.4 ? Colors.orangeAccent : AppColors.primaryNeon,
                  widget: NeonProgressBar(progress: _cpuLoad, color: _cpuLoad > 0.4 ? Colors.orangeAccent : AppColors.primaryNeon),
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: "VECTOR STORAGE MEMORY",
                  value: "${(_memLoad * 8).toStringAsFixed(2)} / 8.00 GB",
                  statusText: "Cache Optimal",
                  color: AppColors.accentPurple,
                  widget: NeonProgressBar(progress: _memLoad, color: AppColors.accentPurple),
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: "FIRESTORE READ/WRITE LATENCY",
                  value: "${_dbLatency.toInt()} ms",
                  statusText: _dbLatency < 40.0 ? "Excellent Ping" : "Moderate Ping",
                  color: Colors.greenAccent,
                  widget: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _dbLatency < 40.0 ? "DIRECT SHARD ACTIVE" : "SYNAPSE QUEUE NORMAL",
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: "NEURAL NETWORK DEPLOYMENT",
                  value: _aiModelSynced ? "100% ONLINE" : "RESYNCING...",
                  statusText: _aiModelSynced ? "6 AI Models Dynamic" : "Diagnostic Check",
                  color: _aiModelSynced ? Colors.greenAccent : Colors.orangeAccent,
                  widget: Row(
                    children: [
                      Icon(Icons.network_ping, color: _aiModelSynced ? Colors.greenAccent : Colors.orangeAccent, size: 16),
                      const SizedBox(width: 8),
                      const Text("Active Checksum Secure", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // Telemetry Commands
        HolographicCard(
          glowColor: AppColors.primaryNeon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_suggest, color: AppColors.primaryNeon),
                  SizedBox(width: 10),
                  Text(
                    "COGNITIVE ENGINE CONTROLLERS",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Force an active check of all classroom cognitive distribution lists, Ebbinghaus revision parameters, student wellness metrics, and Firestore indices.",
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _runCoreDiagnostic(provider),
                    icon: const Icon(Icons.radar, color: Colors.black),
                    label: const Text("RUN FULL RE-DIAGNOSTIC", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNeon),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.auditLogs.insert(0, {
                        'event': 'Forced manual Firestore connection handshake',
                        'status': 'Secured',
                        'timestamp': 'Just Now'
                      });
                      FuturisticToast.show(context, message: "Firestore database links re-secured.");
                    },
                    icon: const Icon(Icons.wifi_protected_setup, color: Colors.white),
                    label: const Text("PING FIRESTORE", style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required double width, required String title, required String value, required String statusText, required Color color, required Widget widget}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          widget,
        ],
      ),
    );
  }

  // --- TAB 2: USER REGISTRY MANAGEMENT ---
  Widget _buildRegistryTab(AdminProvider provider) {
    final filteredUsers = _userTypeToggle == 0
        ? provider.students.where((s) =>
            s['fullName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (s['studentId'] ?? "").toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        : provider.faculty.where((f) =>
            f['fullName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (f['facultyId'] ?? "").toString().toLowerCase().contains(_searchQuery.toLowerCase()));

    final activeColor = _userTypeToggle == 0 ? AppColors.primaryNeon : AppColors.accentPurple;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing title and Enlist button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "NEURAL NODE DIRECTORY",
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserModal(context, provider),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text("ENLIST NEW NODE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: activeColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar & Type Selector Row
          Row(
            children: [
              // Toggle Role
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleItem("STUDENTS (${provider.students.length})", 0, AppColors.primaryNeon),
                    _buildToggleItem("FACULTY (${provider.faculty.length})", 1, AppColors.accentPurple),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Search Input
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search name, ID or official email...",
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: activeColor), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Grid/List
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, color: activeColor.withValues(alpha: 0.4), size: 60),
                        const SizedBox(height: 12),
                        const Text("No active user nodes match search criteria.", style: TextStyle(color: Colors.white30)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredUsers.elementAt(index);
                      final uid = item['uid'] ?? "";
                      final name = item['fullName'] ?? "Unnamed User";
                      final email = item['email'] ?? "No Email";
                      final dept = item['department'] ?? "CS Department";
                      final specificId = _userTypeToggle == 0 ? (item['studentId'] ?? "N/A") : (item['facultyId'] ?? "N/A");

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Glowing initial circle
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: activeColor.withValues(alpha: 0.6), width: 1.5),
                                color: activeColor.withValues(alpha: 0.1),
                                boxShadow: [BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 10)],
                              ),
                              child: Center(
                                child: Text(
                                  name.toString().substring(0, name.toString().length > 0 ? 1 : 0).toUpperCase(),
                                  style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
                                        child: Text(specificId, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(email, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text("Field: $dept", style: TextStyle(color: activeColor.withValues(alpha: 0.7), fontSize: 11)),
                                ],
                              ),
                            ),

                            // Action button
                            IconButton(
                              tooltip: "Wipe Profile Node",
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDeleteUser(context, provider, uid, name, _userTypeToggle == 0 ? "student" : "faculty"),
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

  Widget _buildToggleItem(String label, int index, Color activeColor) {
    final isSelected = _userTypeToggle == index;
    return InkWell(
      onTap: () {
        setState(() {
          _userTypeToggle = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // --- TAB 3: SECURITY EVENTS AUDIT LOGS ---
  Widget _buildSecurityTab(AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SECURITY SHIELD & AUDIT LOGS",
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  provider.auditLogs.insert(0, {
                    'event': 'Simulating cyber attacks: DDoS Blocked on Shard Gateway',
                    'status': 'Secured',
                    'timestamp': 'Just Now'
                  });
                  setState(() {});
                  FuturisticToast.show(context, message: "Clearance Level Test Complete. Security optimal.");
                },
                icon: const Icon(Icons.security, color: Colors.greenAccent),
                label: const Text("RUN DEVIANCE DRILL", style: TextStyle(color: Colors.greenAccent)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.greenAccent)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Terminal console wrapper
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF070412),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.redAccent.withValues(alpha: 0.05), blurRadius: 15, spreadRadius: 5),
                ],
              ),
              child: provider.auditLogs.isEmpty
                  ? const Center(child: Text("Console history empty.", style: TextStyle(color: Colors.white24)))
                  : ListView.separated(
                      itemCount: provider.auditLogs.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 12),
                      itemBuilder: (context, index) {
                        final log = provider.auditLogs[index];
                        final event = log['event'] ?? "";
                        final status = log['status'] ?? "Info";
                        final timestamp = log['timestamp'] ?? "";

                        Color statusColor = AppColors.primaryNeon;
                        if (status == 'Secured' || status == 'Optimal' || status == 'Success') {
                          statusColor = Colors.greenAccent;
                        } else if (status == 'Approved' || status == 'Completed') {
                          statusColor = AppColors.accentPurple;
                        } else if (status == 'In Progress') {
                          statusColor = Colors.orangeAccent;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "[$timestamp]",
                                style: const TextStyle(color: Colors.white24, fontSize: 11, fontFamily: 'monospace'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace', height: 1.3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: SYSTEM REPORTS EXPORTER ---
  Widget _buildReportsTab(AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CRYPTO-COMPILER REPORT Nexus",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.3,
              children: [
                _buildReportExportTile(
                  title: "COGNITIVE INDEX LEDGER",
                  subtitle: "Exports entire institution student learning rates, cognitive scores, streaks, and attendance analysis metrics.",
                  icon: Icons.picture_as_pdf,
                  format: "pdf",
                  color: Colors.redAccent,
                  provider: provider,
                ),
                _buildReportExportTile(
                  title: "PLACEMENTS READY DATASET",
                  subtitle: "Compiles student technical, logic aptitude parameters, simulated resume ratings, and recruitment forecasts.",
                  icon: Icons.table_chart,
                  format: "xlsx",
                  color: Colors.greenAccent,
                  provider: provider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportExportTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String format,
    required Color color,
    required AdminProvider provider,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showReportDownloadModal(context, provider, format),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "COMPILE & EXPORT (.${format.toUpperCase()})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

