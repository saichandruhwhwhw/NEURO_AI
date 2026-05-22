import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/student_provider.dart';

class SmartBurnoutAlerts extends StatelessWidget {
   const SmartBurnoutAlerts({super.key});

   @override
   Widget build(BuildContext context) {
     final studentProvider = Provider.of<StudentProvider>(context);
     final burnout = studentProvider.burnoutData;
     final double prob = burnout['burnoutProbability']?.toDouble() ?? 0.35;

     List<Widget> alerts = [];
     if (prob > 0.7) {
       alerts.add(_buildAlert("CRITICAL: High cognitive fatigue detected.", Colors.redAccent, 0));
       alerts.add(const SizedBox(height: 12));
       alerts.add(_buildAlert("ALERT: Focus level is declining due to excessive study duration.", Colors.orangeAccent, 100));
       alerts.add(const SizedBox(height: 12));
       alerts.add(_buildAlert("AI Recommendation: ${burnout['recoveryRecommended'] ?? 'Take a structured screen break.'}", Colors.cyanAccent, 200));
     } else if (prob > 0.4) {
       alerts.add(_buildAlert("WARNING: Moderate fatigue detected.", Colors.orangeAccent, 0));
       alerts.add(const SizedBox(height: 12));
       alerts.add(_buildAlert("AI Recommendation: ${burnout['recoveryRecommended'] ?? 'Shift to Pomodoro cycles.'}", Colors.cyanAccent, 100));
     } else {
       alerts.add(_buildAlert("HEALTHY: Cognitive systems operating at nominal load.", Colors.greenAccent, 0));
       alerts.add(const SizedBox(height: 12));
       alerts.add(_buildAlert("AI Recommendation: Continue pacing your study. Take micro-breaks.", Colors.cyanAccent, 100));
     }

     return Column(
       children: alerts,
     );
   }

   Widget _buildAlert(String message, Color color, int delayMs) {
     return FadeInLeft(
       delay: Duration(milliseconds: delayMs),
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         decoration: BoxDecoration(
           color: color.withValues(alpha: 0.1),
           border: Border(left: BorderSide(color: color, width: 4)),
           borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
         ),
         child: Row(
           children: [
             Icon(Icons.warning_amber_rounded, color: color, size: 20),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 message,
                 style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
               ),
             ),
           ],
         ),
       ),
     );
   }
}
