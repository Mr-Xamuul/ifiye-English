import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/core/utils/final_exam_engine.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';
import 'package:ifiye_english/models/content/final_exam_models.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const engine = FinalExamEngine();

  Future<FinalExamContent> loadExam() => CefrContentRepository(
    bundle: rootBundle,
  ).loadFinalExam('assets/content/a2/final_exam.json');

  test('A2 Final Exam bank and metadata meet the specification', () async {
    final exam = await loadExam();
    expect(exam.id, 'a2-final-exam');
    expect(exam.passingScore, 70);
    expect(exam.estimatedMinutes, inInclusiveRange(75, 100));
    expect(exam.attemptQuestionCount, 100);
    expect(exam.questions, hasLength(180));
    expect(
      exam.resources.where((item) => item.type == 'reading'),
      hasLength(4),
    );
    expect(
      exam.resources.where((item) => item.type == 'document'),
      hasLength(10),
    );
    expect(
      {
        for (final section
            in exam.questions.map((question) => question.sectionId).toSet())
          section: exam.questions
              .where((question) => question.sectionId == section)
              .length,
      },
      const {
        'vocabulary': 35,
        'grammar': 55,
        'reading': 25,
        'documents': 15,
        'communication': 25,
        'correction': 10,
        'somaliToEnglish': 8,
        'englishToSomali': 7,
      },
    );
  });

  test(
    'question IDs, prompts, options, answers and references are valid',
    () async {
      final exam = await loadExam();
      final resourceIds = exam.resources.map((item) => item.id).toSet();

      expect(
        exam.questions.map((question) => question.id).toSet(),
        hasLength(180),
      );
      expect(
        exam.questions.map((question) => question.question).toSet(),
        hasLength(180),
      );
      for (final question in exam.questions) {
        expect(question.options, hasLength(4), reason: question.id);
        expect(
          question.options.toSet(),
          hasLength(4),
          reason: '${question.id} duplicate option',
        );
        expect(
          question.options,
          contains(question.correctAnswer),
          reason: question.id,
        );
        expect(question.explanationSomali.trim(), isNotEmpty);
        expect(question.recommendationUnit, matches(RegExp(r'^Unit \d+$')));
        if (question.sectionId == 'reading' ||
            question.sectionId == 'documents') {
          expect(
            resourceIds,
            contains(question.resourceId),
            reason: question.id,
          );
        } else {
          expect(question.resourceId, isNull, reason: question.id);
        }
      }
    },
  );

  test('all new readings are 180 to 300 words', () async {
    final readings = (await loadExam()).resources.where(
      (item) => item.type == 'reading',
    );
    for (final reading in readings) {
      final words = reading.content
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
      expect(words, inInclusiveRange(180, 300), reason: reading.id);
    }
  });

  test(
    'every attempt has exactly 100 unique questions and exact distribution',
    () async {
      final exam = await loadExam();
      for (final seed in [1, 2, 99]) {
        final attempt = engine.selectAttempt(exam, seed: seed);
        expect(attempt, hasLength(100));
        expect(attempt.map((question) => question.id).toSet(), hasLength(100));
        for (final entry in exam.attemptDistribution.entries) {
          expect(
            attempt.where((question) => question.sectionId == entry.key),
            hasLength(entry.value),
            reason: '${entry.key}, seed $seed',
          );
        }
      }
      expect(
        engine
            .selectAttempt(exam, seed: 1)
            .map((question) => question.id)
            .toList(),
        isNot(
          engine
              .selectAttempt(exam, seed: 2)
              .map((question) => question.id)
              .toList(),
        ),
      );
    },
  );

  test('scoring handles 100, 70, 69 and unanswered answers', () async {
    final attempt = engine.selectAttempt(await loadExam(), seed: 7);
    Map<String, String> firstCorrect(int count) => {
      for (final question in attempt.take(count))
        question.id: question.correctAnswer,
    };

    expect(engine.score(attempt, firstCorrect(100)), 100);
    expect(engine.score(attempt, firstCorrect(70)), 70);
    expect(engine.score(attempt, firstCorrect(69)), 69);
    expect(engine.score(attempt, const {}), 0);

    final sectionScores = engine.categoryScores(attempt, firstCorrect(100));
    expect(sectionScores.values.every((score) => score == 100), isTrue);
  });

  test('attempt IDs restore the same resumable exam', () async {
    final exam = await loadExam();
    final attempt = engine.selectAttempt(exam, seed: 18);
    final ids = attempt.map((question) => question.id).toList();
    expect(
      engine.restoreAttempt(exam, ids).map((question) => question.id),
      ids,
    );
    expect(engine.restoreAttempt(exam, [...ids, 'missing']), isEmpty);
  });

  test(
    'A2 completion and B1 unlock obey the 69/70 boundary and persist',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.recordUnitQuizScore('a1-u10', 90);
      await state.recordUnitQuizScore('a2-u12', 88);
      await state.completeLevelFinalReview('A2', 72);

      expect(state.hasCompletedFinalReviewFor('A2'), isTrue);
      expect(state.courseProgress.hasPassedFinalExam('A2'), isFalse);
      await state.finishLevelFinalExam('A2', 70, 69, {'grammar': 69});
      expect(state.a2FinalExamProgress.latestScore, 69);
      expect(state.a2FinalExamProgress.bestScore, 69);
      expect(state.a2FinalExamProgress.attempts, 1);
      expect(state.a2FinalExamProgress.passed, isFalse);
      expect(state.courseProgress.hasPassedFinalExam('A2'), isFalse);

      await state.finishLevelFinalExam('A2', 70, 70, {'grammar': 70});
      expect(state.a2FinalExamProgress.latestScore, 70);
      expect(state.a2FinalExamProgress.bestScore, 70);
      expect(state.a2FinalExamProgress.attempts, 2);
      expect(state.a2FinalExamProgress.passed, isTrue);
      expect(state.courseProgress.hasPassedFinalExam('A2'), isTrue);
      expect(state.courseProgress.unitQuizScores['a2-u12'], 88);
      expect(state.courseProgress.unitQuizScores['a1-u10'], 90);
      expect(state.hasCompletedFinalReviewFor('A2'), isTrue);

      await state.finishLevelFinalExam('A2', 70, 40, {'grammar': 40});
      expect(state.a2FinalExamProgress.latestScore, 40);
      expect(state.a2FinalExamProgress.bestScore, 70);
      expect(state.a2FinalExamProgress.attempts, 3);
      expect(state.a2FinalExamProgress.passed, isTrue);
      expect(state.courseProgress.hasPassedFinalExam('A2'), isTrue);

      final restored = AppProvider(await LocalStorageService.create());
      await restored.initialize();
      expect(restored.a2FinalExamProgress.latestScore, 40);
      expect(restored.a2FinalExamProgress.bestScore, 70);
      expect(restored.a2FinalExamProgress.attempts, 3);
      expect(restored.a2FinalExamProgress.passed, isTrue);
      expect(restored.courseProgress.hasPassedFinalExam('A2'), isTrue);
      expect(restored.hasCompletedFinalReviewFor('A2'), isTrue);
    },
  );

  test('A1 pass threshold and progress remain backward compatible', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppProvider(await LocalStorageService.create());
    await state.finishFinalExam(74, {'grammar': 74});
    expect(state.courseProgress.hasPassedFinalExam('A1'), isFalse);
    await state.finishFinalExam(75, {'grammar': 75});
    expect(state.courseProgress.hasPassedFinalExam('A1'), isTrue);
    expect(state.finalExamProgress.bestScore, 75);
    expect(state.a2FinalExamProgress.attempts, 0);
  });
}
