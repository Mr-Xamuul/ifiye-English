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

  test('A2 Unit 8 is complete, valid, and references Unit 7', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final previous = await repository.loadUnit(
      'assets/content/a2/unit_07.json',
    );
    final unit = await repository.loadUnit('assets/content/a2/unit_08.json');

    expect(const ContentValidator().validateUnit(unit).errors, isEmpty);
    expect(unit.id, 'a2-u08');
    expect(unit.levelId, 'A2');
    expect(unit.requiredPreviousUnitId, previous.id);
    expect(unit.lessons, hasLength(29));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(unit.lessons.last.practiceExercises, hasLength(45));
    expect(unit.unitQuiz, hasLength(50));
    expect(unit.lessons.expand((lesson) => lesson.vocabulary), hasLength(371));
    expect(unit.lessons.expand((lesson) => lesson.dialogues), hasLength(79));
    expect(
      unit.lessons.expand((lesson) => lesson.practiceExercises),
      hasLength(381),
    );
    for (var index = 1; index < unit.lessons.length; index++) {
      expect(
        unit.lessons[index].requiredPreviousLessonId,
        unit.lessons[index - 1].id,
      );
    }
  });

  test('all A2 IDs remain globally unique through Unit 8', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final units = await Future.wait([
      for (var number = 1; number <= 8; number++)
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

  test('free-time vocabulary examples are contextual and TTS-ready', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_08.json');
    final vocabulary = unit.lessons
        .expand((lesson) => lesson.vocabulary)
        .toList();
    final examples = vocabulary.map((item) => item.exampleEnglish).toList();

    expect(
      examples,
      containsAll([
        'Photography is her favourite hobby because she enjoys taking pictures of nature.',
        'The audience laughed and clapped at the end of the fictional comedy show.',
        'I recommend this fictional film because its story is interesting and easy to understand.',
        'Our team practises football twice a week before the weekend match.',
      ]),
    );
    expect(
      vocabulary.every(
        (item) =>
            item.englishWord.trim().isNotEmpty &&
            item.pronunciation.trim().isNotEmpty &&
            RegExp(r'[.!?]$').hasMatch(item.exampleEnglish) &&
            RegExp(r'[.!?]$').hasMatch(item.exampleSomali),
      ),
      isTrue,
    );
    expect(
      vocabulary.every((item) => item.partOfSpeech.contains('neutral')),
      isTrue,
    );
  });

  test(
    'verb forms, collocations, invitations, and tenses stay accurate',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_08.json');
      expect(unit.lessons[2].grammar!.rule, contains('verb-ing'));
      expect(unit.lessons[3].grammar!.rule, contains('Enjoy'));
      expect(unit.lessons[4].grammar!.rule, contains('to + base verb'));
      expect(
        unit.lessons[5].grammar!.sentenceStructure,
        contains('frequency adverb'),
      );
      expect(unit.lessons[12].grammar!.rule, contains('-ing'));
      expect(unit.lessons[12].grammar!.rule, contains('-ed'));
      expect(
        unit.lessons[15].grammar!.sentenceStructure,
        contains('Would you like'),
      );
      expect(unit.lessons[17].grammar!.rule, contains('Present Continuous'));
      expect(unit.lessons[20].grammar!.rule, contains('Present Perfect'));
      final allText = jsonEncode(
        jsonDecode(
          await rootBundle.loadString('assets/content/a2/unit_08.json'),
        ),
      );
      expect(allText, isNot(contains('have been studying')));
      expect(allText, contains('do football'));
      expect(allText, contains('play football'));
      expect(allText, contains('go swimming'));
      expect(allText, contains('do exercise'));
    },
  );

  test(
    'posters, tickets, reviews, readings, and conversations meet targets',
    () async {
      final unit = await CefrContentRepository(
        bundle: rootBundle,
      ).loadUnit('assets/content/a2/unit_08.json');
      final pastStory = unit.lessons[19].dialogues.first.lines.first.english;
      final cards = unit.lessons[21];
      final reviews = unit.lessons[22];
      final reviewModel = unit.lessons[24].dialogues.first.lines.first.english;
      final hobbyReading = unit.lessons[25].dialogues.first.lines.first.english;
      final conversations = unit.lessons[26];

      expect(
        pastStory.split(RegExp(r'\s+')).length,
        inInclusiveRange(130, 180),
      );
      expect(cards.dialogues, hasLength(10));
      expect(
        cards.dialogues.where(
          (dialogue) => dialogue.titleSomali.contains('event poster'),
        ),
        hasLength(3),
      );
      expect(
        cards.dialogues.where(
          (dialogue) => dialogue.titleSomali.contains('Cinema schedule'),
        ),
        hasLength(2),
      );
      expect(
        cards.dialogues.where(
          (dialogue) => dialogue.titleSomali.contains('Sports ticket'),
        ),
        hasLength(2),
      );
      expect(
        cards.dialogues.where(
          (dialogue) => dialogue.titleSomali.contains('club information'),
        ),
        hasLength(2),
      );
      expect(
        cards.dialogues.where(
          (dialogue) => dialogue.titleSomali.contains('notice'),
        ),
        hasLength(1),
      );
      expect(reviews.dialogues, hasLength(5));
      expect(
        reviewModel.split(RegExp(r'\s+')).length,
        inInclusiveRange(100, 160),
      );
      expect(
        hobbyReading.split(RegExp(r'\s+')).length,
        inInclusiveRange(190, 260),
      );
      expect(conversations.dialogues, hasLength(8));
      expect(
        conversations.dialogues.every(
          (dialogue) =>
              dialogue.lines.length >= 10 && dialogue.lines.length <= 16,
        ),
        isTrue,
      );
    },
  );

  test('Unit 8 quiz has 50 valid answers and exact distribution', () async {
    final unit = await CefrContentRepository(
      bundle: rootBundle,
    ).loadUnit('assets/content/a2/unit_08.json');
    expect(unit.unitQuiz.sublist(0, 7), hasLength(7));
    expect(unit.unitQuiz.sublist(7, 11), hasLength(4));
    expect(unit.unitQuiz.sublist(11, 17), hasLength(6));
    expect(unit.unitQuiz.sublist(17, 22), hasLength(5));
    expect(unit.unitQuiz.sublist(22, 26), hasLength(4));
    expect(unit.unitQuiz.sublist(26, 31), hasLength(5));
    expect(unit.unitQuiz.sublist(31, 35), hasLength(4));
    expect(unit.unitQuiz.sublist(35, 40), hasLength(5));
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
    'Unit 8 progress and saved vocabulary persist without losing earlier work',
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
      expect(level.unitFiles[8], 'assets/content/a2/unit_09.json');

      final progress = CourseProgress(
        completedLessonIds: const {'a1-u10-l17', 'a2-u01-l14', 'a2-u07-l28'},
        unitQuizScores: const {
          'a2-u01': 76,
          'a2-u02': 74,
          'a2-u03': 72,
          'a2-u04': 75,
          'a2-u05': 78,
          'a2-u06': 80,
          'a2-u07': 84,
        },
        finalExamScores: const {'A1': 82},
      );
      final saved = SavedItem(
        id: 'a2-u08-l01-photography',
        type: SavedItemType.word,
        englishText: 'Photography',
        somaliText: 'sawir-qaadis',
        lessonId: 'a2-u08-l01',
        createdAt: DateTime(2026, 7, 20),
      );
      SharedPreferences.setMockInitialValues({
        'courseProgress': jsonEncode(progress.toJson()),
        'savedItems': jsonEncode([saved.toJson()]),
      });
      final storage = await LocalStorageService.create();
      final state = AppProvider(storage);
      await state.initialize();
      expect(state.hasPassedUnit('a2-u08'), isFalse);
      await state.recordUnitQuizScore('a2-u08', 69);
      expect(state.hasPassedUnit('a2-u08'), isFalse);
      await state.recordUnitQuizScore('a2-u08', 70);

      expect(state.hasPassedUnit('a2-u07'), isTrue);
      expect(state.hasPassedUnit('a2-u08'), isTrue);
      expect(state.courseProgress.finalExamScores['A1'], 82);
      expect(state.savedItems.single.lessonId, 'a2-u08-l01');
      expect(storage.courseProgress.unitQuizScores['a2-u08'], 70);
    },
  );
}
