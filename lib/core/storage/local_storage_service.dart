import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/content/course_progress.dart';

class LocalStorageService {
  LocalStorageService._(this._prefs);
  final SharedPreferences _prefs;
  static Future<LocalStorageService> create() async =>
      LocalStorageService._(await SharedPreferences.getInstance());

  bool get onboardingComplete => _prefs.getBool('onboardingComplete') ?? false;
  Future<void> setOnboardingComplete() =>
      _prefs.setBool('onboardingComplete', true);
  List<Map<String, dynamic>> get savedItems =>
      (jsonDecode(_prefs.getString('savedItems') ?? '[]') as List)
          .cast<Map<String, dynamic>>();
  Future<void> saveItems(List<Map<String, dynamic>> values) =>
      _prefs.setString('savedItems', jsonEncode(values));
  List<int> get examScores =>
      _prefs.getStringList('examScores')?.map(int.parse).toList() ?? [];
  Future<void> saveExamScores(List<int> values) =>
      _prefs.setStringList('examScores', values.map((e) => '$e').toList());
  int get dailyGoal => _prefs.getInt('dailyGoal') ?? 10;
  Future<void> setDailyGoal(int value) => _prefs.setInt('dailyGoal', value);
  CourseProgress get courseProgress {
    final source = _prefs.getString('courseProgress');
    if (source == null) return const CourseProgress();
    try {
      return CourseProgress.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
    } on FormatException {
      return const CourseProgress();
    } on TypeError {
      return const CourseProgress();
    }
  }

  Future<void> saveCourseProgress(CourseProgress progress) =>
      _prefs.setString('courseProgress', jsonEncode(progress.toJson()));
  Future<void> reset() async {
    for (final key in [
      'completedLessons',
      'savedItems',
      'examScores',
      'dailyGoal',
      'courseProgress',
    ]) {
      await _prefs.remove(key);
    }
  }
}
