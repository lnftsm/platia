import 'package:flutter/foundation.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/data/models/membership.dart';
import 'package:platia/data/models/payment.dart';
import 'package:platia/data/repositories/user_repository.dart';
import 'package:platia/data/repositories/membership_repository.dart';
import 'package:platia/data/repositories/payment_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final MembershipRepository _membershipRepository = MembershipRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  List<User> _users = [];
  User? _selectedUser;
  Membership? _currentMembership;
  List<Payment> _userPayments = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  Membership? get currentMembership => _currentMembership;
  List<Payment> get userPayments => _userPayments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers({String? role}) async {
    _setLoading(true);
    _setError(null);

    try {
      _users = await _userRepository.getUsers(role: role);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadUserDetails(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedUser = await _userRepository.getUser(userId);
      _currentMembership = await _membershipRepository.getActiveMembership(
        userId,
      );
      _userPayments = await _paymentRepository.getUserPayments(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> createUser(User user) async {
    _setLoading(true);
    _setError(null);

    try {
      await _userRepository.createUser(user);
      await loadUsers();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    _setLoading(true);
    _setError(null);

    try {
      await _userRepository.updateUser(user);
      if (_selectedUser?.id == user.id) {
        _selectedUser = user;
      }
      await loadUsers();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _userRepository.deleteUser(userId);
      await loadUsers();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
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
