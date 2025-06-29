import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:platia/models/user.dart' as app_user;
import 'package:platia/services/auth_service.dart';

// AuthProvider manages user authentication state and operations.
// It provides methods for registration, login, profile updates, and more.
// initial: The initial state when the provider is created.
// authenticated: The user is logged in and authenticated.
// unauthenticated: The user is logged out or not authenticated.
// loading: The provider is currently performing an operation (e.g., loading user data).

// AuthProvider, kullanıcı kimlik doğrulama durumunu ve işlemlerini yönetir.
// Kayıt, giriş, profil güncellemeleri ve daha fazlası için yöntemler sağlar.
// initial: Sağlayıcı oluşturulduğunda başlangıç durumu.
// authenticated: Kullanıcı giriş yaptı ve kimlik doğrulandı.
// unauthenticated: Kullanıcı oturumu kapattı veya kimlik doğrulanmadı.
// loading: Sağlayıcı şu anda bir işlem gerçekleştiriyor (örneğin, kullanıcı verilerini yükleme).
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  app_user.User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  app_user.User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initAuthProvider();
  }

  void _initAuthProvider() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData();
      } else {
        _setUnauthenticated();
      }
    });
  }

  Future<void> _loadUserData() async {
    _setLoading();
    final response = await AuthService.getCurrentUserData();

    if (response.success && response.data != null) {
      _setAuthenticated(response.data!);
    } else {
      _setError(response.message ?? 'Failed to load user data');
      _setUnauthenticated();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    DateTime? birthDate,
    String? gender,
  }) async {
    _setLoading();

    final response = await AuthService.registerWithEmailPassword(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      gender: gender,
    );

    if (response.success && response.data != null) {
      _setAuthenticated(response.data!);
      return true;
    } else {
      _setError(response.message ?? 'Registration failed');
      _setUnauthenticated();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    final response = await AuthService.loginWithEmailPassword(
      email: email,
      password: password,
    );

    if (response.success && response.data != null) {
      _setAuthenticated(response.data!);
      return true;
    } else {
      _setError(response.message ?? 'Login failed');
      _setUnauthenticated();
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _setLoading();

    final response = await AuthService.resetPassword(email: email);

    if (response.success) {
      _clearError();
      _setUnauthenticated(); // Return to unauthenticated state
      return true;
    } else {
      _setError(response.message ?? 'Password reset failed');
      return false;
    }
  }

  Future<bool> updateProfile(app_user.User updatedUser) async {
    _setLoading();

    final response = await AuthService.updateUserProfile(user: updatedUser);

    if (response.success && response.data != null) {
      _setAuthenticated(response.data!);
      return true;
    } else {
      _setError(response.message ?? 'Profile update failed');
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading();
    await AuthService.signOut();
    _setUnauthenticated();
  }

  Future<bool> deleteAccount() async {
    _setLoading();

    final response = await AuthService.deleteAccount();

    if (response.success) {
      _setUnauthenticated();
      return true;
    } else {
      _setError(response.message ?? 'Failed to delete account');
      return false;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _clearError();
    notifyListeners();
  }

  void _setAuthenticated(app_user.User user) {
    _status = AuthStatus.authenticated;
    _user = user;
    _clearError();
    notifyListeners();
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _clearError();
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

extension UserExtension on app_user.User {
  app_user.User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    DateTime? updatedAt,
    bool? isActive,
    bool? kvkkConsent,
  }) {
    return app_user.User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      kvkkConsent: kvkkConsent ?? this.kvkkConsent,
    );
  }
}
