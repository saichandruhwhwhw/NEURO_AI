import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/providers/battle_provider.dart';

class BattleWinnerScreen extends StatefulWidget {
  final bool isDeptMatch;
  const BattleWinnerScreen({super.key, this.isDeptMatch = false});

  @override
  State<BattleWinnerScreen> createState() => _BattleWinnerScreenState();
}

class _BattleWinnerScreenState extends State<BattleWinnerScreen> with SingleTickerProviderStateMixin {
  bool _rewardsFinalized = false;
  int _earnedXP = 0;
  int _earnedCoins = 0;
  int _rpChange = 0;

  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _finalizeRewards();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _finalizeRewards() async {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final studentId = studentProv.studentProfile?['uid'] ?? "student_user";
    final dept = studentProv.studentProfile?['department'] ?? "CSE";

    final room = battleProv.activeRoom;
    if (room == null) return;

    final player1 = room['player1'];
    final player2 = room['player2'];

    final int p1Score = player1['score'] ?? 0;
    final int p2Score = player2 != null ? (player2['score'] ?? 0) : 0;
    final int userAcc = player1['accuracy'] ?? 0;
    final double userSpeed = (player1['speed'] ?? 2.0).toDouble();

    bool didUserWin = p1Score > p2Score;
    
    // Call provider rewards calculation
    final results = await battleProv.finalizeMatchRewards(
      studentId,
      didUserWin,
      p1Score,
      userAcc,
      userSpeed,
    );

    // If it's a Departmental match, log it in standings
    if (widget.isDeptMatch) {
      battleProv.logDepartmentWarMatch(dept, "CSE", didUserWin);
    }

    if (mounted) {
      setState(() {
        _earnedXP = results['xp'] ?? 0;
        _earnedCoins = results['coins'] ?? 0;
        _rpChange = results['rp'] ?? 0;
        _rewardsFinalized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final battleProv = Provider.of<BattleProvider>(context);
    final room = battleProv.activeRoom;

    if (room == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Session data not found.", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Exit"),
              )
            ],
          ),
        ),
      );
    }

    final player1 = room['player1'];
    final player2 = room['player2'];

    final int p1Score = player1['score'] ?? 0;
    final int p2Score = player2 != null ? (player2['score'] ?? 0) : 0;

    final int p1Acc = player1['accuracy'] ?? 0;
    final double p1Speed = (player1['speed'] ?? 0.0).toDouble();

    final int p2Acc = player2 != null ? (player2['accuracy'] ?? 0) : 0;
    final double p2Speed = player2 != null ? (player2['speed'] ?? 0.0).toDouble() : 0.0;


    final bool isUserWinner = p1Score > p2Score;
    final bool isDraw = p1Score == p2Score;

    String matchResultHeader = "VICTORY ACHIEVED";
    Color themeColor = AppColors.primaryNeon;
    IconData matchIcon = Icons.emoji_events;
    if (isDraw) {
      matchResultHeader = "NEURAL SYMMETRY (DRAW)";
      themeColor = Colors.amber;
      matchIcon = Icons.balance;
    } else if (!isUserWinner) {
      matchResultHeader = "DEFEAT DETECTED";
      themeColor = Colors.redAccent;
      matchIcon = Icons.sentiment_very_dissatisfied;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cyber Space Radial glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  themeColor.withValues(alpha: 0.1),
                  Colors.black,
                ],
                center: Alignment.center,
                radius: 1.4,
              ),
            ),
          ),

          // Particle sparkle overlay (animated)
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleSparklePainter(_sparkleController.value, themeColor, isUserWinner),
                size: Size.infinite,
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  // 1. Result Header text
                  FadeInDown(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            matchResultHeader,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(color: themeColor.withValues(alpha: 0.5), blurRadius: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            room['subject'].toString().toUpperCase(),
                            style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 2. Large central trophy
                  Center(
                    child: ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor.withValues(alpha: 0.1),
                          border: Border.all(color: themeColor, width: 2.0),
                          boxShadow: [
                            BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
                          ],
                        ),
                        child: Icon(matchIcon, color: themeColor, size: 80),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. Rewards display panel (XP, Coins, RP ticker)
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
                        border: Border.all(color: Colors.white12, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "COGNITIVE SHARD REWARDS ALLOCATED",
                            style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _rewardsFinalized
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildRewardMetric(
                                      value: "+$_earnedXP",
                                      label: "XP GAINED",
                                      icon: Icons.star,
                                      color: Colors.cyanAccent,
                                    ),
                                    _buildRewardMetric(
                                      value: "+$_earnedCoins",
                                      label: "COINS REAPED",
                                      icon: Icons.monetization_on,
                                      color: Colors.amber,
                                    ),
                                    _buildRewardMetric(
                                      value: _rpChange >= 0 ? "+$_rpChange" : "$_rpChange",
                                      label: "RP STANDINGS",
                                      icon: Icons.shield,
                                      color: _rpChange >= 0 ? AppColors.primaryNeon : Colors.redAccent,
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryNeon),
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Detailed Stats breakdown (User VS Opponent)
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: HolographicCard(
                      glowColor: themeColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.assessment, color: Colors.white70),
                              SizedBox(width: 8),
                              Text("BATTLE METRICS PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          
                          // Score Row
                          _buildMatchDetailRow(
                            label: "SCORE",
                            val1: "$p1Score Pts",
                            val2: "$p2Score Pts",
                            isV1Higher: p1Score > p2Score,
                            isV2Higher: p2Score > p1Score,
                          ),
                          const SizedBox(height: 12),
                          // Accuracy Row
                          _buildMatchDetailRow(
                            label: "ACCURACY",
                            val1: "$p1Acc%",
                            val2: "$p2Acc%",
                            isV1Higher: p1Acc > p2Acc,
                            isV2Higher: p2Acc > p1Acc,
                          ),
                          const SizedBox(height: 12),
                          // Response time
                          _buildMatchDetailRow(
                            label: "REACTION SPEED",
                            val1: "${p1Speed.toStringAsFixed(1)}s",
                            val2: "${p2Speed.toStringAsFixed(1)}s",
                            isV1Higher: p1Speed < p2Speed, // Smaller is better
                            isV2Higher: p2Speed < p1Speed,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 5. Action Buttons (Quit, Share, Re-enter lobby)
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            battleProv.leaveRoom();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "RETURN TO ARENA HUBSPACE",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            FuturisticToast.show(context, message: "Esports record generated! Shared to student feed.");
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: themeColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            "TRANSMIT DUEL RECORD",
                            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

  Widget _buildRewardMetric({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Outfit"),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white30, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildMatchDetailRow({
    required String label,
    required String val1,
    required String val2,
    required bool isV1Higher,
    required bool isV2Higher,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(
                val1,
                style: TextStyle(
                  color: isV1Higher ? AppColors.primaryNeon : Colors.white70,
                  fontSize: 12,
                  fontWeight: isV1Higher ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isV1Higher) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_upward, color: AppColors.primaryNeon, size: 10),
              ]
            ],
          ),
        ),
        const Text("VS", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isV2Higher) ...[
                const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 10),
                const SizedBox(width: 4),
              ],
              Text(
                val2,
                style: TextStyle(
                  color: isV2Higher ? Colors.redAccent : Colors.white70,
                  fontSize: 12,
                  fontWeight: isV2Higher ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Confetti Particle simulator painter
class ParticleSparklePainter extends CustomPainter {
  final double progress;
  final Color themeColor;
  final bool didWin;
  final List<Offset> _stars = [];

  ParticleSparklePainter(this.progress, this.themeColor, this.didWin) {
    final rand = javaRandom(progress);
    for (int i = 0; i < 25; i++) {
      double x = rand.nextDouble() * 400.0;
      // Stars float downward or explode from center
      double y = (rand.nextDouble() * 800.0 + progress * 200) % 800.0;
      _stars.add(Offset(x, y));
    }
  }

  // Consistent seeded pseudo-random helper to prevent flickering
  Random javaRandom(double seedVal) {
    return Random((seedVal * 1000).toInt() + 12345);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!didWin) return; // No sparkles for defeats

    final paint = Paint()
      ..color = themeColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (var pos in _stars) {
      // Map offsets relative to actual canvas sizes
      double actualX = pos.dx % size.width;
      double actualY = pos.dy % size.height;
      canvas.drawCircle(Offset(actualX, actualY), 3.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
