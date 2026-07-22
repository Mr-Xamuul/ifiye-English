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

  test('A2 Unit 11 is complete, valid, and references Unit 10', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final previous = await repository.loadUnit(
      'assets/content/a2/unit_10.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_11.json');
    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u11');
    expect(unit.requiredPreviousUnitId, previous.id);
    expect(unit.lessons, hasLength(34));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(50));
    expect(unit.unitQuiz, hasLength(55));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(408));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(87));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(446),
    );
    for (var i = 1; i < unit.lessons.length; i++) {
      expect(unit.lessons[i].requiredPreviousLessonId, unit.lessons[i - 1].id);
    }
  });

  test('all A2 IDs remain globally unique through Unit 11', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var n = 1; n <= 11; n++)
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

  test(
    'communication phrases are contextual, labelled, and TTS-ready',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_11.json');
      final vocabulary = unit.lessons
          .expand((lesson) => lesson.vocabulary)
          .toList();
      expect(
        vocabulary.every(
          (item) =>
              item.englishWord.isNotEmpty &&
              item.pronunciation.isNotEmpty &&
              item.exampleEnglish.isNotEmpty &&
              item.exampleSomali.isNotEmpty &&
              (item.partOfSpeech.contains('formal') ||
                  item.partOfSpeech.contains('neutral') ||
                  item.partOfSpeech.contains('informal') ||
                  item.partOfSpeech.contains('polite') ||
                  item.partOfSpeech.contains('friendly')),
        ),
        isTrue,
      );
      final raw = await rootBundle.loadString('assets/content/a2/unit_11.json');
      expect(raw, contains('I apologized to the customer'));
      expect(raw, contains('Would you mind closing the door?'));
      expect(raw, contains('I really appreciate it.'));
      expect(raw, isNot(contains('"englishWord": "An advice"')));
    },
  );

  test(
    'requests, apologies, advice, and verb patterns are accurate at A2',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_11.json');
      expect(unit.lessons[6].grammar!.sentenceStructure, contains('Can/Could'));
      expect(unit.lessons[7].grammar!.sentenceStructure, contains('verb-ing'));
      expect(unit.lessons[8].grammar!.rule, contains('may'));
      expect(unit.lessons[11].grammar!.rule, contains('apologize to'));
      expect(unit.lessons[16].grammar!.rule, contains('uncountable'));
      expect(unit.lessons[17].grammar!.rule, contains('Should'));
      expect(unit.lessons[18].grammar!.rule, contains('I agree'));
      expect(unit.lessons[20].grammar!.rule, contains('clarification'));
      expect(unit.lessons[32].grammar!.rule, contains('explain something to'));
    },
  );

  test(
    'phones, messages, reading, and complete dialogues meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_11.json');
      expect(unit.lessons[22].dialogues, hasLength(5));
      expect(unit.lessons[23].dialogues, hasLength(5));
      expect(unit.lessons[24].dialogues, hasLength(7));
      final reading = unit.lessons[30].dialogues.first.lines.first.english;
      expect(reading.split(RegExp(r'\s+')).length, inInclusiveRange(210, 290));
      final conversations = unit.lessons[31].dialogues;
      expect(conversations, hasLength(10));
      expect(
        conversations.every(
          (dialogue) =>
              dialogue.lines.length >= 10 && dialogue.lines.length <= 18,
        ),
        isTrue,
      );
    },
  );

  test('Unit 11 quiz has 55 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_11.json');
    final ranges = <List<int>>[
      [0, 5],
      [5, 9],
      [9, 15],
      [15, 20],
      [20, 24],
      [24, 28],
      [28, 33],
      [33, 37],
      [37, 41],
      [41, 45],
      [45, 48],
      [48, 51],
      [51, 53],
      [53, 55],
    ];
    final counts = <int>[5, 4, 6, 5, 4, 4, 5, 4, 4, 4, 3, 3, 2, 2];
    for (var i = 0; i < ranges.length; i++) {
      expect(
        unit.unitQuiz.sublist(ranges[i][0], ranges[i][1]),
        hasLength(counts[i]),
      );
    }
    expect(
      unit.unitQuiz.every(
        (question) => question.options.contains(question.correctAnswer),
      ),
      isTrue,
    );
  });

  test(
    'Unit 11 pass and saved vocabulary persist without losing earlier work',
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
      expect(level.unitFiles[11], 'assets/content/a2/unit_12.json');
      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u10-l32'},
        unitQuizScores: const {
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
          'a2-u05': 78,
          'a2-u06': 80,
          'a2-u07': 84,
          'a2-u08': 86,
          'a2-u09': 88,
          'a2-u10': 90,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u11-l07-could-request',
        type: SavedItemType.word,
        englishText: 'Could you repeat that, please?',
        somaliText: 'Fadlan taas ma ku celin kartaa?',
        lessonId: 'a2-u11-l07',
        createdAt: DateTime(2026, 7, 22),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u11', 69);
      expect(state.hasPassedUnit('a2-u11'), isFalse);
      await state.recordUnitQuizScore('a2-u11', 70);
      expect(state.hasPassedUnit('a2-u10'), isTrue);
      expect(state.hasPassedUnit('a2-u11'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u11-l07');
      expect(storage.courseProgress.unitQuizScores['a2-u11'], 70);
    },
  );
}
