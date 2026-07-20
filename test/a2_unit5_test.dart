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

  test('A2 Unit 5 is complete, valid, and references Unit 4', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitFour = await repository.loadUnit(
      'assets/content/a2/unit_04.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_05.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u05');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, unitFour.id);
    expect(unit.lessons, hasLength(22));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(40));
    expect(unit.unitQuiz, hasLength(45));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(281));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(49));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(292),
    );
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test('all A2 IDs remain globally unique through Unit 5', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var number = 1; number <= 5; number++)
        repository.loadUnit(
          'assets/content/a2/unit_${number.toString().padLeft(2, '0')}.json',
        ),
    ]);
    final ids = <String>[];
    for (final unit in units) {
      ids.add(unit.id);
      for (final lesson in unit.lessons) {
        ids.add(lesson.id);
        ids.addAll(lesson.practiceExercises.map((item) => item.id));
        ids.addAll(lesson.quizQuestions.map((item) => item.id));
        ids.addAll(
          lesson.grammar?.practiceQuestions.map((item) => item.id) ?? const [],
        );
      }
      ids.addAll(unit.unitQuiz.map((item) => item.id));
    }
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('weather forms and core grammar examples are accurate', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_05.json');
    final vocabulary = unit.lessons[0];
    final willLesson = unit.lessons[7];
    final possibility = unit.lessons[9];
    final comparatives = unit.lessons[10];
    final superlatives = unit.lessons[11];

    expect(
      vocabulary.vocabulary.map((item) => item.englishWord),
      containsAll(['Rain', 'Rainy', 'Wind', 'Windy', 'Storm', 'Stormy']),
    );
    expect(
      vocabulary.examples.map((item) => item.english),
      containsAll([
        'Heavy rain continued for an hour and flooded the empty field.',
        'We moved the picnic indoors because it was a rainy day.',
      ]),
    );
    expect(willLesson.grammar!.sentenceStructure, contains('will/won’t'));
    expect(possibility.grammar!.sentenceStructure, contains('may/might'));
    expect(comparatives.grammar!.sentenceStructure, contains('comparative'));
    expect(superlatives.grammar!.sentenceStructure, contains('superlative'));
    expect(
      willLesson.examples.map((item) => item.english),
      contains('The forecast says it will rain tomorrow afternoon.'),
    );
  });

  test('forecast data and answers are internally consistent', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_05.json');
    final forecast = unit.lessons[6];
    final text = forecast.examples.map((item) => item.english).join('\n');

    expect(text, contains('Monday: mostly sunny; high 29°C; low 20°C'));
    expect(text, contains('Tuesday: heavy rain; high 25°C; low 19°C'));
    expect(text, contains('Wednesday: partly cloudy; high 31°C'));
    expect(forecast.practiceExercises, hasLength(12));
    expect(forecast.practiceExercises[0].correctAnswer, 'Wednesday');
    expect(forecast.practiceExercises[1].correctAnswer, 'Tuesday');
    expect(forecast.practiceExercises[2].correctAnswer, '19°C');
    expect(forecast.practiceExercises[3].correctAnswer, 'Tuesday');
  });

  test(
    'reading and complete conversations meet their content targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_05.json');
      final reading = unit.lessons[18];
      final passage = reading.examples.last.english;
      final wordCount = passage.split(RegExp(r'\s+')).length;
      final conversations = unit.lessons[19];

      expect(wordCount, inInclusiveRange(170, 240));
      expect(reading.practiceExercises.take(10), hasLength(10));
      expect(conversations.dialogues, hasLength(7));
      expect(
        conversations.dialogues.every(
          (dialogue) =>
              dialogue.lines.length >= 10 && dialogue.lines.length <= 16,
        ),
        isTrue,
      );
      expect(conversations.speakingPractice, contains('role-play'));
    },
  );

  test(
    'Unit 5 quiz has 45 valid answers and the requested distribution',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_05.json');

      expect(unit.unitQuiz.sublist(0, 7), hasLength(7));
      expect(unit.unitQuiz.sublist(7, 11), hasLength(4));
      expect(unit.unitQuiz.sublist(11, 16), hasLength(5));
      expect(unit.unitQuiz.sublist(16, 22), hasLength(6));
      expect(unit.unitQuiz.sublist(22, 26), hasLength(4));
      expect(unit.unitQuiz.sublist(26, 30), hasLength(4));
      expect(unit.unitQuiz.sublist(30, 35), hasLength(5));
      expect(unit.unitQuiz.sublist(35, 39), hasLength(4));
      expect(unit.unitQuiz.sublist(39, 42), hasLength(3));
      expect(unit.unitQuiz.sublist(42, 44), hasLength(2));
      expect(unit.unitQuiz.sublist(44, 45), hasLength(1));
      expect(
        unit.unitQuiz.every(
          (item) => item.options.contains(item.correctAnswer),
        ),
        isTrue,
      );
    },
  );

  test(
    'Unit 5 progress and saved vocabulary persist without losing earlier work',
    () async {
      final repository = CefrContentRepository(bundle: rootBundle);
      final level = await repository.loadLevel('assets/content/a2/level.json');
      final available = await repository.loadAvailableUnits(level);
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
      expect(level.unitFiles[5], 'assets/content/a2/unit_06.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u04-l20'},
        unitQuizScores: const {
          'a1-u10': 80,
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u05-l01-rain',
        type: SavedItemType.word,
        englishText: 'Rain',
        somaliText: 'roob',
        lessonId: 'a2-u05-l01',
        createdAt: DateTime(2026, 7, 18),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u05', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u04'), isTrue);
      expect(state.hasPassedUnit('a2-u05'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u05-l01');
      expect(storage.courseProgress.unitQuizScores['a2-u05'], 70);
    },
  );
}
