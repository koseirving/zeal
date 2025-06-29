import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'login_history_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoginHistoryService _loginHistoryService = LoginHistoryService();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isAuthenticated => _auth.currentUser != null;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Record login history
        await _loginHistoryService.recordLogin(credential.user!.uid);
        
        // Get or create user data in Firestore
        return await _getOrCreateUserData(credential.user!);
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        
        // Record login history
        await _loginHistoryService.recordLogin(credential.user!.uid);
        
        // Create user data in Firestore
        return await _createUserData(
          user: credential.user!,
          displayName: displayName,
        );
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected sign up error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in anonymously (guest user)
  Future<UserModel?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        // Record login history
        await _loginHistoryService.recordLogin(credential.user!.uid);
        
        // Create guest user data
        return await _createUserData(
          user: credential.user!,
          displayName: 'Guest User',
          isGuest: true,
        );
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Anonymous sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected anonymous sign in error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected password reset error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user is currently signed in.';
      
      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      
      // Update Firestore user data
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(user.uid).update(updates);
      
      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Update profile error: $e');
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user is currently signed in.';
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user from Firebase Auth
      await user.delete();
      
      debugPrint('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Please sign in again before deleting your account.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Delete account error: $e');
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      
      return null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }

  // Stream user data changes
  Stream<UserModel?> streamUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Private helper methods
  Future<UserModel> _getOrCreateUserData(User user) async {
    try {
      // Check if user data exists
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        return UserModel.fromFirestore(doc);
      } else {
        // Create new user data
        return await _createUserData(
          user: user,
          displayName: user.displayName ?? 'User',
        );
      }
    } catch (e) {
      debugPrint('Get or create user data error: $e');
      // Return a basic user model if Firestore fails
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<UserModel> _createUserData({
    required User user,
    required String displayName,
    bool isGuest = false,
  }) async {
    try {
      final userData = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoURL: user.photoURL,
        isGuest: isGuest,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData.toFirestore());
      
      debugPrint('User data created successfully for: ${user.uid}');
      return userData;
    } catch (e) {
      debugPrint('Create user data error: $e');
      // Return a basic user model if Firestore fails
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        isGuest: isGuest,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}