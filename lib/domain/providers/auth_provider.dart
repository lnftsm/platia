import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:platia/data/models/user.dart';
import 'package:platia/data/services/auth_service.dart';
import 'package:platia/data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);

    try {
      final fbUser = _authService.currentUser;
      if (fbUser != null) {
        _currentUser = await _userRepository.getUser(fbUser.uid);
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final fbUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (fbUser != null) {
        _currentUser = await _userRepository.getUser(fbUser.uid);
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    DateTime? birthDate,
    String? gender,
    required bool kvkkConsent,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final fbUser = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (fbUser != null) {
        final user = User(
          id: fbUser.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          gender: gender,
          kvkkConsent: kvkkConsent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userRepository.createUser(user);
        _currentUser = user;
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    _setLoading(true);
    _setError(null);

    try {
      await _userRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Add this method for creating user accounts (admin creating instructors)
  Future<void> createUserAccount({
    required String email,
    required String password,
    required String userId,
  }) async {
    await _authService.createUserAccount(
      email: email,
      password: password,
      userId: userId,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
