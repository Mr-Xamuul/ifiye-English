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

  test('A2 Unit 4 is complete, valid, and references Unit 3', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final unitThree = await repository.loadUnit(
      'assets/content/a2/unit_03.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_04.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u04');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, unitThree.id);
    expect(unit.lessons, hasLength(20));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(40));
    expect(unit.unitQuiz, hasLength(45));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(244));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(45));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(268),
    );
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test('all A2 IDs remain globally unique through Unit 4', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      repository.loadUnit('assets/content/a2/unit_01.json'),
      repository.loadUnit('assets/content/a2/unit_02.json'),
      repository.loadUnit('assets/content/a2/unit_03.json'),
      repository.loadUnit('assets/content/a2/unit_04.json'),
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

  test('clothing plurals and core shopping grammar are accurate', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_04.json');
    final clothes = unit.lessons[0];
    final accessories = unit.lessons[1];
    final comparatives = unit.lessons[8];
    final tooEnough = unit.lessons[9];
    final oneOnes = unit.lessons[10];

    expect(
      clothes.vocabulary.map((item) => item.englishWord),
      containsAll(['Trousers', 'Jeans', 'Shorts']),
    );
    expect(
      accessories.vocabulary.map((item) => item.englishWord),
      containsAll(['Glasses', 'Sunglasses']),
    );
    expect(
      clothes.examples.map((item) => item.english),
      contains('He needs a pair of trousers.'),
    );
    expect(
      comparatives.examples.map((item) => item.english),
      containsAll([
        'This shirt is cheaper than that one.',
        'These shoes are more comfortable than those shoes.',
        'This jacket is better than the other one.',
        'That product is worse than this one.',
      ]),
    );
    expect(
      comparatives.grammar!.commonMistakesSomali.join(' '),
      isNot(contains('more better ayaa sax')),
    );
    expect(tooEnough.grammar!.sentenceStructure, contains('too + adjective'));
    expect(
      tooEnough.grammar!.sentenceStructure,
      contains('adjective + enough'),
    );
    expect(
      oneOnes.grammar!.rule,
      contains('One wuxuu beddelaa singular countable noun'),
    );
  });

  test(
    'receipts, labels, advertisements, notices, and totals are correct',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_04.json');
      final reading = unit.lessons[15];
      final texts = reading.examples.map((item) => item.english).toList();

      expect(texts.where((text) => text.startsWith('Receipt')), hasLength(2));
      expect(texts.where((text) => text.startsWith('Label')), hasLength(3));
      expect(texts.where((text) => text.startsWith('Sale')), hasLength(3));
      expect(
        texts.where((text) => text.startsWith('Return notice')),
        hasLength(2),
      );
      expect(
        texts,
        contains('Receipt A: Shirt x2 at \$12 each; discount \$4; total \$20.'),
      );
      expect(
        texts,
        contains('Receipt B: Shoes \$30 and socks \$5; cash \$40; change \$5.'),
      );
      expect(
        reading.grammar!.commonMistakesSomali.join(' '),
        contains('2 × 12 − 4 = 20'),
      );
      expect(
        reading.grammar!.commonMistakesSomali.join(' '),
        contains('40 − 35 = 5'),
      );
    },
  );

  test(
    'complete conversations have the required length and learning support',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_04.json');
      final conversations = unit.lessons[17];
      expect(conversations.dialogues, hasLength(7));
      expect(
        conversations.dialogues.every(
          (dialogue) =>
              dialogue.lines.length >= 10 && dialogue.lines.length <= 16,
        ),
        isTrue,
      );
      expect(conversations.practiceExercises, hasLength(12));
      expect(conversations.speakingPractice, contains('role-play'));
    },
  );

  test('Unit 4 quiz has the requested 45-question distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_04.json');
    expect(unit.unitQuiz.sublist(0, 7), hasLength(7));
    expect(unit.unitQuiz.sublist(7, 12), hasLength(5));
    expect(unit.unitQuiz.sublist(12, 17), hasLength(5));
    expect(unit.unitQuiz.sublist(17, 22), hasLength(5));
    expect(unit.unitQuiz.sublist(22, 29), hasLength(7));
    expect(unit.unitQuiz.sublist(29, 34), hasLength(5));
    expect(unit.unitQuiz.sublist(34, 38), hasLength(4));
    expect(unit.unitQuiz.sublist(38, 41), hasLength(3));
    expect(unit.unitQuiz.sublist(41, 43), hasLength(2));
    expect(unit.unitQuiz.sublist(43, 45), hasLength(2));
    expect(
      unit.unitQuiz.every((item) => item.options.contains(item.correctAnswer)),
      isTrue,
    );
  });

  test(
    'Unit 4 progress and saved vocabulary persist without losing earlier work',
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
      expect(level.unitFiles[4], 'assets/content/a2/unit_05.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u03-l19'},
        unitQuizScores: const {
          'a1-u10': 80,
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u04-l01-shirt',
        type: SavedItemType.word,
        englishText: 'Shirt',
        somaliText: 'shaati',
        lessonId: 'a2-u04-l01',
        createdAt: DateTime(2026, 7, 18),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      await state.recordUnitQuizScore('a2-u04', 70);

      expect(state.hasPassedUnit('a2-u01'), isTrue);
      expect(state.hasPassedUnit('a2-u03'), isTrue);
      expect(state.hasPassedUnit('a2-u04'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u04-l01');
      expect(storage.courseProgress.unitQuizScores['a2-u04'], 70);
    },
  );
}
