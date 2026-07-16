class FinalExamQuestion {
  const FinalExamQuestion({
    required this.id,
    required this.sectionId,
    required this.topic,
    required this.unitSource,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanationSomali,
    required this.scoreValue,
    required this.recommendationUnit,
  });

  final String id, sectionId, topic, unitSource, type, difficulty;
  final String question, correctAnswer, explanationSomali, recommendationUnit;
  final List<String> options;
  final int scoreValue;

  factory FinalExamQuestion.fromJson(Map<String, dynamic> json) =>
      FinalExamQuestion(
        id: json['id'] as String,
        sectionId: json['sectionId'] as String,
        topic: json['topic'] as String,
        unitSource: json['unitSource'] as String,
        type: json['type'] as String,
        difficulty: json['difficulty'] as String,
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctAnswer: json['correctAnswer'] as String,
        explanationSomali: json['explanationSomali'] as String,
        scoreValue: json['scoreValue'] as int,
        recommendationUnit: json['recommendationUnit'] as String,
      );
}

class FinalExamContent {
  const FinalExamContent({
    required this.titleEnglish,
    required this.titleSomali,
    required this.passingScore,
    required this.questions,
  });
  final String titleEnglish, titleSomali;
  final int passingScore;
  final List<FinalExamQuestion> questions;

  factory FinalExamContent.fromJson(Map<String, dynamic> json) =>
      FinalExamContent(
        titleEnglish: json['titleEnglish'] as String,
        titleSomali: json['titleSomali'] as String,
        passingScore: json['passingScore'] as int,
        questions: (json['questions'] as List<dynamic>)
            .map((e) => FinalExamQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FinalExamProgress {
  const FinalExamProgress({
    this.started = false,
    this.completed = false,
    this.currentQuestion = 0,
    this.answers = const {},
    this.latestScore = 0,
    this.bestScore = 0,
    this.attempts = 0,
    this.passed = false,
    this.completionDate,
    this.sectionScores = const {},
  });
  final bool started, completed, passed;
  final int currentQuestion, latestScore, bestScore, attempts;
  final Map<String, String> answers;
  final String? completionDate;
  final Map<String, int> sectionScores;

  Map<String, dynamic> toJson() => {
    'started': started,
    'completed': completed,
    'currentQuestion': currentQuestion,
    'answers': answers,
    'latestScore': latestScore,
    'bestScore': bestScore,
    'attempts': attempts,
    'passed': passed,
    'completionDate': completionDate,
    'sectionScores': sectionScores,
  };

  factory FinalExamProgress.fromJson(Map<String, dynamic> json) =>
      FinalExamProgress(
        started: json['started'] as bool? ?? false,
        completed: json['completed'] as bool? ?? false,
        currentQuestion: json['currentQuestion'] as int? ?? 0,
        answers: (json['answers'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, v as String),
        ),
        latestScore: json['latestScore'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        attempts: json['attempts'] as int? ?? 0,
        passed: json['passed'] as bool? ?? false,
        completionDate: json['completionDate'] as String?,
        sectionScores:
            (json['sectionScores'] as Map<String, dynamic>? ?? const {}).map(
              (k, v) => MapEntry(k, v as int),
            ),
      );
}
