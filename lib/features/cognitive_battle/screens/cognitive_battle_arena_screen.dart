import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/providers/battle_provider.dart';

import 'battle_match_screen.dart';
import 'tournament_bracket_screen.dart';

class CognitiveBattleArenaScreen extends StatefulWidget {
  const CognitiveBattleArenaScreen({super.key});

  @override
  State<CognitiveBattleArenaScreen> createState() => _CognitiveBattleArenaScreenState();
}

class _CognitiveBattleArenaScreenState extends State<CognitiveBattleArenaScreen> {
  final TextEditingController _roomIdController = TextEditingController();
  String _selectedDifficulty = "Medium";
  String _selectedSubject = "Artificial Intelligence";

  final List<String> _difficulties = ["Easy", "Medium", "Hard", "Expert"];
  final List<String> _subjects = [
    "Artificial Intelligence",
    "Coding & Logic",
    "Quantitative Aptitude",
    "Cognitive Reasoning",
    "Systems Engineering"
  ];

  @override
  Widget build(BuildContext context) {
    final battleProv = Provider.of<BattleProvider>(context);
    final studentProv = Provider.of<StudentProvider>(context);
    final studentName = studentProv.studentProfile?['fullName'] ?? "Player 1";
    final studentId = studentProv.studentProfile?['uid'] ?? "student_user";
    final department = studentProv.studentProfile?['department'] ?? "CSE";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0B24),
        elevation: 0,
        title: const Text(
          "AI COGNITIVE BATTLE ARENA",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Cyber Grid background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF190C2C), Colors.black],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. User Profile Rank Banner
                  FadeInDown(
                    child: _buildRankBanner(battleProv, studentName),
                  ),
                  const SizedBox(height: 20),

                  // 2. Streaks and Quests Tracker
                  FadeInUp(
                    child: _buildStreaksAndQuests(battleProv),
                  ),
                  const SizedBox(height: 20),

                  // 3. Powerups Armory Shop
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildPowerupsStore(battleProv),
                  ),
                  const SizedBox(height: 24),

                  // 4. Game Modes Selection Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      "CHOOSE GAMEPLAY DOMAIN",
                      style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Game Modes Grid
                  _buildGameModesGrid(context, battleProv, studentId, studentName, department),
                  const SizedBox(height: 24),

                  // 5. Department Standing scoreboard
                  FadeInUp(
                    child: _buildDepartmentStandings(battleProv),
                  ),
                  const SizedBox(height: 24),

                  // 6. Global Leaderboard
                  FadeInUp(
                    child: _buildEsportsLeaderboard(battleProv),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          if (battleProv.isSearching)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Pulse(
                      infinite: true,
                      child: const Icon(Icons.hub, color: AppColors.primaryNeon, size: 80),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "CONNECTING TO COGNITIVE SYNAPSE SHARD...",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enlisting player nodes & syncing Firestore...",
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // A. Rank Banner Widget
  Widget _buildRankBanner(BattleProvider battleProv, String name) {
    String rankName = "Bronze Tier";
    Color rankColor = Colors.brown;
    double progress = 0.0;
    
    int rp = battleProv.rankPoints;
    if (rp <= 200) {
      rankName = "Bronze Challenger";
      rankColor = Colors.orange.shade700;
      progress = rp / 200.0;
    } else if (rp <= 400) {
      rankName = "Silver Specialist";
      rankColor = Colors.grey.shade400;
      progress = (rp - 200) / 200.0;
    } else if (rp <= 650) {
      rankName = "Gold Strategist";
      rankColor = Colors.amber;
      progress = (rp - 400) / 250.0;
    } else if (rp <= 900) {
      rankName = "Platinum Tactician";
      rankColor = Colors.tealAccent.shade400;
      progress = (rp - 650) / 250.0;
    } else if (rp <= 1200) {
      rankName = "Diamond Operator";
      rankColor = AppColors.primaryNeon;
      progress = (rp - 900) / 300.0;
    } else if (rp <= 1600) {
      rankName = "Elite Architect";
      rankColor = AppColors.accentPurple;
      progress = (rp - 1200) / 400.0;
    } else {
      rankName = "Cognitive Master";
      rankColor = Colors.redAccent;
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: rankColor.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: rankColor.withValues(alpha: 0.05), blurRadius: 15, spreadRadius: 3),
        ],
      ),
      child: Row(
        children: [
          // Glowing rank icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rankColor.withValues(alpha: 0.1),
              border: Border.all(color: rankColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [BoxShadow(color: rankColor.withValues(alpha: 0.1), blurRadius: 12)],
            ),
            child: Icon(Icons.shield, color: rankColor, size: 36),
          ),
          const SizedBox(width: 16),
          
          // Rank details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  rankName,
                  style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("RP: $rp / ${rp > 1600 ? 'MAX' : '1600'}", style: const TextStyle(color: Colors.white30, fontSize: 10)),
                    Text("Win Streak: x${battleProv.winStreak}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                NeonProgressBar(progress: progress, color: rankColor, height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // B. Streaks and Quests Panel
  Widget _buildStreaksAndQuests(BattleProvider battleProv) {
    return HolographicCard(
      glowColor: AppColors.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist, color: AppColors.accentPurple),
                  SizedBox(width: 8),
                  Text(
                    "DAILY COGNITIVE CHALLENGES",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
                  const SizedBox(width: 4),
                  Text("${battleProv.dailyStreakCount} Day Streak", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          
          // 7-day streak calendar visualizer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (idx) {
              bool isChecked = idx < battleProv.dailyStreakCount % 7 || (battleProv.dailyStreakCount > 0 && idx == 6);
              Color glow = isChecked ? Colors.orangeAccent : Colors.white24;
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isChecked ? glow.withValues(alpha: 0.1) : Colors.transparent,
                  border: Border.all(color: glow, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    isChecked ? Icons.check : Icons.circle_outlined,
                    color: glow,
                    size: 14,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Daily quests
          ...battleProv.dailyQuests.map((q) {
            double progress = q['current'] / q['target'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(
                    q['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: q['completed'] ? Colors.greenAccent : Colors.white30,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['desc'],
                          style: TextStyle(
                            color: q['completed'] ? Colors.white60 : Colors.white,
                            fontSize: 12,
                            decoration: q['completed'] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        NeonProgressBar(progress: progress, height: 4, color: q['completed'] ? Colors.greenAccent : AppColors.accentPurple),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("+${q['rewardXP']} XP", style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)),
                      Text("+${q['rewardCoins']} Coins", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // C. Powerups Armory Shop
  Widget _buildPowerupsStore(BattleProvider battleProv) {
    final items = [
      {'id': 'hint', 'name': 'Hint Clue', 'icon': Icons.lightbulb, 'cost': 50, 'color': Colors.amber},
      {'id': '50_50', 'name': '50-50 Eliminate', 'icon': Icons.difference, 'cost': 80, 'color': AppColors.primaryNeon},
      {'id': 'double_points', 'name': 'Double Score', 'icon': Icons.star_purple500, 'cost': 100, 'color': Colors.greenAccent},
      {'id': 'freeze_timer', 'name': 'Freeze Clock', 'icon': Icons.ac_unit, 'cost': 120, 'color': Colors.cyanAccent},
      {'id': 'skip', 'name': 'Skip Pass', 'icon': Icons.skip_next, 'cost': 150, 'color': Colors.orangeAccent},
      {'id': 'time_boost', 'name': 'Time Boost', 'icon': Icons.add_alarm, 'cost': 120, 'color': AppColors.accentPurple},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C091D).withValues(alpha: 0.6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.amber),
                  SizedBox(width: 8),
                  Text("COGNITIVE ARMORY STORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text("${battleProv.coins} Coins", style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, idx) {
                final item = items[idx];
                final id = item['id'] as String;
                final name = item['name'] as String;
                final icon = item['icon'] as IconData;
                final cost = item['cost'] as int;
                final color = item['color'] as Color;
                final owned = battleProv.powerups[id] ?? 0;

                return GestureDetector(
                  onTap: () {
                    bool ok = battleProv.buyItem(id, cost, 'powerup');
                    if (ok) {
                      FuturisticToast.show(context, message: "Acquired $name! Loaded in inventory.");
                    } else {
                      FuturisticToast.show(context, message: "Insufficient coins.", isError: true);
                    }
                  },
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("x$owned", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                            Icon(icon, color: color, size: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 8),
                              const SizedBox(width: 2),
                              Text("$cost", style: const TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // D. Game Modes Selection Grid
  Widget _buildGameModesGrid(BuildContext context, BattleProvider battleProv, String studentId, String studentName, String dept) {
    return Column(
      children: [
        // Mode 1: AI Bot Arena & 1v1 Live Arena side-by-side
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: "SOLO BOT TRAINING",
                subtitle: "Fight AI cognitive cores.",
                icon: Icons.computer,
                color: AppColors.primaryNeon,
                actionWidget: DropdownButton<String>(
                  value: _selectedDifficulty,
                  dropdownColor: const Color(0xFF100C2A),
                  style: const TextStyle(color: AppColors.primaryNeon, fontSize: 12, fontWeight: FontWeight.bold),
                  underline: Container(),
                  items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                ),
                onTap: () {
                  battleProv.startBotBattle(_selectedDifficulty, studentId, studentName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BattleMatchScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: "1V1 MULTIPLAYER",
                subtitle: "Live study combat rooms.",
                icon: Icons.wifi,
                color: AppColors.accentPurple,
                actionWidget: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                onTap: () => _showMultiplayerOptions(context, battleProv, studentId, studentName),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mode 2: Tournament Bracket & Department War side-by-side
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: "TOURNAMENT CUP",
                subtitle: "8-Player bracket ladders.",
                icon: Icons.emoji_events,
                color: Colors.amber,
                actionWidget: const Text("PLAY", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TournamentBracketScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: "DEPARTMENT WAR",
                subtitle: "Fight for CSE / IT pride.",
                icon: Icons.group_work,
                color: Colors.redAccent,
                actionWidget: const Text("BATTLE", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                onTap: () {
                  // Instant matchmaking for Department
                  FuturisticToast.show(context, message: "Enlisting you in ECE vs CSE Battle shard...");
                  battleProv.startBotBattle("Hard", studentId, studentName);
                  battleProv.logDepartmentWarMatch(dept, "CSE", true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BattleMatchScreen(isDeptMatch: true)),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mode 3: Faculty Challenges & Team Combat 2v2 side-by-side
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: "FACULTY CHALLENGE",
                subtitle: "Join professor tasks.",
                icon: Icons.menu_book,
                color: Colors.greenAccent,
                actionWidget: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                onTap: () => _showFacultyChallengesDialog(context, battleProv, studentId, studentName),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: "TEAM COMBAT (2V2)",
                subtitle: "Team up and solve.",
                icon: Icons.people,
                color: Colors.cyanAccent,
                actionWidget: const Icon(Icons.lock_outline, color: Colors.white30, size: 14),
                onTap: () {
                  FuturisticToast.show(context, message: "Team mode unlocking in Arena Phase 2 update.", isError: true);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget actionWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                actionWidget,
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // E. Dialogue/Sheet for Multiplayer Create/Join
  void _showMultiplayerOptions(BuildContext context, BattleProvider battleProv, String studentId, String studentName) {
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
                  color: const Color(0xFF100C2A),
                  border: Border.all(color: AppColors.accentPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("1v1 Neural Matchmaker", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24, height: 24),
                    
                    // Create Room
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
                          value: _selectedSubject,
                          dropdownColor: const Color(0xFF100C2A),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => _selectedSubject = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          String rId = await battleProv.createRoom(_selectedSubject, studentId, studentName);
                          if (context.mounted) {
                            _showRoomWaitingDialog(context, battleProv, rId);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
                        child: const Text("CREATE STUDY LOBBY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white12)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("OR", style: TextStyle(color: Colors.white24, fontSize: 10)),
                        ),
                        Expanded(child: Divider(color: Colors.white12)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Join Room
                    const Text("ENTER STUDY LOBBY KEY", style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _roomIdController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "e.g., room_4821",
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accentPurple), borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          String key = _roomIdController.text.trim();
                          if (key.isEmpty) return;
                          
                          Navigator.pop(context);
                          bool joined = await battleProv.joinRoom(key, studentId, studentName);
                          if (joined) {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BattleMatchScreen()),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              FuturisticToast.show(context, message: "Lobby not found or already full.", isError: true);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.accentPurple)),
                        child: const Text("JOIN LOBBY CODE", style: TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.bold)),
                      ),
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

  // F. Lobby waiting dialog
  void _showRoomWaitingDialog(BuildContext context, BattleProvider battleProv, String roomId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogStateCtx, setStateDialog) {
            // Watch changes in battleProv activeRoom
            final room = battleProv.activeRoom;
            if (room != null && room['player2'] != null) {
              // Opponent joined! Close this and go to match screen
              Future.microtask(() {
                if (!context.mounted) return;
                Navigator.pop(dialogStateCtx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BattleMatchScreen()),
                );
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
                    const Text("WAITING FOR OPPONENT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Divider(color: Colors.white24, height: 24),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("LOBBY ACCESS KEY:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(roomId, style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: AppColors.primaryNeon),
                    const SizedBox(height: 20),
                    const Text(
                      "Share this key with a classmate to commence 1v1 duel...",
                      style: TextStyle(color: Colors.white30, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        battleProv.leaveRoom();
                        Navigator.pop(context);
                      },
                      child: const Text("ABORT ARENA LOBBY", style: TextStyle(color: Colors.redAccent)),
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

  // G. Faculty Challenges Dialog
  void _showFacultyChallengesDialog(BuildContext context, BattleProvider battleProv, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF100C2A),
              border: Border.all(color: Colors.greenAccent, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.greenAccent),
                    SizedBox(width: 8),
                    Text("Faculty Academic Quests", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                const Text("ACTIVE CLASSROOM ENLISTMENTS:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 12),
                
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('faculty_challenges')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.rocket_launch, color: Colors.greenAccent),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Prof. Higgins: Quantum 101", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 4),
                                    Text("Active: 8 / 30 Joined", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  FuturisticToast.show(context, message: "Connecting with classroom cluster...");
                                  battleProv.startBotBattle("Hard", studentId, studentName);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const BattleMatchScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                child: const Text("JOIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          var doc = snapshot.data!.docs[idx];
                          var data = doc.data() as Map<String, dynamic>;
                          String challengeName = data['challengeName'] ?? 'Academic Challenge';
                          String createdBy = data['createdBy'] ?? 'Faculty';
                          String subject = data['subject'] ?? 'General';
                          int joined = data['joinedCount'] ?? 8;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              border: Border.all(color: Colors.white12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.rocket_launch, color: Colors.greenAccent),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("$createdBy: $challengeName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text("Focus: $subject | $joined Joined", style: TextStyle(color: Colors.greenAccent.withValues(alpha: 0.8), fontSize: 10)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    FuturisticToast.show(context, message: "Connecting with classroom cluster...");
                                    battleProv.startBotBattle("Hard", studentId, studentName);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BattleMatchScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                  child: const Text("JOIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CLOSE NEXUS", style: TextStyle(color: Colors.white70)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // H. Department Standings Dashboard
  Widget _buildDepartmentStandings(BattleProvider battleProv) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text("DEPARTMENTAL WAR FRONT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("AIDS CHAMPION", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          
          // Department progress bars
          ...battleProv.departmentScores.entries.map((e) {
            double prog = e.value / 2000.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(e.key, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: NeonProgressBar(progress: prog, height: 6, color: e.key == 'AIDS' ? Colors.redAccent : AppColors.secondaryNeon),
                  ),
                  const SizedBox(width: 12),
                  Text("${e.value} Wins", style: const TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // I. Global Leaderboard
  Widget _buildEsportsLeaderboard(BattleProvider battleProv) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: AppColors.primaryNeon),
              SizedBox(width: 8),
              Text("COGNITIVE ARENA GLOBAL STANDINGS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: battleProv.leaderboard.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 10),
            itemBuilder: (context, idx) {
              final player = battleProv.leaderboard[idx];
              final name = player['name'] as String;
              final dept = player['dept'] as String;
              final wins = player['wins'] as int;
              final acc = player['accuracy'] as int;
              final speed = player['speed'] as double;
              final rank = player['rank'] as String;

              Color rankColor = AppColors.primaryNeon;
              if (rank.contains("Master")) rankColor = Colors.redAccent;
              if (rank.contains("Elite")) rankColor = AppColors.accentPurple;

              return Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rankColor.withValues(alpha: 0.15),
                      border: Border.all(color: rankColor),
                    ),
                    child: Center(
                      child: Text("${idx + 1}", style: TextStyle(color: rankColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text("$dept | $rank", style: const TextStyle(color: Colors.white30, fontSize: 10)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("$wins Wins", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("$acc% Acc / ${speed}s", style: const TextStyle(color: Colors.white24, fontSize: 9)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
