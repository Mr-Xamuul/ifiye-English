import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/core/validation/content_validator.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';
import 'package:ifiye_english/models/content/course_progress.dart';
import 'package:ifiye_english/models/models.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A2 Unit 1 is complete, valid, and uses unique A2 IDs', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unit = await repository.loadUnit('assets/content/a2/unit_01.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u01');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, isNull);
    expect(unit.lessons, hasLength(14));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(30));
    expect(unit.unitQuiz, hasLength(35));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(126));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(28));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(160),
    );

    final ids = <String>[
      unit.id,
      for (final lesson in unit.lessons) ...[
        lesson.id,
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
        ...?lesson.grammar?.practiceQuestions.map((item) => item.id),
      ],
      ...unit.unitQuiz.map((item) => item.id),
    ];
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids.every((id) => id.startsWith('a2-')), isTrue);
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test(
    'A2 regular, irregular, reading, and quiz content is accurate',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_01.json');
      final regularWords = unit.lessons[1].vocabulary
          .map((item) => item.englishWord)
          .toSet();
      final irregularWords = unit.lessons[2].vocabulary
          .map((item) => item.englishWord)
          .toSet();

      expect(regularWords, containsAll(['work → worked', 'study → studied']));
      expect(
        irregularWords,
        containsAll([
          'go → went',
          'eat → ate',
          'buy → bought',
          'write → wrote',
          'read → read',
          'leave → left',
        ]),
      );
      expect(regularWords, hasLength(10));
      expect(irregularWords, hasLength(20));
      expect(
        unit.lessons[11].practiceExercises.where(
          (item) => item.type.name == 'readingComprehension',
        ),
        hasLength(7),
      );
      expect(
        unit.unitQuiz.every(
          (item) =>
              item.options.isEmpty || item.options.contains(item.correctAnswer),
        ),
        isTrue,
      );
      expect(
        unit.unitQuiz.where(
          (item) => item.options.contains('She didn’t went.'),
        ),
        isNotEmpty,
      );
    },
  );

  test(
    'only available A2 content loads while all 12 units stay planned',
    () async {
      final repository = CefrContentRepository(bundle: rootBundle);
      final level = await repository.loadLevel('assets/content/a2/level.json');
      final available = await repository.loadAvailableUnits(level);

      expect(level.requiredPreviousLevelId, 'A1');
      expect(level.unitFiles, hasLength(12));
      expect(available.map((unit) => unit.id), [
        'a2-u01',
        'a2-u02',
        'a2-u03',
        'a2-u04',
        'a2-u05',
        'a2-u06',
        'a2-u07',
        'a2-u08',
        'a2-u09',
      ]);
    },
  );

  test('A2 progress preserves A1 scores and saved vocabulary', () async {
    final initialProgress = CourseProgress(
      completedLessonIds: const {'a1-u10-l17'},
      unitQuizScores: const {'a1-u10': 82},
      finalExamScores: const {'A1': 80},
    );
    final saved = SavedItem(
      id: 'a2-u01-l01-yesterday',
      type: SavedItemType.word,
      englishText: 'yesterday',
      somaliText: 'shalay',
      lessonId: 'a2-u01-l01',
      createdAt: DateTime(2026),
    );
    SharedPreferences.setMockInitialValues({
      'courseProgress': jsonEncode(initialProgress.toJson()),
      'savedItems': jsonEncode([saved.toJson()]),
    });
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);
    await state.initialize();

    expect(state.courseProgress.hasPassedFinalExam('A1'), isTrue);
    expect(state.savedItems.single.englishText, 'yesterday');
    await state.recordUnitQuizScore('a2-u01', 70);

    expect(state.hasPassedUnit('a2-u01'), isTrue);
    expect(state.courseProgress.finalExamScores['A1'], 80);
    expect(state.courseProgress.unitQuizScores['a1-u10'], 82);
    expect(state.savedItems.single.lessonId, 'a2-u01-l01');
    expect(storage.courseProgress.unitQuizScores['a2-u01'], 70);
  });
}
