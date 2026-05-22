import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/widgets/futuristic_toast.dart';

class InterviewSimulationEngine extends StatefulWidget {
  const InterviewSimulationEngine({super.key});

  @override
  State<InterviewSimulationEngine> createState() => _InterviewSimulationEngineState();
}

class _ResumeInterviewSimulationEngineState {} // Left for backward safety if needed

class _InterviewSimulationEngineState extends State<InterviewSimulationEngine> {
  String _status = "STANDBY";
  double _speakingConfidence = 0.82;
  double _clarityTone = 0.76;
  bool _isSimulating = false;

  void _startMockInterview(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0C29),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over, color: Colors.cyanAccent),
                        const SizedBox(width: 8),
                        const Text(
                          "AI Interview Uplink",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    const SizedBox(height: 8),
                    const Text(
                      "INTERVIEWER:\n\"Describe how you would address a severe database latency issue in a production environment under heavy query load.\"",
                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("SELECT YOUR RESPONDING STRATEGY:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    _buildOption(
                      context,
                      "Configure database read-replicas, index hot tables, and check slow query logs.",
                      () {
                        Navigator.pop(context);
                        _evaluateInterview(0.95, 0.90, "Optimal analytical response chosen.");
                      },
                    ),
                    _buildOption(
                      context,
                      "Restart the database instance and scale up virtual machine hardware immediately.",
                      () {
                        Navigator.pop(context);
                        _evaluateInterview(0.70, 0.65, "Sub-optimal scaling approach detected.");
                      },
                    ),
                    _buildOption(
                      context,
                      "Implement redis cache clusters for repetitive fetches and audit indexing schemas.",
                      () {
                        Navigator.pop(context);
                        _evaluateInterview(0.90, 0.86, "Strong caching & architecture logic.");
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL SIMULATION", style: TextStyle(color: Colors.white38)),
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

  Widget _buildOption(BuildContext context, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }

  void _evaluateInterview(double finalConfidence, double finalClarity, String feedback) async {
    setState(() {
      _status = "ANALYZING";
      _isSimulating = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _speakingConfidence = finalConfidence;
        _clarityTone = finalClarity;
        _status = "STANDBY";
        _isSimulating = false;
      });
      FuturisticToast.show(context, message: "Evaluation complete: $feedback");
    }
  }

  @override
  Widget build(BuildContext context) {
    return HolographicCard(
      glowColor: Colors.cyanAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.record_voice_over, color: Colors.cyanAccent),
                  const SizedBox(width: 8),
                  const Text("Interview Simulation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Pulse(
                infinite: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _status,
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Communication Analytics", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          _buildAnalysisRow("Speaking Confidence", _speakingConfidence, Colors.cyanAccent),
          const SizedBox(height: 12),
          _buildAnalysisRow("Clarity & Tone Coherence", _clarityTone, Colors.cyanAccent),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSimulating ? null : () => _startMockInterview(context),
              icon: _isSimulating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                _isSimulating ? "ANALYZING RESPONSES..." : "START AI MOCK INTERVIEW",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.3),
                side: const BorderSide(color: Colors.cyanAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, double value, Color glowColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text("${(value * 100).toInt()}%", style: TextStyle(color: glowColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        NeonProgressBar(progress: value, color: glowColor, height: 8),
      ],
    );
  }
}
