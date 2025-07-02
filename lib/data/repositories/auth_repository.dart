import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:platia/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Stream<fb.User?> get authStateChanges => _authService.authStateChanges;

  fb.User? get currentUser => _authService.currentUser;

  Future<fb.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb.User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    return await _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    return await _authService.signOut();
  }
}
