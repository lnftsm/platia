import 'package:flutter/foundation.dart';
import 'package:platia/data/models/membership.dart';
import 'package:platia/data/models/membership_package.dart';
import 'package:platia/data/models/payment.dart';
import 'package:platia/data/repositories/membership_repository.dart';
import 'package:platia/data/repositories/payment_repository.dart';

class MembershipProvider extends ChangeNotifier {
  final MembershipRepository _membershipRepository = MembershipRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  List<MembershipPackage> _packages = [];
  Membership? _activeMembership;
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<MembershipPackage> get packages => _packages;
  Membership? get activeMembership => _activeMembership;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasActiveMembership => _activeMembership?.isActive ?? false;
  bool get membershipExpiring => _activeMembership?.isExpiring ?? false;
  int? get remainingClasses => _activeMembership?.remainingClasses;

  Future<void> loadPackages() async {
    _setLoading(true);
    _setError(null);

    try {
      _packages = await _membershipRepository.getPackages();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadUserMembership(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _activeMembership = await _membershipRepository.getActiveMembership(
        userId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadPaymentHistory(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _payments = await _paymentRepository.getUserPayments(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> purchaseMembership({
    required String userId,
    required String packageId,
    required PaymentMethod paymentMethod,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final package = _packages.firstWhere((p) => p.id == packageId);

      // Create payment
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        amount: package.price,
        method: paymentMethod,
        status: PaymentStatus.pending,
        description: 'Membership Package: ${package.name}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _paymentRepository.createPayment(payment);

      // Create membership
      final membership = Membership(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        packageId: packageId,
        startDate: DateTime.now(),
        endDate: package.validityDays != null
            ? DateTime.now().add(Duration(days: package.validityDays!))
            : DateTime.now().add(const Duration(days: 365)),
        remainingClasses: package.classCount,
        status: MembershipStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _membershipRepository.createMembership(membership);

      // Update payment status
      await _paymentRepository.updatePaymentStatus(
        payment.id,
        PaymentStatus.completed,
      );

      // Reload membership
      await loadUserMembership(userId);

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
