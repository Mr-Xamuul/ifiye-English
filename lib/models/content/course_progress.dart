class CourseProgress {
  const CourseProgress({
    this.version = 1,
    this.completedLessonIds = const {},
    this.lessonQuizScores = const {},
    this.unitQuizScores = const {},
    this.finalExamScores = const {},
  });

  final int version;
  final Set<String> completedLessonIds;
  final Map<String, int> lessonQuizScores;
  final Map<String, int> unitQuizScores;
  final Map<String, int> finalExamScores;

  bool hasPassedLessonQuiz(String lessonId) =>
      (lessonQuizScores[lessonId] ?? 0) >= 70;
  bool hasPassedUnitQuiz(String unitId) => (unitQuizScores[unitId] ?? 0) >= 70;
  bool hasPassedFinalExam(String levelId) =>
      (finalExamScores[levelId] ?? 0) >= (levelId == 'A1' ? 75 : 70);

  Map<String, dynamic> toJson() => {
    'version': version,
    'completedLessonIds': completedLessonIds.toList(),
    'lessonQuizScores': lessonQuizScores,
    'unitQuizScores': unitQuizScores,
    'finalExamScores': finalExamScores,
  };

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
    version: json['version'] as int? ?? 1,
    completedLessonIds:
        (json['completedLessonIds'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toSet(),
    lessonQuizScores: _scoreMap(json['lessonQuizScores']),
    unitQuizScores: _scoreMap(json['unitQuizScores']),
    finalExamScores: _scoreMap(json['finalExamScores']),
  );
}

Map<String, int> _scoreMap(Object? value) =>
    (value as Map<String, dynamic>? ?? const {}).map(
      (key, score) => MapEntry(key, score as int),
    );
