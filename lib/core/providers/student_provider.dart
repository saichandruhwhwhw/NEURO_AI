import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/ai_engine.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _studentSub;
  StreamSubscription? _cognitiveHistorySub;
  StreamSubscription? _memorySub;
  StreamSubscription? _recommendationsSub;
  StreamSubscription? _notificationsSub;

  // Student profile state
  Map<String, dynamic>? studentProfile;
  List<Map<String, dynamic>> cognitiveHistory = [];
  List<Map<String, dynamic>> memoryTopics = [];
  List<Map<String, dynamic>> recommendations = [];
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic> burnoutData = {};
  Map<String, dynamic> placementData = {};
  Map<String, dynamic> skillsData = {};
  Map<String, dynamic> timetableData = {};

  bool isLoading = false;

  StudentProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initStudentData(user.uid);
      } else {
        _clearAll();
      }
    });
  }

  void _clearAll() {
    _studentSub?.cancel();
    _cognitiveHistorySub?.cancel();
    _memorySub?.cancel();
    _recommendationsSub?.cancel();
    _notificationsSub?.cancel();

    studentProfile = null;
    cognitiveHistory.clear();
    memoryTopics.clear();
    recommendations.clear();
    notifications.clear();
    burnoutData.clear();
    placementData.clear();
    skillsData.clear();
    timetableData.clear();
    notifyListeners();
  }

  void _initStudentData(String uid) {
    isLoading = true;
    notifyListeners();

    // 1. Profile stream
    _studentSub = _dbService.streamDocument(DatabaseService.colStudents, uid).listen((doc) {
      if (doc.exists) {
        studentProfile = doc.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    });

    // 2. Cognitive history stream
    _cognitiveHistorySub = FirebaseFirestore.instance
        .collection(DatabaseService.colCognitiveScores)
        .where('studentId', isEqualTo: uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snap) {
      cognitiveHistory = snap.docs.map((d) => d.data()).toList();
      notifyListeners();
    });

    // 3. Memory topics stream
    _memorySub = FirebaseFirestore.instance
        .collection(DatabaseService.colMemoryData)
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      memoryTopics = snap.docs.map((d) {
        var data = d.data();
        data['docId'] = d.id; // Store ID for updates
        
        // Dynamic AI analysis
        Timestamp lastStudiedTs = data['lastStudied'] as Timestamp;
        int revisionCount = data['revisionCount'] as int? ?? 0;
        var memoryAnalysis = AIEngine.analyzeMemoryStability(
          lastStudied: lastStudiedTs.toDate(),
          revisionCount: revisionCount,
        );
        data['forgettingProbability'] = memoryAnalysis['forgettingPercent'] / 100.0;
        data['retentionPercent'] = memoryAnalysis['retentionPercent'];
        data['actionRequired'] = memoryAnalysis['actionRequired'];
        return data;
      }).toList();
      notifyListeners();
    });

    // 4. Burnout data document fetch
    FirebaseFirestore.instance
        .collection(DatabaseService.colBurnoutData)
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        burnoutData = doc.data()!;
        notifyListeners();
      }
    });

    // 5. Placement data document fetch
    FirebaseFirestore.instance
        .collection(DatabaseService.colPlacementData)
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        placementData = doc.data()!;
        notifyListeners();
      }
    });

    // 6. Skills data document fetch
    FirebaseFirestore.instance
        .collection(DatabaseService.colSkills)
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        skillsData = doc.data()!;
        notifyListeners();
      }
    });

    // 7. Timetable data document fetch
    FirebaseFirestore.instance
        .collection(DatabaseService.colTimetables)
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        timetableData = doc.data()!;
        notifyListeners();
      }
    });

    // 8. Recommendations stream
    _recommendationsSub = FirebaseFirestore.instance
        .collection(DatabaseService.colRecommendations)
        .where('studentId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      recommendations = snap.docs.map((d) => d.data()).toList();
      notifyListeners();
    });

    // 9. Notifications stream
    _notificationsSub = FirebaseFirestore.instance
        .collection(DatabaseService.colNotifications)
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      notifications = snap.docs.map((d) => d.data()).toList();
      notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  // --- Dynamic Functions ---

  // A. Log new focus score (from camera simulation) and trigger cognitive score re-evaluation
  Future<void> logFocusSession(double newFocus, String currentEmotion) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    // 1. Add log to focus_logs collection
    await _dbService.addDocument(DatabaseService.colFocusLogs, {
      'studentId': uid,
      'focusScore': newFocus / 100.0,
      'emotion': currentEmotion,
      'engagementScore': (newFocus + 10) / 110.0, // analytical calculation
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Fetch latest attendance & academic metrics
    double attendance = studentProfile?['attendanceRate']?.toDouble() ?? 95.0;
    double currentCGPA = studentProfile?['cgpa']?.toDouble() ?? 9.2;
    double activity = (studentProfile?['learningStreak'] ?? 14) * 5.0 + 30.0;
    double quizScore = currentCGPA * 10.0; // Estimate quiz score from CGPA

    // 3. Compute new Cognitive Score using AI Engine
    var cogResult = AIEngine.calculateCognitiveStatus(
      attendance: attendance,
      quizScore: quizScore,
      focusLevel: newFocus,
      activityScore: activity,
    );

    double newCogScore = cogResult['score'];
    String cogInsight = cogResult['insight'];
    String cogPrediction = cogResult['prediction'];

    // 4. Save new cognitive score node in history
    await _dbService.addDocument(DatabaseService.colCognitiveScores, {
      'studentId': uid,
      'score': newCogScore,
      'attendanceVal': attendance,
      'quizVal': quizScore,
      'focusVal': newFocus / 100.0,
      'activityVal': activity,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 5. Update main student profile in Firestore
    await _dbService.setDocument(DatabaseService.colStudents, uid, {
      'focusLevel': newFocus,
      'cognitiveScore': newCogScore,
    });

    // 6. Generate dynamic recommendation if focus is very low
    if (newFocus < 50) {
      await _dbService.addDocument(DatabaseService.colRecommendations, {
        'studentId': uid,
        'recommendationText': "Sub-optimal focus scan detected. $cogInsight",
        'type': 'wellness',
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  // B. Register topic revision (Memory Reinforcement)
  Future<void> reviseTopic(String docId) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection(DatabaseService.colMemoryData).doc(docId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      int currentRevisions = data['revisionCount'] as int? ?? 0;
      int newRevisions = currentRevisions + 1;

      // Update in Firestore
      await FirebaseFirestore.instance.collection(DatabaseService.colMemoryData).doc(docId).update({
        'revisionCount': newRevisions,
        'lastStudied': FieldValue.serverTimestamp(),
      });

      // Boost learning streak
      int currentStreak = studentProfile?['learningStreak'] ?? 0;
      await _dbService.setDocument(DatabaseService.colStudents, uid, {
        'learningStreak': currentStreak + 1,
      });

      // Push notification
      await _dbService.addDocument(DatabaseService.colNotifications, {
        'userId': uid,
        'message': "Knowledge anchored for ${data['topic']}. Revision level: $newRevisions.",
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // C. Add a new study topic
  Future<void> addTopic(String topicName) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _dbService.addDocument(DatabaseService.colMemoryData, {
      'studentId': uid,
      'topic': topicName,
      'lastStudied': FieldValue.serverTimestamp(),
      'revisionCount': 1,
      'decayRate': 0.20,
      'forgettingProbability': 0.0,
      'reminders': ['Initial learning logged.'],
    });
  }

  // D. Log study session (Burnout monitoring)
  Future<void> logStudySession(double durationMinutes, double productivity) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    double currentDuration = burnoutData['studyDurationMinutes']?.toDouble() ?? 0.0;
    double newDuration = currentDuration + durationMinutes;

    // Run AI Burnout analysis
    var burnoutResult = AIEngine.analyzeBurnout(
      studyDurationMinutes: newDuration,
      inactivityMinutes: burnoutData['inactivityMinutes']?.toDouble() ?? 10.0,
      productivityScore: productivity,
    );

    double prob = burnoutResult['probability'];
    String risk = burnoutResult['riskLevel'];
    String recommendation = burnoutResult['recoveryRecommendation'];

    // Update in Firestore
    await _dbService.setDocument(DatabaseService.colBurnoutData, uid, {
      'studyDurationMinutes': newDuration,
      'productivityScore': productivity,
      'burnoutProbability': prob / 100.0,
      'recoveryRecommended': recommendation,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // If critical burnout probability, add alert recommendation & notification
    if (prob > 70) {
      await _dbService.addDocument(DatabaseService.colRecommendations, {
        'studentId': uid,
        'recommendationText': "SYSTEM ALERT: Burnout index at $prob%. Recommendation: $recommendation",
        'type': 'wellness',
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _dbService.addDocument(DatabaseService.colNotifications, {
        'userId': uid,
        'message': "CRITICAL WELLNESS ALERT: High fatigue values logged.",
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // E. Recover wellness (reduces study duration / fatigue)
  Future<void> triggerRecovery() async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    // Reset study session duration and set burnout back to low
    await _dbService.setDocument(DatabaseService.colBurnoutData, uid, {
      'studyDurationMinutes': 0.0,
      'productivityScore': 90.0,
      'burnoutProbability': 0.10,
      'recoveryRecommended': 'Synapses refreshed. System balanced.',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _dbService.addDocument(DatabaseService.colNotifications, {
      'userId': uid,
      'message': "Wellness recovery sequence completed. Mental load balances restored.",
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // F. Resume upload and recruitment analyzer
  Future<void> submitResumeDetails(String fileName, List<String> skills, double aptitude) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    List<String> userSkills = skills;
    List<String> targetRoleSkills = ['Python', 'SQL', 'TensorFlow', 'Data Visualizations', 'Machine Learning Deployment', 'Cloud Architecture'];

    double cgpa = studentProfile?['cgpa']?.toDouble() ?? 9.2;

    // Run Placement Predictor
    var placementResult = AIEngine.predictPlacement(
      userSkills: userSkills,
      targetRoleSkills: targetRoleSkills,
      cgpa: cgpa,
      aptitudeScore: aptitude,
    );

    double prob = placementResult['probability'];
    List<String> missing = List<String>.from(placementResult['missingSkills']);
    String insight = placementResult['insight'];

    // Save in placement_data
    await _dbService.setDocument(DatabaseService.colPlacementData, uid, {
      'studentId': uid,
      'resumeUrl': fileName,
      'aptitudeScore': aptitude.toInt(),
      'placementProbability': prob / 100.0,
      'careerSuggestions': ['Cognitive Architect', 'Machine Learning Engineer', 'Systems Data Lead'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Save/Update in skills
    await _dbService.setDocument(DatabaseService.colSkills, uid, {
      'studentId': uid,
      'skillsList': userSkills,
      'targetRole': studentProfile?['targetRole'] ?? 'Data Scientist',
      'missingSkills': missing,
    });

    await _dbService.addDocument(DatabaseService.colNotifications, {
      'userId': uid,
      'message': "Resume parsed successfully. Target role placement score: ${(prob).toInt()}%.",
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // G. Update target role
  Future<void> updateTargetRole(String newRole) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _dbService.setDocument(DatabaseService.colStudents, uid, {
      'targetRole': newRole,
    });
    
    // Also update in skills matching
    await _dbService.setDocument(DatabaseService.colSkills, uid, {
      'targetRole': newRole,
    });
  }

  // H. Generate/Reschedule timetable
  Future<void> updateTimetable(Map<String, List<Map<String, String>>> newSchedule) async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _dbService.setDocument(DatabaseService.colTimetables, uid, {
      'studentId': uid,
      'schedule': newSchedule,
    });

    await _dbService.addDocument(DatabaseService.colNotifications, {
      'userId': uid,
      'message': "AI Timetable optimizer compiled a new study arrangement.",
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
