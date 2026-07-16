import 'package:flutter/material.dart';

import '../core/storage/local_storage_service.dart';
import '../models/content/course_progress.dart';
import '../models/content/final_exam_models.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._storage);

  // A1 content remains open while the curriculum is under development.
  static const unlockA1DuringDevelopment = true;

  final LocalStorageService _storage;
  bool initialized = false, splashFinished = false, onboardingComplete = false;
  int navIndex = 0, dailyGoal = 10;
  List<SavedItem> savedItems = [];
  List<int> examScores = [];
  CourseProgress courseProgress = const CourseProgress();
  FinalExamProgress finalExamProgress = const FinalExamProgress();

  Future<void> initialize() async {
    onboardingComplete = _storage.onboardingComplete;
    savedItems = _storage.savedItems.map(SavedItem.fromJson).toList();
    examScores = _storage.examScores;
    dailyGoal = _storage.dailyGoal;
    courseProgress = _storage.courseProgress;
    finalExamProgress = _storage.finalExamProgress;
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

  bool isCourseLessonUnlocked(String? previousLessonId) =>
      unlockA1DuringDevelopment ||
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

  bool get hasCompletedFinalReview =>
      courseProgress.completedLessonIds.contains(finalReviewCompletionId);

  Future<void> completeFinalReview(int readinessScore) async {
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: {
        ...courseProgress.completedLessonIds,
        finalReviewCompletionId,
      },
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: {
        ...courseProgress.unitQuizScores,
        'a1-final-review': readinessScore,
      },
      finalExamScores: courseProgress.finalExamScores,
    );
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  Future<void> saveFinalExamSession(
    int currentQuestion,
    Map<String, String> answers,
  ) async {
    finalExamProgress = FinalExamProgress(
      started: true,
      currentQuestion: currentQuestion,
      answers: answers,
      latestScore: finalExamProgress.latestScore,
      bestScore: finalExamProgress.bestScore,
      attempts: finalExamProgress.attempts,
      passed: finalExamProgress.passed,
      completionDate: finalExamProgress.completionDate,
      sectionScores: finalExamProgress.sectionScores,
    );
    await _storage.saveFinalExamProgress(finalExamProgress);
    notifyListeners();
  }

  Future<void> finishFinalExam(int score, Map<String, int> sections) async {
    final passed = score >= 75;
    finalExamProgress = FinalExamProgress(
      completed: true,
      latestScore: score,
      bestScore: score > finalExamProgress.bestScore
          ? score
          : finalExamProgress.bestScore,
      attempts: finalExamProgress.attempts + 1,
      passed: finalExamProgress.passed || passed,
      completionDate: passed
          ? finalExamProgress.completionDate ?? DateTime.now().toIso8601String()
          : finalExamProgress.completionDate,
      sectionScores: sections,
    );
    courseProgress = CourseProgress(
      version: courseProgress.version,
      completedLessonIds: courseProgress.completedLessonIds,
      lessonQuizScores: courseProgress.lessonQuizScores,
      unitQuizScores: courseProgress.unitQuizScores,
      finalExamScores: {
        ...courseProgress.finalExamScores,
        'A1': finalExamProgress.bestScore,
      },
    );
    await _storage.saveFinalExamProgress(finalExamProgress);
    await _storage.saveCourseProgress(courseProgress);
    notifyListeners();
  }

  Future<void> retryFinalExam() async {
    finalExamProgress = FinalExamProgress(
      bestScore: finalExamProgress.bestScore,
      attempts: finalExamProgress.attempts,
      passed: finalExamProgress.passed,
      completionDate: finalExamProgress.completionDate,
      sectionScores: finalExamProgress.sectionScores,
    );
    await _storage.saveFinalExamProgress(finalExamProgress);
    notifyListeners();
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
    dailyGoal = 10;
    await _storage.reset();
    notifyListeners();
  }
}
