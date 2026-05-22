import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // Local student state
  int coins = 350;
  int xp = 1200;
  int rankPoints = 450; // Bronze: 0-200, Silver: 201-400, Gold: 401-650, Platinum: 651-900, Diamond: 901-1200, Elite: 1201-1600, Master: 1601+
  int winStreak = 4;
  int dailyStreakCount = 7;
  
  // Powerups inventory
  Map<String, int> powerups = {
    'hint': 2,
    '50_50': 1,
    'double_points': 3,
    'freeze_timer': 1,
    'skip': 0,
    'time_boost': 2,
  };

  // Daily quests tracking
  List<Map<String, dynamic>> dailyQuests = [
    {'id': 'win_bot', 'desc': 'Win 2 matches against AI Bot', 'target': 2, 'current': 1, 'rewardXP': 100, 'rewardCoins': 50, 'completed': false},
    {'id': 'high_acc', 'desc': 'Achieve >85% accuracy in any battle', 'target': 1, 'current': 0, 'rewardXP': 150, 'rewardCoins': 80, 'completed': false},
    {'id': 'use_powerup', 'desc': 'Use 3 powerups in live battles', 'target': 3, 'current': 1, 'rewardXP': 80, 'rewardCoins': 40, 'completed': false},
  ];

  // Active multiplayer room state
  StreamSubscription? _roomSub;
  Map<String, dynamic>? activeRoom;
  bool isSearching = false;

  // Department scores
  Map<String, int> departmentScores = {
    'CSE': 1420,
    'IT': 1380,
    'AIDS': 1490,
    'ECE': 1210,
    'MECH': 980,
    'CIVIL': 850,
  };

  // Global leaderboard
  List<Map<String, dynamic>> leaderboard = [];

  // Question bank with diverse subjects
  final List<Map<String, dynamic>> _questionBank = [
    // Coding
    {
      'question': 'Which Dart collection type maintains insertion order and allows unique items only?',
      'options': ['List', 'Map', 'Set', 'LinkedHashSet'],
      'correctIndex': 3,
      'category': 'Coding'
    },
    {
      'question': 'What is the time complexity of searching in a balanced Binary Search Tree?',
      'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
      'correctIndex': 1,
      'category': 'Coding'
    },
    // AI / ML
    {
      'question': 'Which activation function is commonly used to prevent vanishing gradient problems?',
      'options': ['Sigmoid', 'Tanh', 'ReLU', 'Softmax'],
      'correctIndex': 2,
      'category': 'Artificial Intelligence'
    },
    {
      'question': 'What technique regularizes deep neural networks by randomly dropping neurons during training?',
      'options': ['Batch Normalization', 'Gradient Descent', 'Dropout', 'Weight Decay'],
      'correctIndex': 2,
      'category': 'Artificial Intelligence'
    },
    // Aptitude
    {
      'question': 'A train traveling at 60 km/h passes a post in 9 seconds. What is the length of the train in meters?',
      'options': ['120m', '150m', '180m', '200m'],
      'correctIndex': 1,
      'category': 'Aptitude'
    },
    {
      'question': 'If 5 machines take 5 minutes to produce 5 widgets, how long would it take 100 machines to make 100 widgets?',
      'options': ['5 minutes', '20 minutes', '50 minutes', '100 minutes'],
      'correctIndex': 0,
      'category': 'Aptitude'
    },
    // Memory
    {
      'question': 'According to Ebbinghaus forgetting curve theory, within what timeframe does the steepest drop in memory recall happen?',
      'options': ['First 20 minutes', 'First 2 hours', 'First 24 hours', 'First week'],
      'correctIndex': 0,
      'category': 'Memory'
    },
    // Cognitive
    {
      'question': 'Complete the series: 2, 6, 12, 20, 30, ?',
      'options': ['36', '40', '42', '46'],
      'correctIndex': 2,
      'category': 'Cognitive'
    },
    {
      'question': 'In a vector space, if vectors A and B are orthogonal, what is their dot product?',
      'options': ['0', '1', '-1', 'Infinity'],
      'correctIndex': 0,
      'category': 'Cognitive'
    },
    {
      'question': 'What protocol operates at the Application Layer (Layer 7) of the OSI model?',
      'options': ['TCP', 'IP', 'HTTP', 'Ethernet'],
      'correctIndex': 2,
      'category': 'Department Core'
    }
  ];

  BattleProvider() {
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    leaderboard = [
      {'name': 'Alex Mercer', 'dept': 'CSE', 'wins': 142, 'accuracy': 92, 'speed': 1.8, 'rank': 'Cognitive Master'},
      {'name': 'Marcus Vance', 'dept': 'AIDS', 'wins': 128, 'accuracy': 89, 'speed': 2.1, 'rank': 'Elite'},
      {'name': 'Elena Rostova', 'dept': 'ECE', 'wins': 115, 'accuracy': 91, 'speed': 1.9, 'rank': 'Elite'},
      {'name': 'Sarah Connor', 'dept': 'IT', 'wins': 98, 'accuracy': 85, 'speed': 2.3, 'rank': 'Diamond'},
      {'name': 'T-800 Solver', 'dept': 'CSE', 'wins': 92, 'accuracy': 98, 'speed': 1.1, 'rank': 'Cognitive Master'},
    ];
  }

  // --- POWERUP SHOP ACTIONS ---
  bool buyPowerup(String powerupId, int cost) {
    if (coins >= cost) {
      coins -= cost;
      powerups[powerupId] = (powerups[powerupId] ?? 0) + 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  void usePowerup(String powerupId) {
    if ((powerups[powerupId] ?? 0) > 0) {
      powerups[powerupId] = powerups[powerupId]! - 1;
      
      // Update Quest progress if using in game
      var quest = dailyQuests.firstWhere((q) => q['id'] == 'use_powerup');
      if (quest['current'] < quest['target']) {
        quest['current'] += 1;
        if (quest['current'] == quest['target']) {
          quest['completed'] = true;
          coins += quest['rewardCoins'] as int;
          xp += quest['rewardXP'] as int;
        }
      }
      notifyListeners();
    }
  }

  // --- QUEST COMPLETIONS ---
  void incrementQuestProgress(String questId, int val) {
    var quest = dailyQuests.firstWhere((q) => q['id'] == questId);
    if (!quest['completed'] && quest['current'] < quest['target']) {
      quest['current'] += val;
      if (quest['current'] >= quest['target']) {
        quest['completed'] = true;
        coins += quest['rewardCoins'] as int;
        xp += quest['rewardXP'] as int;
      }
      notifyListeners();
    }
  }

  // --- MULTIPLAYER ROOM ENGINE ---

  // 1. Create Room on Firestore
  Future<String> createRoom(String subject, String studentId, String studentName) async {
    isSearching = true;
    notifyListeners();

    String roomId = "room_${_random.nextInt(8999) + 1000}";
    
    // Choose 10 random questions from bank
    List<Map<String, dynamic>> selectedQuestions = List.from(_questionBank);
    selectedQuestions.shuffle();
    if (selectedQuestions.length > 10) {
      selectedQuestions = selectedQuestions.sublist(0, 10);
    }

    final roomDoc = {
      'roomId': roomId,
      'subject': subject,
      'status': 'waiting',
      'currentQuestionIndex': 0,
      'questions': selectedQuestions,
      'player1': {
        'uid': studentId,
        'name': studentName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.90,
        'answers': [], // list of bools
      },
      'player2': null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('battle_rooms').doc(roomId).set(roomDoc);
    subscribeToRoom(roomId);
    
    return roomId;
  }

  // 2. Join Room on Firestore
  Future<bool> joinRoom(String roomId, String studentId, String studentName) async {
    isSearching = true;
    notifyListeners();

    DocumentReference ref = _firestore.collection('battle_rooms').doc(roomId);
    DocumentSnapshot snap = await ref.get();

    if (snap.exists) {
      var data = snap.data() as Map<String, dynamic>;
      if (data['status'] == 'waiting' && data['player2'] == null) {
        // Join room
        await ref.update({
          'player2': {
            'uid': studentId,
            'name': studentName,
            'score': 0,
            'accuracy': 0,
            'speed': 0.0,
            'focus': 0.88,
            'answers': [],
          },
          'status': 'countdown' // Trigger countdown for both
        });

        subscribeToRoom(roomId);
        return true;
      }
    }

    isSearching = false;
    notifyListeners();
    return false;
  }

  // 3. Listen to Active Room changes
  void subscribeToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = _firestore.collection('battle_rooms').doc(roomId).snapshots().listen((snap) {
      if (snap.exists) {
        activeRoom = snap.data();
        isSearching = false;
        notifyListeners();
      }
    });
  }

  // 4. Submit Answer during battle
  Future<void> submitAnswer(String studentId, int questionIndex, bool isCorrect, double responseTime, double focusVal) async {
    if (activeRoom == null) return;
    String roomId = activeRoom!['roomId'];
    DocumentReference ref = _firestore.collection('battle_rooms').doc(roomId);

    Map<String, dynamic> room = Map.from(activeRoom!);
    bool isPlayer1 = room['player1']['uid'] == studentId;

    String playerKey = isPlayer1 ? 'player1' : 'player2';
    var player = Map<String, dynamic>.from(room[playerKey]);

    List<dynamic> answers = List.from(player['answers']);
    if (answers.length > questionIndex) return; // Already answered this

    answers.add(isCorrect);
    
    // Score Calculation:
    // Base correct = 10 pts.
    // Reaction Speed Bonus: if answered within 2s +5 pts.
    int pts = 0;
    if (isCorrect) {
      pts = 10;
      if (responseTime < 2.0) pts += 5;
    }

    player['score'] = (player['score'] as int) + pts;
    player['answers'] = answers;
    
    // Recalculate average speed & accuracy
    int totalAnswers = answers.length;
    int correctCount = answers.where((a) => a == true).length;
    player['accuracy'] = ((correctCount / totalAnswers) * 100).toInt();
    
    double prevSpeed = player['speed']?.toDouble() ?? 0.0;
    player['speed'] = (prevSpeed * (totalAnswers - 1) + responseTime) / totalAnswers;
    player['focus'] = focusVal;

    // Update locally
    room[playerKey] = player;

    // Check if both answered current question
    var opponentKey = isPlayer1 ? 'player2' : 'player1';
    var opponent = room[opponentKey];

    bool opponentAnswered = opponent != null && (opponent['answers'] as List).length > questionIndex;
    int nextIndex = room['currentQuestionIndex'];

    if (opponentAnswered || room['status'] == 'bot_active') {
      // Both answered (or playing against bot), advance question index
      nextIndex = questionIndex + 1;
      if (nextIndex >= 10) {
        room['status'] = 'completed';
      }
    }

    await ref.update({
      playerKey: player,
      'currentQuestionIndex': nextIndex,
      'status': room['status'],
    });
  }

  // 5. Leave Room / Clear State
  void leaveRoom() {
    _roomSub?.cancel();
    activeRoom = null;
    isSearching = false;
    notifyListeners();
  }

  // --- LOCAL AI BOT BATTLE SIMULATOR ---
  void startBotBattle(String difficulty, String studentId, String studentName) {
    isSearching = true;
    notifyListeners();

    // Select questions
    List<Map<String, dynamic>> selectedQuestions = List.from(_questionBank);
    selectedQuestions.shuffle();
    if (selectedQuestions.length > 10) {
      selectedQuestions = selectedQuestions.sublist(0, 10);
    }

    String botName = "Neuro-Bot v1.0";
    double botAccuracy = 0.50; // Easy
    double minSpeed = 3.0;
    double maxSpeed = 6.0;

    if (difficulty == 'Medium') {
      botName = "Cognitive-Cortex";
      botAccuracy = 0.70;
      minSpeed = 2.0;
      maxSpeed = 4.5;
    } else if (difficulty == 'Hard') {
      botName = "Cybernetic-Brain";
      botAccuracy = 0.88;
      minSpeed = 1.2;
      maxSpeed = 3.0;
    } else if (difficulty == 'Expert') {
      botName = "Alpha-Synapse AI";
      botAccuracy = 0.96;
      minSpeed = 0.6;
      maxSpeed = 1.8;
    }

    activeRoom = {
      'roomId': 'local_bot_match',
      'subject': 'AI Neural Training',
      'status': 'bot_active',
      'currentQuestionIndex': 0,
      'questions': selectedQuestions,
      'player1': {
        'uid': studentId,
        'name': studentName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.92,
        'answers': [],
      },
      'player2': {
        'uid': 'ai_bot_opponent',
        'name': botName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.95,
        'answers': [],
      },
      'bot_params': {
        'accuracy': botAccuracy,
        'minSpeed': minSpeed,
        'maxSpeed': maxSpeed,
      }
    };

    isSearching = false;
    notifyListeners();

    // Start bot solver trigger
    _runBotSimulation();
  }

  void _runBotSimulation() async {
    while (activeRoom != null && activeRoom!['status'] == 'bot_active') {
      int currIdx = activeRoom!['currentQuestionIndex'];
      if (currIdx >= 10) {
        activeRoom!['status'] = 'completed';
        notifyListeners();
        break;
      }

      var bot = activeRoom!['player2'];
      List<dynamic> botAnswers = List.from(bot['answers']);
      
      // If bot hasn't answered current index yet
      if (botAnswers.length <= currIdx) {
        var params = activeRoom!['bot_params'];
        double speedSec = params['minSpeed'] + _random.nextDouble() * (params['maxSpeed'] - params['minSpeed']);
        
        await Future.delayed(Duration(milliseconds: (speedSec * 1000).toInt()));
        
        if (activeRoom == null || activeRoom!['status'] != 'bot_active' || activeRoom!['currentQuestionIndex'] != currIdx) {
          continue;
        }

        // Generate bot answer correctness
        bool botCorrect = _random.nextDouble() < params['accuracy'];
        botAnswers.add(botCorrect);
        
        int botPts = 0;
        if (botCorrect) {
          botPts = 10;
          if (speedSec < 2.0) botPts += 5;
        }

        bot['score'] = (bot['score'] as int) + botPts;
        bot['answers'] = botAnswers;
        
        int total = botAnswers.length;
        int corrects = botAnswers.where((a) => a == true).length;
        bot['accuracy'] = ((corrects / total) * 100).toInt();
        
        double prevS = bot['speed']?.toDouble() ?? 0.0;
        bot['speed'] = (prevS * (total - 1) + speedSec) / total;

        activeRoom!['player2'] = bot;
        
        // If player 1 also answered, we advance index
        var player1 = activeRoom!['player1'];
        if ((player1['answers'] as List).length > currIdx) {
          activeRoom!['currentQuestionIndex'] = currIdx + 1;
          if (activeRoom!['currentQuestionIndex'] >= 10) {
            activeRoom!['status'] = 'completed';
          }
        }
        notifyListeners();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // --- POST-MATCH REWARDS DISPATCH ---
  Future<Map<String, dynamic>> finalizeMatchRewards(String studentId, bool didUserWin, int userScore, int userAccuracy, double userSpeed) async {
    int earnedXP = 50 + (userScore * 1.5).toInt();
    int earnedCoins = 20 + (userScore * 0.8).toInt();
    int rpChange = didUserWin ? 25 : -10;

    if (didUserWin) {
      earnedXP += 100; // Win bonus
      earnedCoins += 50;
      winStreak += 1;
      
      // Update Quests progress
      incrementQuestProgress('win_bot', 1);
    } else {
      winStreak = 0;
    }

    if (userAccuracy > 85) {
      incrementQuestProgress('high_acc', 1);
    }

    xp += earnedXP;
    coins += earnedCoins;
    rankPoints = (rankPoints + rpChange).clamp(0, 5000);

    // Save final stats to Firestore
    try {
      final studentRef = _firestore.collection(DatabaseService.colStudents).doc(studentId);
      final profileSnap = await studentRef.get();
      if (profileSnap.exists) {
        var profile = profileSnap.data() as Map<String, dynamic>;
        
        // Recalculate cognitive score based on match performance
        double prevCognitive = profile['cognitiveScore']?.toDouble() ?? 90.0;
        // Accuracy and speed feed into new cognitive score
        double matchCognitiveContribution = (userAccuracy * 0.7) + ((10.0 - userSpeed.clamp(1.0, 10.0)) * 3.0);
        double finalCognitive = (prevCognitive * 0.95) + (matchCognitiveContribution * 0.05);

        await studentRef.update({
          'cognitiveScore': double.parse(finalCognitive.toStringAsFixed(1)),
          'learningStreak': didUserWin ? (profile['learningStreak'] ?? 0) + 1 : profile['learningStreak'],
        });

        // Add cognitive score history log
        await _firestore.collection(DatabaseService.colCognitiveScores).add({
          'studentId': studentId,
          'score': double.parse(finalCognitive.toStringAsFixed(1)),
          'attendanceVal': profile['attendanceRate'] ?? 95.0,
          'quizVal': userAccuracy.toDouble(),
          'focusVal': 0.92,
          'activityVal': (userScore * 2.0).clamp(0, 100),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("BattleProvider: Error writing rewards to Firestore: $e");
    }

    notifyListeners();
    
    return {
      'xp': earnedXP,
      'coins': earnedCoins,
      'rp': rpChange,
      'winStreak': winStreak,
    };
  }

  // --- DEPARTMENT MATCH STANDINGS UPDATE ---
  void logDepartmentWarMatch(String userDept, String opponentDept, bool didUserWin) {
    if (didUserWin) {
      departmentScores[userDept] = (departmentScores[userDept] ?? 0) + 30;
    } else {
      departmentScores[opponentDept] = (departmentScores[opponentDept] ?? 0) + 30;
      departmentScores[userDept] = (departmentScores[userDept] ?? 0) + 10; // consolidation points
    }
    notifyListeners();
  }
}
