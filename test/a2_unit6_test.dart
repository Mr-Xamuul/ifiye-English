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

  test('A2 Unit 6 is complete, valid, and references Unit 5', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitFive = await repository.loadUnit(
      'assets/content/a2/unit_05.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_06.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u06');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, unitFive.id);
    expect(unit.lessons, hasLength(27));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(45));
    expect(unit.unitQuiz, hasLength(50));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(393));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(60));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(357),
    );
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test('all A2 IDs remain globally unique through Unit 6', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var number = 1; number <= 6; number++)
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

  test('workplace vocabulary examples are complete and contextual', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_06.json');
    final vocabulary = unit.lessons.expand((lesson) => lesson.vocabulary);
    final examples = vocabulary.map((item) => item.exampleEnglish).toList();

    expect(
      examples,
      containsAll([
        'The receptionist answered the phone and arranged an appointment for the customer.',
        'My evening shift starts at four and finishes at ten o’clock.',
        'The application message explains the job, skills, and experience clearly.',
      ]),
    );
    expect(
      vocabulary.every(
        (item) =>
            item.exampleEnglish.trim().isNotEmpty &&
            item.exampleSomali.trim().isNotEmpty &&
            item.partOfSpeech.contains('neutral') &&
            item.explanationSomali.contains('Common collocation'),
      ),
      isTrue,
    );
    expect(
      examples.any(
        (example) => RegExp(
          r'^(He is a driver|She is a teacher|I am a worker)\.?$',
          caseSensitive: false,
        ).hasMatch(example),
      ),
      isFalse,
    );
  });

  test('workplace grammar forms and distinctions are explicit', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_06.json');
    final workplaces = unit.lessons[2].grammar!;
    final presentSimple = unit.lessons[6].grammar!;
    final presentContinuous = unit.lessons[7].grammar!;
    final must = unit.lessons[9].grammar!;
    final haveTo = unit.lessons[10].grammar!;
    final relative = unit.lessons[14].grammar!;
    final past = unit.lessons[16].grammar!;

    expect(workplaces.sentenceStructure, contains('work at'));
    expect(workplaces.sentenceStructure, contains('work as'));
    expect(presentSimple.sentenceStructure, contains('s/es/ies'));
    expect(presentContinuous.sentenceStructure, contains('am/is/are'));
    expect(must.sentenceStructure, contains('must/mustn’t + base'));
    expect(haveTo.rule, contains('Mustn’t'));
    expect(haveTo.rule, contains('don’t have to'));
    expect(relative.rule, contains('Who'));
    expect(relative.rule, contains('that'));
    expect(past.rule, contains('Past Simple'));
    expect(
      unit.lessons.every(
        (lesson) => lesson.grammar!.positiveExamples.length >= 8,
      ),
      isTrue,
    );
  });

  test('schedule entries and working-hour answers are correct', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_06.json');
    final schedule = unit.lessons[5];
    final text = schedule.examples.map((item) => item.english).join('\n');

    expect(text, contains('Amina — Monday — 08:00–16:00'));
    expect(text, contains('7.5 working hours'));
    expect(text, contains('Yusuf — Tuesday — 07:00–15:00'));
    expect(text, contains('7 working hours'));
    expect(text, contains('Hodan — Wednesday — 14:00–20:00'));
    expect(text, contains('5.5 working hours'));
    expect(text, contains('Maryan — Friday — 09:00–13:00'));
    expect(schedule.practiceExercises[0].correctAnswer, '7.5 hours');
    expect(schedule.practiceExercises[1].correctAnswer, '7 hours');
    expect(schedule.practiceExercises[3].correctAnswer, '5.5 hours');
  });

  test('notices, job ads, reading, and full dialogues meet targets', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_06.json');
    final notices = unit.lessons[13];
    final advertisements = unit.lessons[17];
    final reading = unit.lessons[23];
    final passage = reading.examples.last.english;
    final conversations = unit.lessons[24];

    expect(notices.examples, hasLength(greaterThanOrEqualTo(10)));
    expect(
      advertisements.examples.where(
        (item) => RegExp(
          r'^(SHOP ASSISTANT|RECEPTIONIST|DELIVERY DRIVER|OFFICE ASSISTANT|HOTEL WORKER)',
        ).hasMatch(item.english),
      ),
      hasLength(5),
    );
    expect(passage.split(RegExp(r'\s+')).length, inInclusiveRange(180, 250));
    expect(reading.practiceExercises.take(10), hasLength(10));
    expect(conversations.dialogues, hasLength(8));
    expect(
      conversations.dialogues.every(
        (dialogue) =>
            dialogue.lines.length >= 10 && dialogue.lines.length <= 16,
      ),
      isTrue,
    );
    expect(conversations.speakingPractice, contains('role-play'));
  });

  test('Unit 6 quiz has 50 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_06.json');

    expect(unit.unitQuiz.sublist(0, 8), hasLength(8));
    expect(unit.unitQuiz.sublist(8, 13), hasLength(5));
    expect(unit.unitQuiz.sublist(13, 18), hasLength(5));
    expect(unit.unitQuiz.sublist(18, 23), hasLength(5));
    expect(unit.unitQuiz.sublist(23, 29), hasLength(6));
    expect(unit.unitQuiz.sublist(29, 34), hasLength(5));
    expect(unit.unitQuiz.sublist(34, 37), hasLength(3));
    expect(unit.unitQuiz.sublist(37, 40), hasLength(3));
    expect(unit.unitQuiz.sublist(40, 43), hasLength(3));
    expect(unit.unitQuiz.sublist(43, 46), hasLength(3));
    expect(unit.unitQuiz.sublist(46, 48), hasLength(2));
    expect(unit.unitQuiz.sublist(48, 50), hasLength(2));
    expect(
      unit.unitQuiz.every((item) => item.options.contains(item.correctAnswer)),
      isTrue,
    );
  });

  test(
    'Unit 6 progress and saved vocabulary persist without losing earlier work',
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
        'a2-u10',
        'a2-u11',
        'a2-u12',
      ]);
      expect(level.unitFiles[6], 'assets/content/a2/unit_07.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u05-l22'},
        unitQuizScores: const {
          'a1-u10': 80,
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
          'a2-u05': 78,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u06-l01-receptionist',
        type: SavedItemType.word,
        englishText: 'Receptionist',
        somaliText: 'soo-dhoweeye',
        lessonId: 'a2-u06-l01',
        createdAt: DateTime(2026, 7, 20),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u06', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u05'), isTrue);
      expect(state.hasPassedUnit('a2-u06'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u06-l01');
      expect(storage.courseProgress.unitQuizScores['a2-u06'], 70);
    },
  );
}
