import '../../models/content/content_models.dart';

class A2ReviewDiagnostics {
  const A2ReviewDiagnostics({
    required this.overallScore,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.categoryScores,
    required this.unitScores,
    required this.strongestAreas,
    required this.weakestAreas,
    required this.recommendedSectionIds,
  });

  final int overallScore;
  final int correctAnswers;
  final int incorrectAnswers;
  final Map<String, int> categoryScores;
  final Map<String, int> unitScores;
  final List<String> strongestAreas;
  final List<String> weakestAreas;
  final List<String> recommendedSectionIds;

  String get readinessLabel => overallScore >= 85
      ? 'Ready for A2 Final Exam'
      : overallScore >= 70
      ? 'Nearly ready; dib u eeg qaybaha lagu taliyay'
      : 'More review needed';

  static A2ReviewDiagnostics calculate(
    List<PracticeExercise> questions,
    Set<String> correctQuestionIds,
  ) {
    final categoryTotals = <String, int>{};
    final categoryCorrect = <String, int>{};
    final unitTotals = <String, int>{};
    final unitCorrect = <String, int>{};

    for (final question in questions) {
      final category = categoryFromId(question.id);
      final unit = unitFromId(question.id);
      categoryTotals[category] = (categoryTotals[category] ?? 0) + 1;
      unitTotals[unit] = (unitTotals[unit] ?? 0) + 1;
      if (correctQuestionIds.contains(question.id)) {
        categoryCorrect[category] = (categoryCorrect[category] ?? 0) + 1;
        unitCorrect[unit] = (unitCorrect[unit] ?? 0) + 1;
      }
    }

    int percentage(int correct, int total) =>
        total == 0 ? 0 : (correct / total * 100).round();
    final categories = {
      for (final entry in categoryTotals.entries)
        entry.key: percentage(categoryCorrect[entry.key] ?? 0, entry.value),
    };
    final units = {
      for (final entry in unitTotals.entries)
        entry.key: percentage(unitCorrect[entry.key] ?? 0, entry.value),
    };
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final weak = sorted.reversed.take(3).map((entry) => entry.key).toList();
    final recommendations = <String>{};
    for (final entry in units.entries) {
      if (entry.value < 70) recommendations.add(sectionForUnit(entry.key));
    }
    if ((categories['grammar'] ?? 100) < 70) {
      recommendations.add('a2-fr-s13');
    }
    if ((categories['vocabulary'] ?? 100) < 70) {
      recommendations.add('a2-fr-s14');
    }
    if ((categories['reading'] ?? 100) < 70) {
      recommendations.add('a2-fr-s15');
    }
    if ((categories['communication'] ?? 100) < 70) {
      recommendations.add('a2-fr-s16');
    }

    final correct = correctQuestionIds
        .intersection(questions.map((question) => question.id).toSet())
        .length;
    return A2ReviewDiagnostics(
      overallScore: percentage(correct, questions.length),
      correctAnswers: correct,
      incorrectAnswers: questions.length - correct,
      categoryScores: categories,
      unitScores: units,
      strongestAreas: sorted.take(3).map((entry) => entry.key).toList(),
      weakestAreas: weak,
      recommendedSectionIds: recommendations.toList()..sort(),
    );
  }

  static String categoryFromId(String id) {
    for (final category in const [
      'vocabulary',
      'grammar',
      'reading',
      'communication',
      'documents',
      'correction',
      'completion',
      'somaliToEnglish',
      'englishToSomali',
      'scenario',
    ]) {
      if (id.contains('-$category-')) return category;
    }
    return 'integrated';
  }

  static String unitFromId(String id) {
    final match = RegExp(r'-u(\d{2})-').firstMatch(id);
    return match == null ? 'A2 mixed' : 'A2 Unit ${int.parse(match.group(1)!)}';
  }

  static String sectionForUnit(String unit) {
    final match = RegExp(r'(\d+)$').firstMatch(unit);
    if (match == null) return 'a2-fr-s13';
    return 'a2-fr-s${int.parse(match.group(1)!).toString().padLeft(2, '0')}';
  }
}
