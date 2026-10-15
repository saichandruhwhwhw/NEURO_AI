import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/battle_provider.dart';
import '../../../core/widgets/holographic_card.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BattleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ESPORTS STORE", style: TextStyle(color: AppColors.primaryNeon)),
        backgroundColor: Colors.transparent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text("🪙 ${prov.coins}", style: const TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("POWERUPS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildItemCard(context, prov, "Hint", "hint", 50, Icons.lightbulb, 'powerup'),
                _buildItemCard(context, prov, "50/50", "50_50", 80, Icons.call_split, 'powerup'),
                _buildItemCard(context, prov, "Double Points", "double_points", 100, Icons.looks_two, 'powerup'),
                _buildItemCard(context, prov, "Freeze Time", "freeze_timer", 150, Icons.ac_unit, 'powerup'),
              ],
            ),
            const SizedBox(height: 30),
            const Text("HOLOGRAPHIC THEMES", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildItemCard(context, prov, "Dark Matter Theme", "Dark Matter", 500, Icons.dark_mode, 'theme', isWide: true),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, BattleProvider prov, String name, String id, int cost, IconData icon, String type, {bool isWide = false}) {
    bool isOwned = false;
    if (type == 'theme') isOwned = prov.unlockedThemes.contains(id);

    return HolographicCard(
      glowColor: AppColors.secondaryNeon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.secondaryNeon, size: 40),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          if (type == 'powerup') Text("Owned: ${prov.powerups[id] ?? 0}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isOwned ? Colors.grey : AppColors.primaryNeon),
            onPressed: isOwned ? null : () {
              bool success = prov.buyItem(id, cost, type);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Purchased $name!")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough coins!")));
              }
            },
            child: Text(isOwned ? "OWNED" : "🪙 $cost", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
