import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/battle_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BattleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ACHIEVEMENTS", style: TextStyle(color: AppColors.primaryNeon)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prov.achievements.length,
        itemBuilder: (context, index) {
          var ach = prov.achievements[index];
          bool unlocked = ach['unlocked'];
          return Card(
            color: unlocked ? AppColors.primaryNeon.withValues(alpha: 0.1) : Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: unlocked ? AppColors.primaryNeon : Colors.transparent)
            ),
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.lock, 
                color: unlocked ? Colors.amber : Colors.white30,
                size: 40,
              ),
              title: Text(ach['title'], style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
              subtitle: Text(ach['desc'], style: TextStyle(color: unlocked ? Colors.white70 : Colors.white30)),
            ),
          );
        },
      ),
    );
  }
}
