import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User and Save Profile to Firestore
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save role and profile data to Firestore
      if (userCredential.user != null) {
        profileData['role'] = role;
        profileData['email'] = email;
        profileData['createdAt'] = FieldValue.serverTimestamp();
        
        await _firestore.collection('users').doc(userCredential.user!.uid).set(profileData);
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login User and Fetch Role
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("AuthService: Attempting login for $email");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("AuthService: Login success. Fetching role from Firestore for UID: ${userCredential.user?.uid}");
      if (userCredential.user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          debugPrint("AuthService: User document found.");
          return doc.data() as Map<String, dynamic>?;
        } else {
          debugPrint("AuthService: User document DOES NOT exist in Firestore.");
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("AuthService [FirebaseAuthException]: Code = ${e.code}, Message = ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("AuthService [General Exception]: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if an email is registered in Firestore
  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("AuthService [checkEmailExists Exception]: $e");
      return false;
    }
  }

  // Send Password Reset Email
  Future<void> sendResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("AuthService [sendResetEmail Exception]: $e");
      rethrow;
    }
  }

  // Reauthenticate & Update Password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No active authenticated user session found.',
        );
      }

      // Reauthenticate the user first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update the password
      await user.updatePassword(newPassword);
      
      // Reload user to refresh session
      await user.reload();
    } on FirebaseAuthException catch (e) {
      debugPrint("AuthService [changePassword FirebaseAuthException]: Code = ${e.code}, Message = ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("AuthService [changePassword General Exception]: $e");
      rethrow;
    }
  }
}

