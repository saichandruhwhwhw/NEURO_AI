import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> faculty = [];
  List<Map<String, dynamic>> auditLogs = [];

  bool isLoading = false;
  StreamSubscription? _studentsSub;
  StreamSubscription? _facultySub;

  AdminProvider() {
    _initAdminData();
  }

  void _initAdminData() {
    isLoading = true;
    notifyListeners();

    // 1. Stream students list
    _studentsSub = FirebaseFirestore.instance
        .collection(DatabaseService.colStudents)
        .snapshots()
        .listen((snap) {
      students = snap.docs.map((d) {
        var data = d.data();
        data['uid'] = d.id;
        return data;
      }).toList();
      notifyListeners();
    });

    // 2. Stream faculty list
    _facultySub = FirebaseFirestore.instance
        .collection(DatabaseService.colUsers)
        .where('role', isEqualTo: 'faculty')
        .snapshots()
        .listen((snap) {
      faculty = snap.docs.map((d) {
        var data = d.data();
        data['uid'] = d.id;
        return data;
      }).toList();
      notifyListeners();
    });

    // Seed some mock audit logs for the security command center
    _seedAuditLogs();

    isLoading = false;
    notifyListeners();
  }

  void _seedAuditLogs() {
    auditLogs = [
      {'event': 'Database Encryption Verification', 'status': 'Secured', 'timestamp': 'Just Now'},
      {'event': 'AI Models Synchronization', 'status': 'Optimal', 'timestamp': '3 mins ago'},
      {'event': 'Firestore Reads Peak Control', 'status': 'Safe', 'timestamp': '12 mins ago'},
      {'event': 'Faculty Registration Uplink', 'status': 'Approved', 'timestamp': '1 hour ago'},
      {'event': 'Intrusion Detection Scan', 'status': '0 Threats', 'timestamp': '2 hours ago'},
    ];
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _facultySub?.cancel();
    super.dispose();
  }

  // --- Dynamic Actions ---

  // A. Create a user (student/faculty) in Firestore
  Future<void> createUserProfile(String email, String fullName, String role, String specificId, String department) async {
    // Generate a random ID for Firestore since Auth creates credentials
    String randomUid = "user_${DateTime.now().millisecondsSinceEpoch}";
    
    final data = {
      'uid': randomUid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (role == 'student') {
      data['studentId'] = specificId;
      data['year'] = '1st Year';
      data['cognitiveScore'] = 80.0;
      data['focusLevel'] = 80.0;
      data['attendanceRate'] = 100.0;
      data['learningStreak'] = 1;
      data['cognitiveRank'] = students.length + 1;
      data['cgpa'] = 8.0;
      data['targetRole'] = 'General Engineer';

      await _dbService.setDocument(DatabaseService.colUsers, randomUid, data);
      await _dbService.setDocument(DatabaseService.colStudents, randomUid, data);
      
      // Seed default timetable, burnout, skills as well
      await _dbService.seedInitialStudentData(randomUid, email, fullName, specificId, department, '1st Year');
    } else {
      data['facultyId'] = specificId;
      data['assignedClasses'] = ['CS-501', 'CS-101'];
      await _dbService.setDocument(DatabaseService.colUsers, randomUid, data);
    }

    // Add log
    auditLogs.insert(0, {
      'event': 'Created $role Profile: $fullName',
      'status': 'Success',
      'timestamp': 'Just Now',
    });
    notifyListeners();
  }

  // B. Delete a student/faculty user
  Future<void> deleteUserProfile(String userId, String role) async {
    await FirebaseFirestore.instance.collection(DatabaseService.colUsers).doc(userId).delete();
    if (role == 'student') {
      await FirebaseFirestore.instance.collection(DatabaseService.colStudents).doc(userId).delete();
    }

    auditLogs.insert(0, {
      'event': 'Deleted $role Profile: $userId',
      'status': 'Completed',
      'timestamp': 'Just Now',
    });
    notifyListeners();
  }

  // C. PDF and Excel Export Simulator
  Future<String> exportPerformanceReport(String format) async {
    // Return a simulated path
    await Future.delayed(const Duration(seconds: 2)); // Simulate file rendering
    String path = "C:/Users/MegalaM/neurolearn_ai/reports/cognitive_report_${DateTime.now().millisecondsSinceEpoch}.$format";
    
    auditLogs.insert(0, {
      'event': 'Report exported to $format',
      'status': 'Rendered',
      'timestamp': 'Just Now',
    });
    notifyListeners();
    return path;
  }
}
