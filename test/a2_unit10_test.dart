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

  test('A2 Unit 10 is complete, valid, and references Unit 9', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final previous = await repository.loadUnit(
      'assets/content/a2/unit_09.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_10.json');
    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u10');
    expect(unit.requiredPreviousUnitId, previous.id);
    expect(unit.lessons, hasLength(32));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(50));
    expect(unit.unitQuiz, hasLength(59));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(457));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(94));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(422),
    );
    for (var i = 1; i < unit.lessons.length; i++) {
      expect(unit.lessons[i].requiredPreviousLessonId, unit.lessons[i - 1].id);
    }
  });

  test('all A2 IDs remain globally unique through Unit 10', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var n = 1; n <= 10; n++)
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

  test('place vocabulary examples are contextual and TTS-ready', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_10.json');
    final vocabulary = unit.lessons
        .expand((lesson) => lesson.vocabulary)
        .toList();
    final examples = vocabulary.map((item) => item.exampleEnglish).toList();
    expect(
      examples,
      containsAll([
        'Our neighbourhood is quiet, and most daily services are within walking distance.',
        'The central market becomes crowded in the afternoon when people finish work.',
        'The apartment is in a convenient location because it is close to shops and public transport.',
        'Visitors must use the main entrance at the front of the fictional building.',
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
    final furniture = unit.lessons[2].vocabulary.firstWhere(
      (item) => item.englishWord == 'Furniture',
    );
    expect(furniture.commonMistakeSomali, contains('uncountable'));
    expect(
      jsonEncode(
        vocabulary.map((item) => item.exampleEnglish).toList(),
      ).toLowerCase(),
      isNot(contains('furnitures')),
    );
  });

  test('place grammar and comparison forms are accurate at A2', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_10.json');
    expect(unit.lessons[4].grammar!.rule, contains('There is'));
    expect(unit.lessons[8].grammar!.sentenceStructure, contains('preposition'));
    expect(unit.lessons[11].grammar!.rule, contains('Movement'));
    expect(unit.lessons[13].grammar!.rule, contains('Comparative'));
    expect(unit.lessons[14].grammar!.rule, contains('Superlative'));
    expect(
      unit.lessons[15].grammar!.sentenceStructure,
      contains('as + adjective + as'),
    );
    expect(unit.lessons[16].grammar!.rule, contains('enough + noun'));
    expect(unit.lessons[17].grammar!.rule, contains('One'));
    expect(unit.lessons[18].grammar!.rule, contains('who'));
    expect(unit.lessons[19].grammar!.rule, contains('Where'));
    final raw = await rootBundle.loadString('assets/content/a2/unit_10.json');
    expect(raw, isNot(contains('non-defining relative')));
    expect(raw, isNot(contains('reduced relative')));
    expect(raw, contains('better'));
    expect(raw, contains('worse'));
    expect(raw, contains('farther'));
  });

  test(
    'maps, signs, properties, readings, and conversations meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_10.json');
      final mapsAndSigns = unit.lessons[23];
      final ads = unit.lessons[24];
      final comparison = unit.lessons[25].dialogues.first;
      final description = unit.lessons[26].dialogues.first.lines.first.english;
      final reading = unit.lessons[28].dialogues.first.lines.first.english;
      final conversations = unit.lessons[29];
      expect(mapsAndSigns.dialogues, hasLength(14));
      expect(ads.dialogues, hasLength(5));
      expect(comparison.lines, hasLength(4));
      expect(
        description.split(RegExp(r'\s+')).length,
        inInclusiveRange(140, 190),
      );
      expect(reading.split(RegExp(r'\s+')).length, inInclusiveRange(210, 290));
      expect(conversations.dialogues, hasLength(8));
      expect(
        conversations.dialogues.every(
          (d) => d.lines.length >= 10 && d.lines.length <= 16,
        ),
        isTrue,
      );
    },
  );

  test('Unit 10 quiz has 59 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_10.json');
    final ranges = <List<int>>[
      [0, 6],
      [6, 10],
      [10, 15],
      [15, 20],
      [20, 24],
      [24, 31],
      [31, 36],
      [36, 40],
      [40, 44],
      [44, 47],
      [47, 51],
      [51, 55],
      [55, 57],
      [57, 59],
    ];
    final counts = <int>[6, 4, 5, 5, 4, 7, 5, 4, 4, 3, 4, 4, 2, 2];
    for (var i = 0; i < ranges.length; i++) {
      expect(
        unit.unitQuiz.sublist(ranges[i][0], ranges[i][1]),
        hasLength(counts[i]),
      );
    }
    expect(
      unit.unitQuiz.every((q) => q.options.contains(q.correctAnswer)),
      isTrue,
    );
  });

  test(
    'Unit 10 progress and saved vocabulary persist without losing earlier work',
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
      expect(level.unitFiles[10], 'assets/content/a2/unit_11.json');
      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u09-l30'},
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
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u10-l07-neighbourhood',
        type: SavedItemType.word,
        englishText: 'Neighbourhood',
        somaliText: 'xaafad',
        lessonId: 'a2-u10-l07',
        createdAt: DateTime(2026, 7, 22),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u10', 69);
      expect(state.hasPassedUnit('a2-u10'), isFalse);
      await state.recordUnitQuizScore('a2-u10', 70);
      expect(state.hasPassedUnit('a2-u09'), isTrue);
      expect(state.hasPassedUnit('a2-u10'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u10-l07');
      expect(storage.courseProgress.unitQuizScores['a2-u10'], 70);
    },
  );
}
