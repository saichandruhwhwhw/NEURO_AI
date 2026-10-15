import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/battle_provider.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';

class VoiceBattleScreen extends StatefulWidget {
  const VoiceBattleScreen({super.key});

  @override
  State<VoiceBattleScreen> createState() => _VoiceBattleScreenState();
}

class _VoiceBattleScreenState extends State<VoiceBattleScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  String _transcription = "Say your answer...";
  double _confidence = 0.0;
  Timer? _simTimer;
  late AnimationController _pulseController;
  
  Map<String, dynamic>? _currentQuestion;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMatch();
    });
  }
  
  void _initMatch() {
    final prov = Provider.of<BattleProvider>(context, listen: false);
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    prov.createRoom('GENERAL', studentProv.studentProfile?['uid'] ?? 'u1', studentProv.studentProfile?['fullName'] ?? 'Player 1', mode: 'voice');
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecordingAndSubmit();
    } else {
      setState(() {
        _isRecording = true;
        _transcription = "Listening...";
      });
      // Simulate listening
      _simTimer = Timer(const Duration(seconds: 2), () {
        if (_isRecording) _stopRecordingAndSubmit();
      });
    }
  }

  void _stopRecordingAndSubmit() {
    _simTimer?.cancel();
    final prov = Provider.of<BattleProvider>(context, listen: false);
    final room = prov.activeRoom;
    if (room == null) return;
    
    int qIdx = room['currentQuestionIndex'];
    if (qIdx >= room['questions'].length) return;
    
    var q = room['questions'][qIdx];
    String correctAns = q['options'][q['correctIndex']].toString().toLowerCase();

    setState(() {
      _isRecording = false;
      _transcription = "Transcript: $correctAns"; // Simulated perfect transcript for demo
      _confidence = 0.94;
    });
    
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    prov.submitAnswer(studentProv.studentProfile?['uid'] ?? 'u1', qIdx, true, 2.5, 0.90);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BattleProvider>(context);
    final room = prov.activeRoom;

    if (room == null || prov.isSearching) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Pulse(infinite: true, child: const Icon(Icons.mic, color: AppColors.primaryNeon, size: 80))),
      );
    }
    
    if (room['status'] == 'completed') {
       return Scaffold(backgroundColor: Colors.black, body: const Center(child: Text("VOICE BATTLE COMPLETED", style: TextStyle(color: Colors.white, fontSize: 24))));
    }

    int qIdx = room['currentQuestionIndex'];
    if (qIdx < room['questions'].length) {
      _currentQuestion = room['questions'][qIdx];
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("VOICE BATTLE"), backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HolographicCard(
                glowColor: Colors.purpleAccent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _currentQuestion?['question'] ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red.withValues(alpha: 0.3) : Colors.purpleAccent.withValues(alpha: 0.2),
                        border: Border.all(color: _isRecording ? Colors.red : Colors.purpleAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.purpleAccent).withValues(alpha: 0.5 * _pulseController.value),
                            blurRadius: 30 * _pulseController.value,
                            spreadRadius: 10 * _pulseController.value,
                          )
                        ]
                      ),
                      child: Icon(Icons.mic, size: 60, color: _isRecording ? Colors.red : Colors.white),
                    );
                  }
                ),
              ),
              const SizedBox(height: 40),
              Text(_transcription, style: const TextStyle(color: Colors.white54, fontSize: 16, fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
              if (_confidence > 0 && !_isRecording)
                Text("Confidence: ${(_confidence * 100).toInt()}%", style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
