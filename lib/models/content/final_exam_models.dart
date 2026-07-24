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
    this.resourceId,
  });

  final String id, sectionId, topic, unitSource, type, difficulty;
  final String question, correctAnswer, explanationSomali, recommendationUnit;
  final String? resourceId;
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
        resourceId: json['resourceId'] as String?,
      );
}

class FinalExamResource {
  const FinalExamResource({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
  });

  final String id, type, title, content;

  factory FinalExamResource.fromJson(Map<String, dynamic> json) =>
      FinalExamResource(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
      );
}

class FinalExamContent {
  const FinalExamContent({
    this.id = 'a1-final-exam',
    required this.titleEnglish,
    required this.titleSomali,
    this.descriptionSomali = '',
    required this.passingScore,
    this.estimatedMinutes = 80,
    this.attemptQuestionCount,
    this.attemptDistribution = const {},
    this.resources = const [],
    required this.questions,
  });
  final String id, titleEnglish, titleSomali, descriptionSomali;
  final int passingScore, estimatedMinutes;
  final int? attemptQuestionCount;
  final Map<String, int> attemptDistribution;
  final List<FinalExamResource> resources;
  final List<FinalExamQuestion> questions;

  factory FinalExamContent.fromJson(Map<String, dynamic> json) =>
      FinalExamContent(
        id: json['id'] as String? ?? 'a1-final-exam',
        titleEnglish: json['titleEnglish'] as String,
        titleSomali: json['titleSomali'] as String,
        descriptionSomali: json['descriptionSomali'] as String? ?? '',
        passingScore: json['passingScore'] as int,
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 80,
        attemptQuestionCount: json['attemptQuestionCount'] as int?,
        attemptDistribution:
            (json['attemptDistribution'] as Map<String, dynamic>? ?? const {})
                .map((key, value) => MapEntry(key, value as int)),
        resources: (json['resources'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  FinalExamResource.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
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
    this.questionIds = const [],
  });
  final bool started, completed, passed;
  final int currentQuestion, latestScore, bestScore, attempts;
  final Map<String, String> answers;
  final List<String> questionIds;
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
    'questionIds': questionIds,
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
        questionIds: (json['questionIds'] as List<dynamic>? ?? const [])
            .cast<String>(),
      );
}
