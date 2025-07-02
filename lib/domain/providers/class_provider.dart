import 'package:flutter/foundation.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/class_schedule.dart';
import 'package:platia/data/models/instructor.dart';
import 'package:platia/data/models/studio.dart';
import 'package:platia/data/models/reservation.dart';
import 'package:platia/data/models/filter_options.dart';
import 'package:platia/data/repositories/class_repository.dart';
import 'package:platia/data/repositories/reservation_repository.dart';

class ClassProvider extends ChangeNotifier {
  final ClassRepository _classRepository = ClassRepository();
  final ReservationRepository _reservationRepository = ReservationRepository();

  List<Class> _classes = [];
  List<ClassSchedule> _schedules = [];
  List<Instructor> _instructors = [];
  List<Studio> _studios = [];
  List<Reservation> _userReservations = [];
  FilterOptions? _currentFilter;
  bool _isLoading = false;
  String? _error;

  List<Class> get classes => _classes;
  List<ClassSchedule> get schedules => _schedules;
  List<Instructor> get instructors => _instructors;
  List<Studio> get studios => _studios;
  List<Reservation> get userReservations => _userReservations;
  FilterOptions? get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ClassSchedule> get filteredSchedules {
    if (_currentFilter == null || _currentFilter!.isEmpty) {
      return _schedules;
    }

    return _schedules.where((schedule) {
      // Apply filters
      if (_currentFilter!.startDate != null &&
          schedule.startTime.isBefore(_currentFilter!.startDate!)) {
        return false;
      }

      if (_currentFilter!.endDate != null &&
          schedule.startTime.isAfter(_currentFilter!.endDate!)) {
        return false;
      }

      if (_currentFilter!.instructorIds?.isNotEmpty ?? false) {
        if (!_currentFilter!.instructorIds!.contains(schedule.instructorId)) {
          return false;
        }
      }

      if (_currentFilter!.studioIds?.isNotEmpty ?? false) {
        if (!_currentFilter!.studioIds!.contains(schedule.studioId)) {
          return false;
        }
      }

      if (_currentFilter!.classIds?.isNotEmpty ?? false) {
        if (!_currentFilter!.classIds!.contains(schedule.classId)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> loadClasses() async {
    _setLoading(true);
    _setError(null);

    try {
      _classes = await _classRepository.getClasses();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadSchedules({DateTime? date}) async {
    _setLoading(true);
    _setError(null);

    try {
      _schedules = await _classRepository.getSchedules(date: date);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadInstructors() async {
    _setLoading(true);
    _setError(null);

    try {
      _instructors = await _classRepository.getInstructors();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadStudios() async {
    _setLoading(true);
    _setError(null);

    try {
      _studios = await _classRepository.getStudios();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> loadUserReservations(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      _userReservations = await _reservationRepository.getUserReservations(
        userId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> makeReservation(String userId, String scheduleId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _reservationRepository.createReservation(
        userId: userId,
        scheduleId: scheduleId,
      );
      await loadUserReservations(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelReservation(String reservationId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _reservationRepository.cancelReservation(reservationId);
      // Reload reservations
      final reservation = _userReservations.firstWhere(
        (r) => r.id == reservationId,
      );
      await loadUserReservations(reservation.userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void applyFilter(FilterOptions filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _currentFilter = null;
    notifyListeners();
  }

  Class? getClassById(String id) {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Instructor? getInstructorById(String id) {
    try {
      return _instructors.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Studio? getStudioById(String id) {
    try {
      return _studios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
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
