import 'package:flutter/material.dart';

import '../core/storage/local_storage_service.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._storage);
  final LocalStorageService _storage;
  bool initialized = false, splashFinished = false, onboardingComplete = false;
  int navIndex = 0, dailyGoal = 10;
  Set<String> completedLessons = {};
  List<SavedItem> savedItems = [];
  List<int> examScores = [];

  Future<void> initialize() async {
    onboardingComplete = _storage.onboardingComplete;
    completedLessons = _storage.completedLessons;
    savedItems = _storage.savedItems.map(SavedItem.fromJson).toList();
    examScores = _storage.examScores;
    dailyGoal = _storage.dailyGoal;
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

  bool lessonUnlocked(int index) =>
      index == 0 || completedLessons.contains('a1-$index');
  Future<void> completeLesson(String id) async {
    completedLessons.add(id);
    await _storage.saveCompletedLessons(completedLessons);
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
  double get progress => completedLessons.length / 10;
  Future<void> updateDailyGoal(int value) async {
    dailyGoal = value;
    await _storage.setDailyGoal(value);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    completedLessons.clear();
    savedItems.clear();
    examScores.clear();
    dailyGoal = 10;
    await _storage.reset();
    notifyListeners();
  }
}
