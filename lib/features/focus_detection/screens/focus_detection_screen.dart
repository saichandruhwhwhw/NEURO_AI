import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../dashboard/widgets/glass_container.dart';
import '../../../core/providers/student_provider.dart';

class FocusDetectionScreen extends StatefulWidget {
  const FocusDetectionScreen({super.key});

  @override
  State<FocusDetectionScreen> createState() => _FocusDetectionScreenState();
}

class _FocusDetectionScreenState extends State<FocusDetectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  
  String _selectedEmotion = "Focused";
  double _calculatedFocus = 88.0;
  bool _isAnalyzing = false;

  final Map<String, double> _emotionFocusValues = {
    'Focused': 92.5,
    'Neutral': 75.0,
    'Distracted': 34.2,
    'Fatigued': 45.0,
    'Excited': 82.0,
  };

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _runAnalysis(String emotion) {
    setState(() {
      _isAnalyzing = true;
      _selectedEmotion = emotion;
      _calculatedFocus = _emotionFocusValues[emotion] ?? 75.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        FuturisticToast.show(context, message: "Cognitive Scan complete. Focus score updated to $_calculatedFocus%");
      }
    });
  }

  void _saveToDatabase(StudentProvider provider) async {
    await provider.logFocusSession(_calculatedFocus, _selectedEmotion);
    if (mounted) {
      FuturisticToast.show(context, message: "Telemetry synced to Firestore successfully.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cyberpunk overlay gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF001510), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                        "AI Focus & Emotion Tracker",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Camera feed simulator
                  Center(
                    child: Stack(
                      children: [
                        // Stylized face tracker
                        Container(
                          width: double.infinity,
                          height: 300,
                          constraints: const BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.1), blurRadius: 20)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Futuristic grid background
                                Opacity(
                                  opacity: 0.3,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fit=crop&w=600&h=600',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                
                                // Face Box overlay
                                Container(
                                  width: 160,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.greenAccent, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Stack(
                                    children: [
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Text("FACIAL BOUNDS", style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Scanning Laser Line
                                AnimatedBuilder(
                                  animation: _scannerController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 300 * _scannerController.value,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryNeon,
                                          boxShadow: [
                                            BoxShadow(color: AppColors.primaryNeon, blurRadius: 10, spreadRadius: 2)
                                          ]
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                
                                if (_isAnalyzing)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(color: AppColors.primaryNeon),
                                          SizedBox(height: 12),
                                          Text("DEEP NEURAL READING...", style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Emotion selection
                  const Text("SELECT EMOTION SCAN STATE", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _emotionFocusValues.keys.map((em) {
                        bool isSelected = _selectedEmotion == em;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(em),
                            selected: isSelected,
                            selectedColor: AppColors.primaryNeon.withValues(alpha: 0.3),
                            backgroundColor: Colors.white10,
                            labelStyle: TextStyle(color: isSelected ? AppColors.primaryNeon : Colors.white),
                            side: BorderSide(color: isSelected ? AppColors.primaryNeon : Colors.transparent),
                            onSelected: (val) {
                              if (val) _runAnalysis(em);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Analytics Panel
                  FadeInUp(
                    child: HolographicCard(
                      glowColor: AppColors.primaryNeon,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Real-Time Engagement Metrics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Calculated Attention Level", style: TextStyle(color: Colors.white70)),
                              Text("${_calculatedFocus.toInt()}%", style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          NeonProgressBar(progress: _calculatedFocus / 100.0, color: AppColors.primaryNeon),
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Current Neural State", style: TextStyle(color: Colors.white70)),
                              Text(_selectedEmotion.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveToDatabase(studentProvider),
                      icon: const Icon(Icons.cloud_upload_outlined, color: Colors.black),
                      label: const Text("UPLINK TELEMETRY TO CLOUD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNeon,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
