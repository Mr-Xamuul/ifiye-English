import 'dart:math';

import '../../models/content/final_exam_models.dart';

class FinalExamEngine {
  const FinalExamEngine();

  List<FinalExamQuestion> selectAttempt(FinalExamContent exam, {int? seed}) {
    final count = exam.attemptQuestionCount ?? exam.questions.length;
    if (count == exam.questions.length || exam.attemptDistribution.isEmpty) {
      return List<FinalExamQuestion>.of(exam.questions);
    }
    final random = Random(seed);
    final selected = <FinalExamQuestion>[];
    for (final entry in exam.attemptDistribution.entries) {
      final pool =
          exam.questions
              .where((question) => question.sectionId == entry.key)
              .toList()
            ..shuffle(random);
      if (pool.length < entry.value) {
        throw StateError(
          '${entry.key} bank has ${pool.length}; ${entry.value} required.',
        );
      }
      selected.addAll(pool.take(entry.value));
    }
    if (selected.length != count) {
      throw StateError(
        'Attempt distribution selects ${selected.length}; $count required.',
      );
    }
    selected.shuffle(random);
    return selected;
  }

  List<FinalExamQuestion> restoreAttempt(
    FinalExamContent exam,
    List<String> ids,
  ) {
    final byId = {for (final question in exam.questions) question.id: question};
    final restored = ids.map((id) => byId[id]).whereType<FinalExamQuestion>();
    return restored.length == ids.length ? restored.toList() : const [];
  }

  int score(List<FinalExamQuestion> questions, Map<String, String> answers) {
    if (questions.isEmpty) return 0;
    final correct = questions
        .where((question) => answers[question.id] == question.correctAnswer)
        .length;
    return (correct / questions.length * 100).round();
  }

  Map<String, int> categoryScores(
    List<FinalExamQuestion> questions,
    Map<String, String> answers,
  ) {
    final result = <String, int>{};
    for (final section
        in questions.map((question) => question.sectionId).toSet()) {
      final items = questions
          .where((question) => question.sectionId == section)
          .toList();
      final correct = items
          .where((question) => answers[question.id] == question.correctAnswer)
          .length;
      result[section] = (correct / items.length * 100).round();
    }
    final translations = questions
        .where(
          (question) =>
              question.sectionId == 'somaliToEnglish' ||
              question.sectionId == 'englishToSomali',
        )
        .toList();
    if (translations.isNotEmpty) {
      final correct = translations
          .where((question) => answers[question.id] == question.correctAnswer)
          .length;
      result
        ..remove('somaliToEnglish')
        ..remove('englishToSomali')
        ..['translation'] = (correct / translations.length * 100).round();
    }
    return result;
  }

  List<String> strongest(Map<String, int> scores) =>
      _rank(scores, descending: true);

  List<String> weakest(Map<String, int> scores) =>
      _rank(scores, descending: false);

  List<String> recommendations(
    List<FinalExamQuestion> questions,
    Map<String, String> answers,
  ) {
    final missed = <String, int>{};
    for (final question in questions) {
      if (answers[question.id] != question.correctAnswer) {
        missed[question.recommendationUnit] =
            (missed[question.recommendationUnit] ?? 0) + 1;
      }
    }
    final ranked = missed.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(3).map((entry) => entry.key).toList();
  }

  List<String> _rank(Map<String, int> scores, {required bool descending}) {
    final entries = scores.entries.toList()
      ..sort(
        (a, b) => descending
            ? b.value.compareTo(a.value)
            : a.value.compareTo(b.value),
      );
    return entries.take(3).map((entry) => entry.key).toList();
  }
}
