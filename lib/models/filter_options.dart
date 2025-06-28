import 'package:platia/models/class_schedule.dart';
import 'package:platia/models/pilates_class.dart';

class FilterOptions {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? instructorIds;
  final List<String>? studioIds;
  final List<String>? classIds;
  final List<ClassDifficulty>? difficulties;
  final List<ClassScheduleStatus>? statuses;
  final String? searchQuery;

  FilterOptions({
    this.startDate,
    this.endDate,
    this.instructorIds,
    this.studioIds,
    this.classIds,
    this.difficulties,
    this.statuses,
    this.searchQuery,
  });

  FilterOptions copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? instructorIds,
    List<String>? studioIds,
    List<String>? classIds,
    List<ClassDifficulty>? difficulties,
    List<ClassScheduleStatus>? statuses,
    String? searchQuery,
  }) {
    return FilterOptions(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructorIds: instructorIds ?? this.instructorIds,
      studioIds: studioIds ?? this.studioIds,
      classIds: classIds ?? this.classIds,
      difficulties: difficulties ?? this.difficulties,
      statuses: statuses ?? this.statuses,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructorIds': instructorIds,
      'studioIds': studioIds,
      'classIds': classIds,
      'difficulties': difficulties
          ?.map((d) => d.toString().split('.').last)
          .toList(),
      'statuses': statuses?.map((s) => s.toString().split('.').last).toList(),
      'searchQuery': searchQuery,
    };
  }

  bool get isEmpty {
    return startDate == null &&
        endDate == null &&
        (instructorIds?.isEmpty ?? true) &&
        (studioIds?.isEmpty ?? true) &&
        (classIds?.isEmpty ?? true) &&
        (difficulties?.isEmpty ?? true) &&
        (statuses?.isEmpty ?? true) &&
        (searchQuery?.isEmpty ?? true);
  }
}
