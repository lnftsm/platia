import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/data/models/instructor.dart';

class InstructorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'instructors';

  Future<Instructor?> getInstructor(String instructorId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(instructorId)
          .get();
      if (doc.exists) {
        return Instructor.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get instructor: $e');
    }
  }

  Future<Instructor?> getInstructorByUserId(String userId) async {
    try {
      // In this implementation, instructor ID is same as user ID
      return await getInstructor(userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> createInstructor(Instructor instructor) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(instructor.id)
          .set(instructor.toJson());
    } catch (e) {
      throw Exception('Failed to create instructor: $e');
    }
  }

  Future<void> updateInstructor(Instructor instructor) async {
    try {
      await _firestore.collection(_collection).doc(instructor.id).update({
        ...instructor.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update instructor: $e');
    }
  }

  Future<Map<String, int>> getInstructorStatistics(String instructorId) async {
    try {
      // Calculate statistics from various collections
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Monthly classes
      final monthlyClassesQuery = await _firestore
          .collection('schedules')
          .where('instructorId', isEqualTo: instructorId)
          .where('startTime', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      // Total students (unique users from reservations)
      final reservationsQuery = await _firestore
          .collection('reservations')
          .where('instructorId', isEqualTo: instructorId)
          .get();

      final uniqueStudents = reservationsQuery.docs
          .map((doc) => doc.data()['userId'] as String)
          .toSet()
          .length;

      // Average rating
      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('instructorId', isEqualTo: instructorId)
          .get();

      double averageRating = 0;
      if (reviewsQuery.docs.isNotEmpty) {
        final totalRating = reviewsQuery.docs
            .map((doc) => doc.data()['instructorRating'] as int)
            .reduce((a, b) => a + b);
        averageRating = totalRating / reviewsQuery.docs.length;
      }

      // Occupancy rate
      int totalCapacity = 0;
      int totalEnrollment = 0;
      for (final doc in monthlyClassesQuery.docs) {
        totalCapacity += doc.data()['maxCapacity'] as int;
        totalEnrollment += doc.data()['currentEnrollment'] as int;
      }

      final occupancyRate = totalCapacity > 0
          ? ((totalEnrollment / totalCapacity) * 100).round()
          : 0;

      return {
        'monthlyClasses': monthlyClassesQuery.docs.length,
        'totalStudents': uniqueStudents,
        'averageRating': averageRating.round(),
        'occupancyRate': occupancyRate,
      };
    } catch (e) {
      throw Exception('Failed to get instructor statistics: $e');
    }
  }
}
