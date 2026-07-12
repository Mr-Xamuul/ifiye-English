enum SavedItemType { word, sentence, lesson }

class LessonItem {
  const LessonItem({
    required this.id,
    required this.englishText,
    required this.somaliText,
    required this.exampleEnglish,
    required this.exampleSomali,
    required this.pronunciation,
    this.type = 'vocabulary',
  });
  final String id,
      englishText,
      somaliText,
      exampleEnglish,
      exampleSomali,
      pronunciation,
      type;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.levelId,
    required this.titleEnglish,
    required this.titleSomali,
    required this.description,
    required this.duration,
    required this.lessonItems,
  });
  final String id, levelId, titleEnglish, titleSomali, description;
  final int duration;
  final List<LessonItem> lessonItems;
}

class CefrLevel {
  const CefrLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonCount,
    required this.isLocked,
  });
  final String id, title, description;
  final int lessonCount;
  final bool isLocked;
}

class SavedItem {
  SavedItem({
    required this.id,
    required this.type,
    required this.englishText,
    required this.somaliText,
    this.lessonId,
    required this.createdAt,
  });
  final String id, englishText, somaliText;
  final SavedItemType type;
  final String? lessonId;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'englishText': englishText,
    'somaliText': somaliText,
    'lessonId': lessonId,
    'createdAt': createdAt.toIso8601String(),
  };
  factory SavedItem.fromJson(Map<String, dynamic> j) => SavedItem(
    id: j['id'],
    type: SavedItemType.values.byName(j['type']),
    englishText: j['englishText'],
    somaliText: j['somaliText'],
    lessonId: j['lessonId'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanationSomali,
    required this.type,
  });
  final String id, question, correctAnswer, explanationSomali, type;
  final List<String> options;
}
