import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/data/models/reservation.dart';

class ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Reservation.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reservations: $e');
    }
  }

  Future<void> createReservation({
    required String userId,
    required String scheduleId,
  }) async {
    try {
      // Check if already reserved
      final existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('scheduleId', isEqualTo: scheduleId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Already reserved');
      }

      // Create reservation
      final reservation = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        scheduleId: scheduleId,
        reservedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection(_collection).add(reservation.toJson());

      // Update class enrollment count
      await _firestore.collection('schedules').doc(scheduleId).update({
        'currentEnrollment': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    try {
      // Get reservation details
      final doc = await _firestore
          .collection(_collection)
          .doc(reservationId)
          .get();
      if (!doc.exists) {
        throw Exception('Reservation not found');
      }

      final reservation = Reservation.fromJson({...doc.data()!, 'id': doc.id});

      // Update reservation status
      await _firestore.collection(_collection).doc(reservationId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update class enrollment count
      await _firestore
          .collection('schedules')
          .doc(reservation.scheduleId)
          .update({'currentEnrollment': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }
}
