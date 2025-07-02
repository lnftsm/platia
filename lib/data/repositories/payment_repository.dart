import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/data/models/payment.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'payments';

  Future<List<Payment>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Payment.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  Future<void> createPayment(Payment payment) async {
    try {
      await _firestore.collection(_collection).add(payment.toJson());
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'status': status.toString().split('.').last,
        'paidAt': status == PaymentStatus.completed
            ? FieldValue.serverTimestamp()
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }
}
