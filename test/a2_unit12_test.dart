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

  test('A2 Unit 12 is complete, valid, and references Unit 11', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final previous = await repository.loadUnit(
      'assets/content/a2/unit_11.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_12.json');
    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u12');
    expect(unit.requiredPreviousUnitId, previous.id);
    expect(unit.lessons, hasLength(36));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(55));
    expect(unit.unitQuiz, hasLength(60));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(437));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(120));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(475),
    );
    for (var i = 1; i < unit.lessons.length; i++) {
      expect(unit.lessons[i].requiredPreviousLessonId, unit.lessons[i - 1].id);
    }
  });

  test('all A2 IDs remain globally unique through Unit 12', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var n = 1; n <= 12; n++)
        repository.loadUnit(
          'assets/content/a2/unit_${n.toString().padLeft(2, '0')}.json',
        ),
    ]);
    final ids = <String>[];
    for (final unit in units) {
      ids.add(unit.id);
      for (final lesson in unit.lessons) {
        ids.add(lesson.id);
        ids.addAll(lesson.practiceExercises.map((exercise) => exercise.id));
        ids.addAll(lesson.quizQuestions.map((question) => question.id));
        ids.addAll(
          lesson.grammar?.practiceQuestions.map((question) => question.id) ??
              const [],
        );
      }
      ids.addAll(unit.unitQuiz.map((question) => question.id));
    }
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('service vocabulary is contextual, labelled, and TTS-ready', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_12.json');
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
            item.partOfSpeech.contains('everyday problem solving'),
      ),
      isTrue,
    );
    final raw = await rootBundle.loadString('assets/content/a2/unit_12.json');
    expect(
      raw,
      contains(
        'The delivery service sent a message before bringing the fictional package.',
      ),
    );
    expect(raw, contains('I would like a replacement because'));
    expect(
      raw,
      contains('There was a misunderstanding about the meeting time'),
    );
    expect(raw, isNot(contains('"englishWord": "An information"')));
    expect(raw, isNot(contains('"englishWord": "An advice"')));
  });

  test(
    'integrated grammar and problem-solving forms are accurate at A2',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_12.json');
      expect(unit.lessons[1].grammar!.rule, contains('statement word order'));
      expect(unit.lessons[4].grammar!.rule, contains('Past Simple'));
      expect(unit.lessons[5].grammar!.rule, contains('Present Perfect'));
      expect(unit.lessons[16].grammar!.rule, contains('first conditional'));
      expect(unit.lessons[17].grammar!.rule, contains('because of'));
      expect(unit.lessons[18].grammar!.rule, contains('However'));
      expect(unit.lessons[33].grammar!.rule, contains('current result'));
      final raw = await rootBundle.loadString('assets/content/a2/unit_12.json');
      expect(raw, contains('Could you tell me where the office is?'));
      expect(raw, isNot(contains('Could you tell me where is the office?')));
      expect(raw, contains('My order has not arrived yet.'));
      expect(raw, contains('My order did not arrive.'));
    },
  );

  test(
    'mock documents, scenarios, readings, and dialogues meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_12.json');
      expect(unit.lessons[12].dialogues, hasLength(5));
      expect(unit.lessons[13].dialogues, hasLength(5));
      expect(unit.lessons[19].dialogues, hasLength(5));
      expect(unit.lessons[20].dialogues, hasLength(5));
      expect(unit.lessons[21].dialogues, hasLength(7));
      expect(unit.lessons[25].dialogues, hasLength(12));
      expect(unit.lessons[26].dialogues, hasLength(7));
      expect(unit.lessons[30].dialogues, hasLength(10));
      expect(unit.lessons[32].dialogues, hasLength(10));
      expect(
        unit.lessons[32].dialogues.every(
          (dialogue) =>
              dialogue.lines.length >= 12 && dialogue.lines.length <= 20,
        ),
        isTrue,
      );
      final complaint = unit.lessons[28].dialogues.first.lines.first.english;
      expect(
        complaint.split(RegExp(r'\s+')).length,
        inInclusiveRange(130, 190),
      );
      final reading = unit.lessons[31].dialogues.first.lines.first.english;
      expect(reading.split(RegExp(r'\s+')).length, inInclusiveRange(230, 320));
    },
  );

  test('Unit 12 quiz has 60 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_12.json');
    final ranges = <List<int>>[
      [0, 5],
      [5, 10],
      [10, 16],
      [16, 21],
      [21, 26],
      [26, 31],
      [31, 35],
      [35, 39],
      [39, 43],
      [43, 46],
      [46, 50],
      [50, 53],
      [53, 56],
      [56, 58],
      [58, 60],
    ];
    final counts = <int>[5, 5, 6, 5, 5, 5, 4, 4, 4, 3, 4, 3, 3, 2, 2];
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
    'Unit 12 pass persists and preserves earlier progress and vocabulary',
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
      expect(level.unitFiles, hasLength(12));
      expect(level.finalExamFile, 'assets/content/a2/final_exam.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u11-l34'},
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
          'a2-u11': 92,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u12-l07-replacement',
        type: SavedItemType.word,
        englishText: 'I would like a replacement.',
        somaliText: 'Waxaan jeclaan lahaa beddel.',
        lessonId: 'a2-u12-l07',
        createdAt: DateTime(2026, 7, 22),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u12', 69);
      expect(state.hasPassedUnit('a2-u12'), isFalse);
      await state.recordUnitQuizScore('a2-u12', 70);
      expect(state.hasPassedUnit('a2-u11'), isTrue);
      expect(state.hasPassedUnit('a2-u12'), isTrue);
      expect(state.hasCompletedFinalReview, isFalse);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u12-l07');
      expect(storage.courseProgress.unitQuizScores['a2-u12'], 70);
    },
  );
}
