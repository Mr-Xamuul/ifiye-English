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

  test('A2 Unit 3 is complete, valid, and references Unit 2', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitTwo = await repository.loadUnit('assets/content/a2/unit_02.json');
    final unitThree = await repository.loadUnit(
      'assets/content/a2/unit_03.json',
    );

    expect(const ContentValidator().validateUnit(unitThree).errors, isEmpty);
    expect(unitThree.id, 'a2-u03');
    expect(unitThree.levelId, 'A2');
    expect(unitThree.requiredPreviousUnitId, unitTwo.id);
    expect(unitThree.lessons, hasLength(19));
    expect(unitThree.lessons.last.lessonType.name, 'review');
    expect(unitThree.lessons.last.practiceExercises, hasLength(35));
    expect(unitThree.unitQuiz, hasLength(40));
    expect(
      unitThree.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(238),
    );
    expect(
      unitThree.lessons.expand((lesson) => lesson.dialogues),
      hasLength(42),
    );
    expect(
      unitThree.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(215),
    );
    for (var index = 1; index < unitThree.lessons.length; index++) {
      expect(
        unitThree.lessons[index].requiredPreviousLessonId,
        unitThree.lessons[index - 1].id,
      );
    }
  });

  test('A2 Unit 1 to Unit 3 IDs are globally unique', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      repository.loadUnit('assets/content/a2/unit_01.json'),
      repository.loadUnit('assets/content/a2/unit_02.json'),
      repository.loadUnit('assets/content/a2/unit_03.json'),
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
    expect(ids.where((id) => id.startsWith('a2-u03')), hasLength(376));
  });

  test('body plurals and Unit 3 grammar forms are accurate', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_03.json');
    final bodyWords = unit.lessons[0].vocabulary
        .map((item) => item.englishWord)
        .toSet();
    final feelings = unit.lessons[1];
    final haveGot = unit.lessons[3];
    final should = unit.lessons[7];
    final haveTo = unit.lessons[8];

    expect(bodyWords, containsAll(['Tooth / teeth', 'Foot / feet']));
    expect(
      feelings.grammar!.sentenceStructure,
      'Subject + feel/feels + adjective.',
    );
    expect(haveGot.grammar!.positiveExamples, hasLength(8));
    expect(
      haveGot.examples.map((item) => item.english),
      containsAll([
        'I have got a headache.',
        'She has got a cough.',
        'Has she got a fever?',
      ]),
    );
    expect(
      should.examples.map((item) => item.english),
      containsAll([
        'You should rest.',
        'She should drink some water.',
        'Should I make an appointment?',
      ]),
    );
    expect(should.grammar!.sentenceStructure, contains('base verb'));
    expect(
      haveTo.examples.map((item) => item.english),
      containsAll([
        'I have to make an appointment.',
        'She has to arrive early.',
        'You don’t have to come today.',
      ]),
    );
  });

  test(
    'notices, reading, and complete conversations meet requirements',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_03.json');
      final notices = unit.lessons[13];
      final reading = unit.lessons[15];
      final conversations = unit.lessons[16];

      expect(notices.vocabulary, hasLength(10));
      expect(notices.practiceExercises, hasLength(10));
      expect(
        notices.practiceExercises.every(
          (item) => item.options.contains(item.correctAnswer),
        ),
        isTrue,
      );
      final passage = reading.examples
          .map((item) => item.english)
          .firstWhere((text) => text.split(RegExp(r'\s+')).length > 100);
      expect(passage.split(RegExp(r'\s+')).length, inInclusiveRange(150, 220));
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
    'health content contains no diagnosis, medication dose, or drug names',
    () async {
      final source = await rootBundle.loadString(
        'assets/content/a2/unit_03.json',
      );
      final lower = source.toLowerCase();

      expect(RegExp(r'\b\d+(\.\d+)?\s*(mg|ml)\b').hasMatch(lower), isFalse);
      expect(
        lower.contains(
          RegExp(r'\b(amoxicillin|ibuprofen|paracetamol|aspirin)\b'),
        ),
        isFalse,
      );
      expect(lower, contains('language-learning'));
      expect(lower, contains('local emergency services'));
      expect(lower, isNot(contains('call 911')));
      expect(lower, isNot(contains('call 999')));
    },
  );

  test('Unit 3 quiz has the requested 40-question distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_03.json');
    expect(unit.unitQuiz.sublist(0, 6), hasLength(6));
    expect(unit.unitQuiz.sublist(6, 12), hasLength(6));
    expect(unit.unitQuiz.sublist(12, 17), hasLength(5));
    expect(unit.unitQuiz.sublist(17, 22), hasLength(5));
    expect(unit.unitQuiz.sublist(22, 28), hasLength(6));
    expect(unit.unitQuiz.sublist(28, 33), hasLength(5));
    expect(unit.unitQuiz.sublist(33, 36), hasLength(3));
    expect(unit.unitQuiz.sublist(36, 38), hasLength(2));
    expect(unit.unitQuiz.sublist(38, 40), hasLength(2));
    expect(
      unit.unitQuiz.every((item) => item.options.contains(item.correctAnswer)),
      isTrue,
    );
  });

  test(
    'available A2 content ends at Unit 3 and progress is preserved',
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
      ]);
      expect(level.unitFiles[3], 'assets/content/a2/unit_04.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u02-l18'},
        unitQuizScores: const {'a1-u10': 80, 'a2-u01': 76, 'a2-u02': 74},
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u03-l01-head',
        type: SavedItemType.word,
        englishText: 'Head / heads',
        somaliText: 'madax / madaxyo',
        lessonId: 'a2-u03-l01',
        createdAt: DateTime(2026, 7, 18),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u03', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u02'), isTrue);
      expect(state.hasPassedUnit('a2-u03'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u03-l01');
      expect(storage.courseProgress.unitQuizScores['a2-u03'], 70);
    },
  );
}
