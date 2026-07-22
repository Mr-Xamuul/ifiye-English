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

  test('A2 Unit 7 is complete, valid, and references Unit 6', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitSix = await repository.loadUnit('assets/content/a2/unit_06.json');
    final unit = await repository.loadUnit('assets/content/a2/unit_07.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u07');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, unitSix.id);
    expect(unit.lessons, hasLength(28));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(45));
    expect(unit.unitQuiz, hasLength(54));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(389));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(62));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(369),
    );
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test('all A2 IDs remain globally unique through Unit 7', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var number = 1; number <= 7; number++)
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

  test('education vocabulary examples are contextual and complete', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_07.json');
    final vocabulary = unit.lessons.expand((lesson) => lesson.vocabulary);
    final examples = vocabulary.map((item) => item.exampleEnglish).toList();

    expect(
      examples,
      containsAll([
        'Our teacher gave us a writing assignment that we must complete by Thursday.',
        'I am going to revise the grammar lessons before Monday’s exam.',
        'He turned off his phone so that he could concentrate on the lesson.',
        'Her English progress improved after she began practising for twenty minutes every day.',
      ]),
    );
    expect(
      vocabulary.every(
        (item) =>
            item.exampleEnglish.trim().isNotEmpty &&
            item.exampleSomali.trim().isNotEmpty &&
            item.explanationSomali.contains('Common collocation'),
      ),
      isTrue,
    );
    expect(
      unit.lessons[6].vocabulary
          .map((item) => item.exampleEnglish.toLowerCase())
          .any((example) => example.contains('homeworks')),
      isFalse,
    );
  });

  test('Present Perfect and education grammar stay accurate at A2', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_07.json');
    final ability = unit.lessons[10].grammar!;
    final presentPerfect = unit.lessons[12].grammar!;
    final participles = unit.lessons[13];
    final everNever = unit.lessons[14].grammar!;
    final adverbs = unit.lessons[15].grammar!;
    final tense = unit.lessons[16].grammar!;
    final forSince = unit.lessons[17].grammar!;
    final participleWords = participles.vocabulary
        .map((item) => item.englishWord.toLowerCase())
        .join(' ');

    expect(ability.sentenceStructure, contains('be + able to'));
    expect(presentPerfect.sentenceStructure, contains('have'));
    expect(presentPerfect.sentenceStructure, contains('past participle'));
    for (final form in [
      'done',
      'written',
      'spoken',
      'seen',
      'taken',
      'given',
      'known',
      'begun',
      'forgotten',
      'understood',
    ]) {
      expect(participleWords, contains(form));
    }
    expect(everNever.rule, contains('never'));
    expect(adverbs.rule, contains('yet'));
    expect(tense.rule, contains('Past Simple'));
    expect(forSince.rule, contains('For + duration'));
    expect(forSince.rule, contains('since + starting point'));
    expect(
      unit.lessons
          .expand((lesson) => lesson.examples)
          .map((item) => item.english)
          .join(' '),
      isNot(contains('have been studying')),
    );
    expect(
      unit.lessons.every(
        (lesson) => lesson.grammar!.positiveExamples.length >= 8,
      ),
      isTrue,
    );
  });

  test('timetable calculations and course information are correct', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_07.json');
    final timetable = unit.lessons[18];
    final timetableText = timetable.examples
        .map((item) => item.english)
        .join('\n');
    final courses = unit.lessons[20];

    expect(timetableText, contains('Science — 09:15–10:30'));
    expect(timetableText, contains('75 minutes'));
    expect(timetableText, contains('Mathematics — 08:00–09:30'));
    expect(timetableText, contains('90 minutes'));
    expect(timetable.practiceExercises[1].correctAnswer, '75 minutes');
    expect(timetable.practiceExercises[5].correctAnswer, 'Two');
    expect(
      courses.examples.where(
        (item) => RegExp(
          r'^(BEGINNER COMPUTER COURSE|ENGLISH EVENING COURSE|BUSINESS-SKILLS TRAINING|WRITING COURSE|ONLINE LANGUAGE COURSE)',
        ).hasMatch(item.english),
      ),
      hasLength(5),
    );
  });

  test(
    'notices, progress writing, reading, and dialogues meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_07.json');
      final notices = unit.lessons[19];
      final progress = unit.lessons[23].examples.last.english;
      final reading = unit.lessons[24];
      final passage = reading.examples.last.english;
      final conversations = unit.lessons[25];

      expect(notices.examples, hasLength(greaterThanOrEqualTo(10)));
      expect(progress.split(RegExp(r'\s+')).length, inInclusiveRange(120, 170));
      expect(passage.split(RegExp(r'\s+')).length, inInclusiveRange(190, 260));
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
    },
  );

  test('Unit 7 quiz has 54 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_07.json');

    expect(unit.unitQuiz.sublist(0, 7), hasLength(7));
    expect(unit.unitQuiz.sublist(7, 11), hasLength(4));
    expect(unit.unitQuiz.sublist(11, 15), hasLength(4));
    expect(unit.unitQuiz.sublist(15, 19), hasLength(4));
    expect(unit.unitQuiz.sublist(19, 23), hasLength(4));
    expect(unit.unitQuiz.sublist(23, 30), hasLength(7));
    expect(unit.unitQuiz.sublist(30, 34), hasLength(4));
    expect(unit.unitQuiz.sublist(34, 38), hasLength(4));
    expect(unit.unitQuiz.sublist(38, 43), hasLength(5));
    expect(unit.unitQuiz.sublist(43, 46), hasLength(3));
    expect(unit.unitQuiz.sublist(46, 49), hasLength(3));
    expect(unit.unitQuiz.sublist(49, 52), hasLength(3));
    expect(unit.unitQuiz.sublist(52, 54), hasLength(2));
    expect(
      unit.unitQuiz.every((item) => item.options.contains(item.correctAnswer)),
      isTrue,
    );
  });

  test(
    'Unit 7 progress and saved vocabulary persist without losing earlier work',
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
      ]);
      expect(level.unitFiles[7], 'assets/content/a2/unit_08.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u06-l27'},
        unitQuizScores: const {
          'a1-u10': 80,
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
          'a2-u05': 78,
          'a2-u06': 80,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u07-l07-assignment',
        type: SavedItemType.word,
        englishText: 'Assignment',
        somaliText: 'layli la dhiibayo',
        lessonId: 'a2-u07-l07',
        createdAt: DateTime(2026, 7, 20),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      expect(state.hasPassedUnit('a2-u07'), isFalse);
      await state.recordUnitQuizScore('a2-u07', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u06'), isTrue);
      expect(state.hasPassedUnit('a2-u07'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u07-l07');
      expect(storage.courseProgress.unitQuizScores['a2-u07'], 70);
    },
  );
}
