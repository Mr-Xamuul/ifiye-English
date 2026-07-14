enum SavedItemType { word, sentence, lesson }

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
