import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class VivaLieDetectionScanner extends StatelessWidget {
  const VivaLieDetectionScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(20, (index) => _buildVoiceWave(index)),
              ),
            ),
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.redAccent.withValues(alpha: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric("Stress", "High", Colors.redAccent),
            _buildMetric("Confidence", "Low", Colors.orangeAccent),
            _buildMetric("Truth Prob", "45%", Colors.redAccent),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Expanded(child: Text("Voice micro-tremors detected. High probability of deceptive or uncertain answer.", style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceWave(int index) {
    // Generate chaotic wave for "lie" simulation
    double height = (index % 4 == 0) ? 80.0 : ((index % 3 == 0) ? 30.0 : 60.0);
    return ElasticInUp(
      duration: Duration(milliseconds: 500 + (index * 50)),
      child: Container(
        width: 4,
        height: height,
        decoration: BoxDecoration(
          color: height > 60 ? Colors.redAccent : Colors.white54,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
