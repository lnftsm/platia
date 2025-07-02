import 'package:flutter/foundation.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/repositories/instructor_repository.dart';
import 'package:platia/data/repositories/class_repository.dart';

class InstructorProvider extends ChangeNotifier {
  final InstructorRepository _instructorRepository = InstructorRepository();
  final ClassRepository _classRepository = ClassRepository();

  Instructor? _currentInstructor;
  List<ClassSchedule> _instructorSchedules = [];
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String? _error;

  Instructor? get currentInstructor => _currentInstructor;
  List<ClassSchedule> get instructorSchedules => _instructorSchedules;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInstructorByUserId(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentInstructor = await _instructorRepository.getInstructorByUserId(
        userId,
      );
      if (_currentInstructor != null) {
        await loadInstructorSchedules(_currentInstructor!.id);
        await loadInstructorStatistics(_currentInstructor!.id);
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<Instructor?> getInstructorByUserId(String userId) async {
    try {
      return await _instructorRepository.getInstructorByUserId(userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadInstructorSchedules(String instructorId) async {
    try {
      _instructorSchedules = await _classRepository.getInstructorSchedules(
        instructorId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadInstructorStatistics(String instructorId) async {
    try {
      _statistics = await _instructorRepository.getInstructorStatistics(
        instructorId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> updateInstructorProfile(Instructor instructor) async {
    _setLoading(true);
    _setError(null);

    try {
      await _instructorRepository.updateInstructor(instructor);
      _currentInstructor = instructor;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createOrUpdateInstructor(Instructor instructor) async {
    _setLoading(true);
    _setError(null);

    try {
      final existing = await _instructorRepository.getInstructor(instructor.id);
      if (existing != null) {
        await _instructorRepository.updateInstructor(instructor);
      } else {
        await _instructorRepository.createInstructor(instructor);
      }
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
