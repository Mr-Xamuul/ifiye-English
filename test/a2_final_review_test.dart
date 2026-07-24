import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/core/utils/a2_review_diagnostics.dart';
import 'package:ifiye_english/core/validation/content_validator.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';
import 'package:ifiye_english/models/content/content_models.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<CourseUnit> loadReview() => CefrContentRepository(
    bundle: rootBundle,
  ).loadUnit('assets/content/a2/final_review.json');

  test('A2 Final Review schema, sections and prerequisite are valid', () async {
    final review = await loadReview();

    expect(const ContentValidator().validateUnit(review).errors, isEmpty);
    expect(review.id, 'a2-final-review');
    expect(review.levelId, 'A2');
    expect(review.requiredPreviousUnitId, 'a2-u12');
    expect(review.lessons.length, 16);
    expect(review.lessons[12].practiceExercises.length, 80);
    expect(review.lessons[13].vocabulary.length, 240);
    expect(review.lessons[13].practiceExercises.length, 60);
    expect(review.lessons[14].dialogues.length, 8);
    expect(review.lessons[14].practiceExercises.length, 80);
    expect(review.lessons[15].dialogues.length, 15);
    expect(review.lessons[15].practiceExercises.length, 15);
    expect(review.unitQuiz.length, 75);
  });

  test('review IDs remain unique across all A2 content', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = <CourseUnit>[
      for (var number = 1; number <= 12; number++)
        await repository.loadUnit(
          'assets/content/a2/unit_${number.toString().padLeft(2, '0')}.json',
        ),
      await loadReview(),
    ];
    final ids = <String>{};
    for (final unit in units) {
      expect(ids.add(unit.id), isTrue, reason: unit.id);
      for (final lesson in unit.lessons) {
        expect(ids.add(lesson.id), isTrue, reason: lesson.id);
        for (final exercise in [
          ...lesson.practiceExercises,
          ...lesson.quizQuestions,
          ...?lesson.grammar?.practiceQuestions,
        ]) {
          expect(ids.add(exercise.id), isTrue, reason: exercise.id);
        }
      }
      for (final question in unit.unitQuiz) {
        expect(ids.add(question.id), isTrue, reason: question.id);
      }
    }
  });

  test('vocabulary is unique, complete and TTS-ready', () async {
    final vocabulary = (await loadReview()).lessons[13].vocabulary;
    final words = vocabulary
        .map((item) => item.englishWord.toLowerCase())
        .toSet();

    expect(words.length, 240);
    for (final item in vocabulary) {
      expect(item.somaliMeaning.trim(), isNotEmpty);
      expect(item.pronunciation.trim(), isNotEmpty);
      expect(item.exampleEnglish.trim(), isNotEmpty);
      expect(item.exampleSomali.trim(), isNotEmpty);
    }
  });

  test('new reading passages have required length', () async {
    final readings = (await loadReview()).lessons[14].dialogues;
    for (final reading in readings) {
      final words = reading.lines
          .expand((line) => line.english.split(RegExp(r'\s+')))
          .where((word) => word.isNotEmpty)
          .length;
      expect(words, inInclusiveRange(180, 320), reason: reading.titleSomali);
    }
  });

  test(
    'readiness assessment has exact distribution and valid answers',
    () async {
      final questions = (await loadReview()).unitQuiz;
      const expected = <String, int>{
        'vocabulary': 10,
        'grammar': 20,
        'reading': 8,
        'communication': 7,
        'documents': 5,
        'correction': 5,
        'completion': 5,
        'somaliToEnglish': 5,
        'englishToSomali': 5,
        'scenario': 5,
      };
      final actual = <String, int>{};
      for (final question in questions) {
        final category = A2ReviewDiagnostics.categoryFromId(question.id);
        actual[category] = (actual[category] ?? 0) + 1;
        expect(question.options, contains(question.correctAnswer));
        expect(question.explanationSomali.trim(), isNotEmpty);
      }
      expect(actual, expected);
    },
  );

  test(
    'diagnostics report scores and adaptive section recommendations',
    () async {
      final questions = (await loadReview()).unitQuiz;
      final correctIds = questions
          .where((question) => !question.id.contains('-grammar-'))
          .map((question) => question.id)
          .toSet();
      final result = A2ReviewDiagnostics.calculate(questions, correctIds);

      expect(result.correctAnswers, 55);
      expect(result.incorrectAnswers, 20);
      expect(result.overallScore, 73);
      expect(result.categoryScores['grammar'], 0);
      expect(result.recommendedSectionIds, contains('a2-fr-s13'));
      expect(result.weakestAreas, contains('grammar'));
    },
  );

  test('A2 review completion persists without losing A1 progress', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);
    await state.recordUnitQuizScore('a1-u10', 88);
    await state.recordUnitQuizScore('a2-u12', 70);

    expect(state.hasPassedUnit('a2-u12'), isTrue);
    expect(state.hasCompletedFinalReviewFor('A2'), isFalse);
    await state.completeLevelFinalReview('A2', 76);
    expect(state.hasCompletedFinalReviewFor('A2'), isTrue);
    expect(state.courseProgress.unitQuizScores['a2-final-review'], 76);
    expect(state.courseProgress.unitQuizScores['a1-u10'], 88);

    await state.completeLevelFinalReview('A2', 60);
    expect(state.courseProgress.unitQuizScores['a2-final-review'], 76);
    final restored = AppProvider(await LocalStorageService.create());
    await restored.initialize();
    expect(restored.hasCompletedFinalReviewFor('A2'), isTrue);
    expect(restored.courseProgress.unitQuizScores['a1-u10'], 88);
  });
}
