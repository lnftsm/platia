import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/studio.dart';

class ClassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Class>> getClasses() async {
    try {
      final snapshot = await _firestore
          .collection('classes')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return Class.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get classes: $e');
    }
  }

  Future<List<ClassSchedule>> getSchedules({DateTime? date}) async {
    try {
      Query query = _firestore.collection('schedules');

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        query = query
            .where('startTime', isGreaterThanOrEqualTo: startOfDay)
            .where('startTime', isLessThanOrEqualTo: endOfDay);
      }

      final snapshot = await query.orderBy('startTime').get();

      return snapshot.docs.map((doc) {
        return ClassSchedule.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get schedules: $e');
    }
  }

  // Add this method for getting instructor's schedules
  Future<List<ClassSchedule>> getInstructorSchedules(
    String instructorId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('instructorId', isEqualTo: instructorId)
          .where(
            'startTime',
            isGreaterThanOrEqualTo: DateTime.now().subtract(
              const Duration(days: 30),
            ),
          )
          .orderBy('startTime', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return ClassSchedule.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get instructor schedules: $e');
    }
  }

  Future<List<Instructor>> getInstructors() async {
    try {
      final snapshot = await _firestore
          .collection('instructors')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return Instructor.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get instructors: $e');
    }
  }

  Future<List<Studio>> getStudios() async {
    try {
      final snapshot = await _firestore
          .collection('studios')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return Studio.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get studios: $e');
    }
  }
}
