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

  test('A2 Unit 9 is complete, valid, and references Unit 8', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final previous = await repository.loadUnit(
      'assets/content/a2/unit_08.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_09.json');
    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u09');
    expect(unit.requiredPreviousUnitId, previous.id);
    expect(unit.lessons, hasLength(30));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(50));
    expect(unit.unitQuiz, hasLength(55));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(339));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(71));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(398),
    );
    for (var i = 1; i < unit.lessons.length; i++) {
      expect(unit.lessons[i].requiredPreviousLessonId, unit.lessons[i - 1].id);
    }
  });

  test('all A2 IDs remain globally unique through Unit 9', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var n = 1; n <= 9; n++)
        repository.loadUnit(
          'assets/content/a2/unit_${n.toString().padLeft(2, '0')}.json',
        ),
    ]);
    final ids = <String>[];
    for (final unit in units) {
      ids.add(unit.id);
      for (final lesson in unit.lessons) {
        ids.add(lesson.id);
        ids.addAll(lesson.practiceExercises.map((e) => e.id));
        ids.addAll(lesson.quizQuestions.map((e) => e.id));
        ids.addAll(
          lesson.grammar?.practiceQuestions.map((e) => e.id) ?? const [],
        );
      }
      ids.addAll(unit.unitQuiz.map((e) => e.id));
    }
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('future-plan vocabulary examples are contextual and TTS-ready', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_09.json');
    final vocabulary = unit.lessons
        .expand((lesson) => lesson.vocabulary)
        .toList();
    final exampleText = vocabulary.map((item) => item.exampleEnglish).toList();
    expect(
      exampleText,
      containsAll([
        'Her main goal is to complete the English course before the end of the year.',
        'I have arranged an appointment with the course adviser for tomorrow morning.',
        'We postponed the meeting until Monday because two team members were unavailable.',
        'She follows a weekly study plan to help her achieve her language-learning goal.',
      ]),
    );
    expect(
      vocabulary.every(
        (item) =>
            item.englishWord.isNotEmpty &&
            item.pronunciation.isNotEmpty &&
            item.exampleSomali.isNotEmpty &&
            item.partOfSpeech.contains('neutral'),
      ),
      isTrue,
    );
  });

  test(
    'going to, will, arrangements, conditionals, and time clauses are accurate',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_09.json');
      expect(
        unit.lessons[2].grammar!.sentenceStructure,
        contains('going to + base verb'),
      );
      expect(unit.lessons[3].grammar!.rule, contains('Negative'));
      expect(unit.lessons[4].grammar!.rule, contains('Present Continuous'));
      expect(unit.lessons[5].grammar!.rule, contains('Going to'));
      expect(unit.lessons[6].grammar!.rule, contains('Will + base verb'));
      expect(unit.lessons[9].grammar!.rule, contains('instant decision'));
      expect(unit.lessons[10].grammar!.rule, contains('May/might + base verb'));
      expect(
        unit.lessons[18].grammar!.sentenceStructure,
        contains('If + Present Simple'),
      );
      expect(unit.lessons[19].grammar!.rule, contains('will laguma celiyo'));
      final raw = await rootBundle.loadString('assets/content/a2/unit_09.json');
      expect(raw, isNot(contains('Future Continuous')));
      expect(raw, isNot(contains('Future Perfect')));
      expect(raw, contains('when I arrive'));
      expect(
        unit.unitQuiz.map((question) => question.correctAnswer),
        isNot(contains('I will call when I will arrive.')),
      );
    },
  );

  test(
    'action plan, calendar, goal writing, reading, and conversations meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_09.json');
      final actionPlan = unit.lessons[13].dialogues.first;
      final calendar = unit.lessons[14].dialogues.first;
      final goalText = unit.lessons[25].dialogues.first.lines.first.english;
      final reading = unit.lessons[26].dialogues.first.lines.first.english;
      final conversations = unit.lessons[27];
      expect(actionPlan.lines, hasLength(8));
      expect(calendar.lines, hasLength(7));
      expect(
        calendar.lines.map((line) => line.english).join(' '),
        contains('09:00–10:00'),
      );
      expect(goalText.split(RegExp(r'\s+')).length, inInclusiveRange(140, 190));
      expect(reading.split(RegExp(r'\s+')).length, inInclusiveRange(200, 280));
      expect(conversations.dialogues, hasLength(8));
      expect(
        conversations.dialogues.every(
          (d) => d.lines.length >= 10 && d.lines.length <= 16,
        ),
        isTrue,
      );
    },
  );

  test('Unit 9 quiz has 55 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_09.json');
    expect(unit.unitQuiz.sublist(0, 5), hasLength(5));
    expect(unit.unitQuiz.sublist(5, 12), hasLength(7));
    expect(unit.unitQuiz.sublist(12, 17), hasLength(5));
    expect(unit.unitQuiz.sublist(17, 22), hasLength(5));
    expect(unit.unitQuiz.sublist(22, 29), hasLength(7));
    expect(unit.unitQuiz.sublist(29, 35), hasLength(6));
    expect(unit.unitQuiz.sublist(35, 39), hasLength(4));
    expect(unit.unitQuiz.sublist(39, 42), hasLength(3));
    expect(unit.unitQuiz.sublist(42, 45), hasLength(3));
    expect(unit.unitQuiz.sublist(45, 49), hasLength(4));
    expect(unit.unitQuiz.sublist(49, 52), hasLength(3));
    expect(unit.unitQuiz.sublist(52, 55), hasLength(3));
    expect(
      unit.unitQuiz.every((q) => q.options.contains(q.correctAnswer)),
      isTrue,
    );
  });

  test(
    'Unit 9 progress and saved vocabulary persist without losing earlier work',
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
      expect(level.unitFiles[9], 'assets/content/a2/unit_10.json');
      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u08-l29'},
        unitQuizScores: const {
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
          'a2-u05': 78,
          'a2-u06': 80,
          'a2-u07': 84,
          'a2-u08': 86,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u09-l13-goal',
        type: SavedItemType.word,
        englishText: 'Goal',
        somaliText: 'hadaf',
        lessonId: 'a2-u09-l13',
        createdAt: DateTime(2026, 7, 20),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u09', 69);
      expect(state.hasPassedUnit('a2-u09'), isFalse);
      await state.recordUnitQuizScore('a2-u09', 70);
      expect(state.hasPassedUnit('a2-u08'), isTrue);
      expect(state.hasPassedUnit('a2-u09'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u09-l13');
      expect(storage.courseProgress.unitQuizScores['a2-u09'], 70);
    },
  );
}
