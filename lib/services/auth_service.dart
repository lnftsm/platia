import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/providers/auth_provider.dart';

import '../models/user.dart' as app_user;
import '../models/api_response.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  static Future<ApiResponse<app_user.User>> registerWithEmailPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      // Create Firebase Auth account
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');

        // Create user document in Firestore
        final appUser = app_user.User(
          id: credential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          gender: gender,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          kvkkConsent: true,
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toJson());

        return ApiResponse.success(
          data: appUser,
          message: 'Account created successfully',
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to create account',
          statusCode: 400,
        );
      }
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(
        message: _getAuthErrorMessage(e),
        statusCode: _getAuthErrorCode(e),
        errors: {'firebase': e.code},
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  // Login with email and password
  static Future<ApiResponse<app_user.User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final appUser = app_user.User.fromJson({
            'id': credential.user!.uid,
            ...userDoc.data()!,
          });

          return ApiResponse.success(
            data: appUser,
            message: 'Login successful',
          );
        } else {
          // User document doesn't exist, create minimal one
          final appUser = app_user.User(
            id: credential.user!.uid,
            firstName: credential.user!.displayName?.split(' ').first ?? 'User',
            lastName:
                credential.user!.displayName?.split(' ').skip(1).join(' ') ??
                '',
            email: credential.user!.email!,
            phoneNumber: credential.user!.phoneNumber ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            kvkkConsent: false,
          );

          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set(appUser.toJson());

          return ApiResponse.success(data: appUser);
        }
      } else {
        return ApiResponse.error(message: 'Login failed', statusCode: 400);
      }
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(
        message: _getAuthErrorMessage(e),
        statusCode: _getAuthErrorCode(e),
        errors: {'firebase': e.code},
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  // Reset password
  static Future<ApiResponse<void>> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ApiResponse.success(message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(
        message: _getAuthErrorMessage(e),
        statusCode: _getAuthErrorCode(e),
      );
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // Sign out
  static Future<ApiResponse<void>> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      return ApiResponse.success(message: 'Signed out successfully');
    } catch (e) {
      return ApiResponse.error(message: 'Sign out failed');
    }
  }

  // Get current user data
  static Future<ApiResponse<app_user.User>> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse.error(message: 'No user logged in', statusCode: 401);
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final appUser = app_user.User.fromJson({
          'id': user.uid,
          ...userDoc.data()!,
        });
        return ApiResponse.success(data: appUser);
      } else {
        return ApiResponse.error(
          message: 'User data not found',
          statusCode: 404,
        );
      }
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get user data');
    }
  }

  // Update user profile
  static Future<ApiResponse<app_user.User>> updateUserProfile({
    required app_user.User user,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ApiResponse.error(message: 'No user logged in', statusCode: 401);
      }

      // Update Firebase Auth profile
      await currentUser.updateDisplayName(user.fullName);

      // Update Firestore document
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedUser.toJson());

      return ApiResponse.success(data: updatedUser, message: 'Profile updated');
    } catch (e) {
      return ApiResponse.error(message: 'Failed to update profile');
    }
  }

  // Delete account
  static Future<ApiResponse<void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ApiResponse.error(message: 'No user logged in', statusCode: 401);
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      return ApiResponse.success(message: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return ApiResponse.error(
          message: 'Please log in again to delete your account',
          statusCode: 403,
        );
      }
      return ApiResponse.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return ApiResponse.error(message: 'Failed to delete account');
    }
  }

  // Helper methods for error handling
  static String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  static int _getAuthErrorCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 401;
      case 'email-already-in-use':
        return 409;
      case 'weak-password':
      case 'invalid-email':
        return 400;
      case 'user-disabled':
        return 403;
      case 'too-many-requests':
        return 429;
      default:
        return 500;
    }
  }
}
