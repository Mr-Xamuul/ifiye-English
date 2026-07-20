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

  test('A2 Unit 2 is complete, valid, and references Unit 1', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitOne = await repository.loadUnit('assets/content/a2/unit_01.json');
    final unitTwo = await repository.loadUnit('assets/content/a2/unit_02.json');

    expect(const ContentValidator().validateUnit(unitTwo).errors, isEmpty);
    expect(unitTwo.id, 'a2-u02');
    expect(unitTwo.levelId, 'A2');
    expect(unitTwo.requiredPreviousUnitId, unitOne.id);
    expect(unitTwo.lessons, hasLength(18));
    expect(unitTwo.lessons.last.lessonType.name, 'review');
    expect(unitTwo.lessons.last.practiceExercises, hasLength(35));
    expect(unitTwo.unitQuiz, hasLength(40));
    expect(
      unitTwo.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(223),
    );
    expect(unitTwo.lessons.expand((lesson) => lesson.dialogues), hasLength(40));
    expect(
      unitTwo.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(205),
    );
    for (var index = 1; index < unitTwo.lessons.length; index++) {
      expect(
        unitTwo.lessons[index].requiredPreviousLessonId,
        unitTwo.lessons[index - 1].id,
      );
    }
  });

  test('A2 Unit 1 and Unit 2 IDs never collide', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      repository.loadUnit('assets/content/a2/unit_01.json'),
      repository.loadUnit('assets/content/a2/unit_02.json'),
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
    expect(ids.where((id) => id.startsWith('a2-u02')), hasLength(358));
  });

  test(
    'travel timetable, reading, announcements, and dialogues are complete',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_02.json');
      final timetable = unit.lessons[4];
      final announcements = unit.lessons[13];
      final reading = unit.lessons[14];
      final conversations = unit.lessons[15];

      expect(
        timetable.practiceExercises
            .firstWhere((item) => item.question.contains('08:00'))
            .correctAnswer,
        '2 hours 30 minutes',
      );
      expect(
        timetable.practiceExercises
            .firstWhere((item) => item.question.contains('14:20'))
            .correctAnswer,
        '1 hour 45 minutes',
      );
      expect(announcements.examples.take(8), hasLength(8));
      expect(announcements.practiceExercises.take(8), hasLength(8));
      expect(
        announcements.practiceExercises
            .take(8)
            .every((item) => item.options.contains(item.correctAnswer)),
        isTrue,
      );
      final passage = reading.examples
          .map((item) => item.english)
          .firstWhere((text) => text.split(RegExp(r'\s+')).length > 100);
      final wordCount = passage.split(RegExp(r'\s+')).length;
      expect(wordCount, inInclusiveRange(150, 220));
      expect(
        reading.practiceExercises.where(
          (item) => item.type.name == 'readingComprehension',
        ),
        hasLength(7),
      );
      expect(conversations.dialogues, hasLength(6));
      expect(
        conversations.dialogues.every(
          (dialogue) =>
              dialogue.lines.length >= 10 && dialogue.lines.length <= 16,
        ),
        isTrue,
      );
    },
  );

  test(
    'going-to, travel prepositions, and quiz distribution are correct',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_02.json');
      final goingTo = unit.lessons[10];
      final mistakes = unit.lessons[16];

      expect(goingTo.grammar, isNotNull);
      expect(goingTo.grammar!.sentenceStructure, contains('am/is/are'));
      expect(goingTo.grammar!.positiveExamples, hasLength(8));
      expect(
        goingTo.examples.map((item) => item.english),
        containsAll([
          'I am going to travel next week.',
          'She is going to visit her family.',
          'We are going to take a bus.',
        ]),
      );
      expect(
        mistakes.examples.map((item) => item.english),
        containsAll([
          'I go on foot.',
          'I arrived at the airport.',
          'I arrived in Mogadishu.',
        ]),
      );

      expect(unit.unitQuiz.sublist(0, 7), hasLength(7));
      expect(unit.unitQuiz.sublist(7, 12), hasLength(5));
      expect(unit.unitQuiz.sublist(12, 17), hasLength(5));
      expect(unit.unitQuiz.sublist(17, 21), hasLength(4));
      expect(unit.unitQuiz.sublist(21, 27), hasLength(6));
      expect(unit.unitQuiz.sublist(27, 31), hasLength(4));
      expect(unit.unitQuiz.sublist(31, 35), hasLength(4));
      expect(unit.unitQuiz.sublist(35, 38), hasLength(3));
      expect(unit.unitQuiz.sublist(38, 40), hasLength(2));
      expect(
        unit.unitQuiz.every(
          (item) => item.options.contains(item.correctAnswer),
        ),
        isTrue,
      );
    },
  );

  test(
    'available A2 units stop at Unit 2 and progress remains persistent',
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
      ]);
      expect(level.unitFiles[2], 'assets/content/a2/unit_03.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14'},
        unitQuizScores: const {'a1-u10': 80, 'a2-u01': 76},
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u02-l01-bus',
        type: SavedItemType.word,
        englishText: 'Bus',
        somaliText: 'bas',
        lessonId: 'a2-u02-l01',
        createdAt: DateTime(2026, 7, 18),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u02', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u02'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.courseProgress.unitQuizScores['a1-u10'], 80);
      expect(state.savedItems.single.englishText, 'Bus');
      expect(storage.courseProgress.unitQuizScores['a2-u02'], 70);
    },
  );
}
