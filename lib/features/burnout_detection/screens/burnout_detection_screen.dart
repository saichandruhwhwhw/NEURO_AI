import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../widgets/burnout_meter.dart';
import '../widgets/cognitive_energy_scanner.dart';
import '../widgets/ai_recovery_engine.dart';
import '../widgets/emotional_stability_analytics.dart';
import '../widgets/smart_burnout_alerts.dart';

class BurnoutDetectionScreen extends StatefulWidget {
  const BurnoutDetectionScreen({super.key});

  @override
  State<BurnoutDetectionScreen> createState() => _BurnoutDetectionScreenState();
}

class _BurnoutDetectionScreenState extends State<BurnoutDetectionScreen> {
  double _durationMinutes = 90.0;
  double _productivityScore = 80.0;
  bool _isLogging = false;

  void _submitSession(StudentProvider provider) async {
    setState(() {
      _isLogging = true;
    });

    await provider.logStudySession(_durationMinutes, _productivityScore);

    if (mounted) {
      setState(() {
        _isLogging = false;
      });
      FuturisticToast.show(context, message: "Study session logged. AI Wellness status updated.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Deep red/purple gradient background simulating alert status
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B0000), Color(0xFF0F0C29)],
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
                          "Neural Wellness Scanner",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Smart Alerts
                  const SmartBurnoutAlerts(),
                  const SizedBox(height: 24),

                  // Session Logger Input Panel
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: HolographicCard(
                      glowColor: Colors.deepOrangeAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.add_task, color: Colors.deepOrangeAccent),
                              SizedBox(width: 8),
                              Text(
                                "Log Study Session",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Study Duration", style: TextStyle(color: Colors.white70)),
                              Text("${_durationMinutes.toInt()} mins", style: const TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _durationMinutes,
                            min: 15,
                            max: 480,
                            divisions: 31,
                            activeColor: Colors.deepOrangeAccent,
                            inactiveColor: Colors.white12,
                            onChanged: (val) {
                              setState(() {
                                _durationMinutes = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Productivity Level", style: TextStyle(color: Colors.white70)),
                              Text("${_productivityScore.toInt()}%", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _productivityScore,
                            min: 10,
                            max: 100,
                            divisions: 18,
                            activeColor: Colors.greenAccent,
                            inactiveColor: Colors.white12,
                            onChanged: (val) {
                              setState(() {
                                _productivityScore = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLogging ? null : () => _submitSession(studentProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent.withValues(alpha: 0.2),
                                side: const BorderSide(color: Colors.deepOrangeAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLogging
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepOrangeAccent))
                                  : const Text("UPLINK STUDY TELEMETRY", style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Burnout Meter
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: const BurnoutMeter(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Cognitive Scanner
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: const CognitiveEnergyScanner(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Emotional Stability
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: const EmotionalStabilityAnalytics(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Recovery Engine
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: const AiRecoveryEngine(),
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
