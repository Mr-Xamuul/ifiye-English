import 'package:flutter/material.dart';

import '../core/storage/local_storage_service.dart';
import '../models/content/course_progress.dart';
import '../models/content/final_exam_models.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._storage);

  // Keeps every available lesson and assessment open for curriculum testing.
  // Set this to false before publishing the production progression rules.
  static const unlockAllDuringDevelopment = true;
  static const unlockA1DuringDevelopment = unlockAllDuringDevelopment;

  final LocalStorageService _storage;
  bool initialized = false, splashFinished = false, onboardingComplete = false;
  int navIndex = 0, dailyGoal = 10;
  List<SavedItem> savedItems = [];
  List<int> examScores = [];
  CourseProgress courseProgress = const CourseProgress();
  FinalExamProgress finalExamProgress = const FinalExamProgress();
  FinalExamProgress a2FinalExamProgress = const FinalExamProgress();

  Future<void> initialize() async {
    onboardingComplete = _storage.onboardingComplete;
    savedItems = _storage.savedItems.map(SavedItem.fromJson).toList();
    examScores = _storage.examScores;
    dailyGoal = _storage.dailyGoal;
    courseProgress = _storage.courseProgress;
    finalExamProgress = _storage.finalExamProgress;
    a2FinalExamProgress = _storage.finalExamProgressFor('A2');
    initialized = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    splashFinished = true;
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboardingComplete = true;
    await _storage.setOnboardingComplete();
    notifyListeners();
  }

  void setNavIndex(int value) {
    navIndex = value;
    notifyListeners();
  }

  bool isCourseLessonUnlocked(
    String? previousLessonId, {
    String levelId = 'A1',
  }) =>
      unlockAllDuringDevelopment ||
      previousLessonId == null ||
      courseProgress.completedLessonIds.contains(previousLessonId);

  Future<void> completeCourseLesson(String lessonId) async {
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: {...courseProgress.completedLessonIds, lessonId},
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: courseProgress.unitQuizScores,
      finalExamScores: courseProgress.finalExamScores,
    );
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  Future<void> recordUnitQuizScore(String unitId, int score) async {
    final previous = courseProgress.unitQuizScores[unitId] ?? 0;
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: courseProgress.completedLessonIds,
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: {
        ...courseProgress.unitQuizScores,
        unitId: score > previous ? score : previous,
      },
      finalExamScores: courseProgress.finalExamScores,
    );
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  bool hasPassedUnit(String unitId) => courseProgress.hasPassedUnitQuiz(unitId);

  static const finalReviewCompletionId = 'a1-final-review-completed';

  static String finalReviewCompletionIdFor(String levelId) =>
      '${levelId.toLowerCase()}-final-review-completed';

  bool get hasCompletedFinalReview =>
      courseProgress.completedLessonIds.contains(finalReviewCompletionId);

  bool hasCompletedFinalReviewFor(String levelId) => courseProgress
      .completedLessonIds
      .contains(finalReviewCompletionIdFor(levelId));

  Future<void> completeFinalReview(int readinessScore) async {
    await completeLevelFinalReview('A1', readinessScore);
  }

  Future<void> completeLevelFinalReview(
    String levelId,
    int readinessScore,
  ) async {
    final reviewId = '${levelId.toLowerCase()}-final-review';
    final completionId = finalReviewCompletionIdFor(levelId);
    final previous = courseProgress.unitQuizScores[reviewId] ?? 0;
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: {...courseProgress.completedLessonIds, completionId},
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: {
        ...courseProgress.unitQuizScores,
        reviewId: readinessScore > previous ? readinessScore : previous,
      },
      finalExamScores: courseProgress.finalExamScores,
    );
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  Future<void> saveFinalExamSession(
    int currentQuestion,
    Map<String, String> answers, [
    List<String> questionIds = const [],
  ]) async {
    await saveLevelFinalExamSession(
      'A1',
      currentQuestion,
      answers,
      questionIds,
    );
  }

  FinalExamProgress finalExamProgressFor(String levelId) =>
      levelId == 'A1' ? finalExamProgress : a2FinalExamProgress;

  Future<void> saveLevelFinalExamSession(
    String levelId,
    int currentQuestion,
    Map<String, String> answers,
    List<String> questionIds,
  ) async {
    final previous = finalExamProgressFor(levelId);
    final updated = FinalExamProgress(
      started: true,
      currentQuestion: currentQuestion,
      answers: answers,
      latestScore: previous.latestScore,
      bestScore: previous.bestScore,
      attempts: previous.attempts,
      passed: previous.passed,
      completionDate: previous.completionDate,
      sectionScores: previous.sectionScores,
      questionIds: questionIds,
    );
    _setFinalExamProgress(levelId, updated);
    await _storage.saveFinalExamProgressFor(levelId, updated);
    notifyListeners();
  }

  Future<void> finishFinalExam(int score, Map<String, int> sections) async {
    await finishLevelFinalExam('A1', 75, score, sections);
  }

  Future<void> finishLevelFinalExam(
    String levelId,
    int passingScore,
    int score,
    Map<String, int> sections,
  ) async {
    final previous = finalExamProgressFor(levelId);
    final passed = score >= passingScore;
    final updated = FinalExamProgress(
      completed: true,
      latestScore: score,
      bestScore: score > previous.bestScore ? score : previous.bestScore,
      attempts: previous.attempts + 1,
      passed: previous.passed || passed,
      completionDate: passed
          ? previous.completionDate ?? DateTime.now().toIso8601String()
          : previous.completionDate,
      sectionScores: sections,
    );
    _setFinalExamProgress(levelId, updated);
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: courseProgress.completedLessonIds,
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: courseProgress.unitQuizScores,
      finalExamScores: {
        ...courseProgress.finalExamScores,
        levelId: updated.bestScore,
      },
    );
    await _storage.saveFinalExamProgressFor(levelId, updated);
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  Future<void> retryFinalExam() async {
    await retryLevelFinalExam('A1');
  }

  Future<void> retryLevelFinalExam(String levelId) async {
    final previous = finalExamProgressFor(levelId);
    final updated = FinalExamProgress(
      bestScore: previous.bestScore,
      attempts: previous.attempts,
      passed: previous.passed,
      completionDate: previous.completionDate,
      sectionScores: previous.sectionScores,
    );
    _setFinalExamProgress(levelId, updated);
    await _storage.saveFinalExamProgressFor(levelId, updated);
    notifyListeners();
  }

  void _setFinalExamProgress(String levelId, FinalExamProgress value) {
    if (levelId == 'A1') {
      finalExamProgress = value;
    } else {
      a2FinalExamProgress = value;
    }
  }

  bool isSaved(String id) => savedItems.any((e) => e.id == id);
  Future<void> toggleSaved(SavedItem item) async {
    isSaved(item.id)
        ? savedItems.removeWhere((e) => e.id == item.id)
        : savedItems.insert(0, item);
    await _persistSaved();
    notifyListeners();
  }

  Future<void> removeSaved(String id) async {
    savedItems.removeWhere((e) => e.id == id);
    await _persistSaved();
    notifyListeners();
  }

  Future<void> _persistSaved() =>
      _storage.saveItems(savedItems.map((e) => e.toJson()).toList());
  Future<void> addExamScore(int score) async {
    examScores.add(score);
    await _storage.saveExamScores(examScores);
    notifyListeners();
  }

  int get bestScore =>
      examScores.isEmpty ? 0 : examScores.reduce((a, b) => a > b ? a : b);
  int get previousScore => examScores.isEmpty ? 0 : examScores.last;
  Future<void> updateDailyGoal(int value) async {
    dailyGoal = value;
    await _storage.setDailyGoal(value);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    savedItems.clear();
    examScores.clear();
    courseProgress = const CourseProgress();
    finalExamProgress = const FinalExamProgress();
    a2FinalExamProgress = const FinalExamProgress();
    dailyGoal = 10;
    await _storage.reset();
    notifyListeners();
  }
}
