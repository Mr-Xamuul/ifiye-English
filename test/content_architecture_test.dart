import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/validation/content_validator.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog loads six valid CEFR level definitions', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();

    final levels = await repository.loadLevels();

    expect(levels.map((level) => level.id), [
      'A1',
      'A2',
      'B1',
      'B2',
      'C1',
      'C2',
    ]);
    for (final level in levels) {
      expect(validator.validateLevel(level).errors, isEmpty);
    }
  });

  test('A1 Unit 1 has complete lessons, review, and unit quiz', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();

    final unit = await repository.loadUnit('assets/content/a1/unit_01.json');
    final result = validator.validateUnit(unit);

    expect(result.errors, isEmpty);
    expect(unit.lessons, hasLength(6));
    expect(unit.lessons.last.lessonType.name, 'review');
    expect(
      unit.lessons.every((lesson) => lesson.practiceExercises.length >= 8),
      isTrue,
    );
    expect(unit.unitQuiz, hasLength(15));
  });

  test('A1 Unit 2 is complete, valid, and references Unit 1', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final unitOne = await repository.loadUnit('assets/content/a1/unit_01.json');
    final unitTwo = await repository.loadUnit('assets/content/a1/unit_02.json');

    expect(validator.validateUnit(unitTwo).errors, isEmpty);
    expect(unitTwo.requiredPreviousUnitId, 'a1-u01');
    expect(unitTwo.lessons, hasLength(8));
    expect(unitTwo.lessons.last.lessonType.name, 'review');
    expect(unitTwo.lessons.last.practiceExercises, hasLength(15));
    expect(unitTwo.unitQuiz, hasLength(20));
    expect(
      unitTwo.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitTwo.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(64),
    );
    expect(
      unitTwo.lessons.expand((lesson) => lesson.practiceExercises).length,
      85,
    );

    final lessonIds = {
      ...unitOne.lessons.map((lesson) => lesson.id),
      ...unitTwo.lessons.map((lesson) => lesson.id),
    };
    expect(lessonIds, hasLength(14));
    for (var index = 1; index < unitTwo.lessons.length; index++) {
      expect(
        unitTwo.lessons[index].requiredPreviousLessonId,
        unitTwo.lessons[index - 1].id,
      );
    }
  });

  test('A1 Unit 3 is complete, valid, and references Unit 2', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final units = await Future.wait([
      repository.loadUnit('assets/content/a1/unit_01.json'),
      repository.loadUnit('assets/content/a1/unit_02.json'),
      repository.loadUnit('assets/content/a1/unit_03.json'),
    ]);
    final unitThree = units.last;

    expect(validator.validateUnit(unitThree).errors, isEmpty);
    expect(unitThree.requiredPreviousUnitId, 'a1-u02');
    expect(unitThree.lessons, hasLength(9));
    expect(unitThree.lessons.last.lessonType.name, 'review');
    expect(unitThree.lessons.last.practiceExercises, hasLength(20));
    expect(unitThree.unitQuiz, hasLength(25));
    expect(
      unitThree.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitThree.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(112),
    );
    expect(
      unitThree.lessons.expand((lesson) => lesson.practiceExercises).length,
      100,
    );

    final allIds = <String>[
      for (final unit in units) ...[
        unit.id,
        ...unit.lessons.map((lesson) => lesson.id),
      ],
      for (final lesson in unitThree.lessons) ...[
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
      ],
      ...unitThree.unitQuiz.map((item) => item.id),
    ];
    expect(allIds.toSet(), hasLength(allIds.length));
    for (var index = 1; index < unitThree.lessons.length; index++) {
      expect(
        unitThree.lessons[index].requiredPreviousLessonId,
        unitThree.lessons[index - 1].id,
      );
    }
  });

  test('A1 Unit 4 is complete, valid, and references Unit 3', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final units = await Future.wait([
      repository.loadUnit('assets/content/a1/unit_01.json'),
      repository.loadUnit('assets/content/a1/unit_02.json'),
      repository.loadUnit('assets/content/a1/unit_03.json'),
      repository.loadUnit('assets/content/a1/unit_04.json'),
    ]);
    final unitFour = units.last;

    expect(validator.validateUnit(unitFour).errors, isEmpty);
    expect(unitFour.requiredPreviousUnitId, 'a1-u03');
    expect(unitFour.lessons, hasLength(10));
    expect(unitFour.lessons.last.lessonType.name, 'review');
    expect(unitFour.lessons.last.practiceExercises, hasLength(20));
    expect(unitFour.unitQuiz, hasLength(25));
    expect(
      unitFour.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitFour.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(104),
    );
    expect(
      unitFour.lessons.expand((lesson) => lesson.practiceExercises).length,
      110,
    );

    final allIds = <String>[
      for (final unit in units) ...[
        unit.id,
        ...unit.lessons.map((lesson) => lesson.id),
      ],
      for (final lesson in unitFour.lessons) ...[
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
      ],
      ...unitFour.unitQuiz.map((item) => item.id),
    ];
    expect(allIds.toSet(), hasLength(allIds.length));
    for (var index = 1; index < unitFour.lessons.length; index++) {
      expect(
        unitFour.lessons[index].requiredPreviousLessonId,
        unitFour.lessons[index - 1].id,
      );
    }
  });

  test('A1 Unit 5 is complete, valid, and references Unit 4', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final units = await Future.wait([
      repository.loadUnit('assets/content/a1/unit_01.json'),
      repository.loadUnit('assets/content/a1/unit_02.json'),
      repository.loadUnit('assets/content/a1/unit_03.json'),
      repository.loadUnit('assets/content/a1/unit_04.json'),
      repository.loadUnit('assets/content/a1/unit_05.json'),
    ]);
    final unitFive = units.last;

    expect(validator.validateUnit(unitFive).errors, isEmpty);
    expect(unitFive.requiredPreviousUnitId, 'a1-u04');
    expect(unitFive.lessons, hasLength(12));
    expect(unitFive.lessons.last.lessonType.name, 'review');
    expect(unitFive.lessons.last.practiceExercises, hasLength(25));
    expect(unitFive.unitQuiz, hasLength(30));
    expect(
      unitFive.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitFive.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(135),
    );
    expect(
      unitFive.lessons.expand((lesson) => lesson.practiceExercises).length,
      157,
    );
    expect(
      unitFive.lessons
          .where((lesson) => lesson.grammar != null)
          .every((lesson) => lesson.grammar!.positiveExamples.length >= 6),
      isTrue,
    );

    final allIds = <String>[
      for (final unit in units) ...[
        unit.id,
        ...unit.lessons.map((lesson) => lesson.id),
      ],
      for (final lesson in unitFive.lessons) ...[
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
      ],
      ...unitFive.unitQuiz.map((item) => item.id),
    ];
    expect(allIds.toSet(), hasLength(allIds.length));
    for (var index = 1; index < unitFive.lessons.length; index++) {
      expect(
        unitFive.lessons[index].requiredPreviousLessonId,
        unitFive.lessons[index - 1].id,
      );
    }
  });

  test('A1 Unit 6 is complete, valid, and references Unit 5', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final units = await Future.wait([
      repository.loadUnit('assets/content/a1/unit_01.json'),
      repository.loadUnit('assets/content/a1/unit_02.json'),
      repository.loadUnit('assets/content/a1/unit_03.json'),
      repository.loadUnit('assets/content/a1/unit_04.json'),
      repository.loadUnit('assets/content/a1/unit_05.json'),
      repository.loadUnit('assets/content/a1/unit_06.json'),
    ]);
    final unitSix = units.last;

    expect(validator.validateUnit(unitSix).errors, isEmpty);
    expect(unitSix.requiredPreviousUnitId, 'a1-u05');
    expect(unitSix.lessons, hasLength(13));
    expect(unitSix.lessons.last.lessonType.name, 'review');
    expect(unitSix.lessons.last.practiceExercises, hasLength(25));
    expect(unitSix.unitQuiz, hasLength(30));
    expect(
      unitSix.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitSix.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(142),
    );
    expect(
      unitSix.lessons.expand((lesson) => lesson.practiceExercises).length,
      181,
    );
    expect(unitSix.lessons.expand((lesson) => lesson.quizQuestions).length, 39);
    expect(
      unitSix.lessons
          .where((lesson) => lesson.grammar != null)
          .every((lesson) => lesson.grammar!.positiveExamples.length >= 6),
      isTrue,
    );

    final allIds = <String>[
      for (final unit in units) ...[
        unit.id,
        ...unit.lessons.map((lesson) => lesson.id),
      ],
      for (final lesson in unitSix.lessons) ...[
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
      ],
      ...unitSix.unitQuiz.map((item) => item.id),
    ];
    expect(allIds.toSet(), hasLength(allIds.length));
    for (var index = 1; index < unitSix.lessons.length; index++) {
      expect(
        unitSix.lessons[index].requiredPreviousLessonId,
        unitSix.lessons[index - 1].id,
      );
    }
  });

  test('A1 Unit 7 is complete, valid, and references Unit 6', () async {
    final repository = CefrContentRepository(bundle: rootBundle);
    final validator = const ContentValidator();
    final units = await Future.wait([
      repository.loadUnit('assets/content/a1/unit_01.json'),
      repository.loadUnit('assets/content/a1/unit_02.json'),
      repository.loadUnit('assets/content/a1/unit_03.json'),
      repository.loadUnit('assets/content/a1/unit_04.json'),
      repository.loadUnit('assets/content/a1/unit_05.json'),
      repository.loadUnit('assets/content/a1/unit_06.json'),
      repository.loadUnit('assets/content/a1/unit_07.json'),
    ]);
    final unitSeven = units.last;

    expect(validator.validateUnit(unitSeven).errors, isEmpty);
    expect(unitSeven.requiredPreviousUnitId, 'a1-u06');
    expect(unitSeven.lessons, hasLength(15));
    expect(unitSeven.lessons.last.lessonType.name, 'review');
    expect(unitSeven.lessons.last.practiceExercises, hasLength(30));
    expect(unitSeven.unitQuiz, hasLength(35));
    expect(
      unitSeven.lessons.every((lesson) => lesson.dialogues.length >= 2),
      isTrue,
    );
    expect(
      unitSeven.lessons.expand((lesson) => lesson.vocabulary),
      hasLength(159),
    );
    expect(
      unitSeven.lessons.expand((lesson) => lesson.practiceExercises).length,
      226,
    );
    expect(
      unitSeven.lessons.expand((lesson) => lesson.quizQuestions).length,
      45,
    );
    expect(
      unitSeven.lessons
          .where((lesson) => lesson.grammar != null)
          .every((lesson) => lesson.grammar!.positiveExamples.length >= 6),
      isTrue,
    );

    final allIds = <String>[
      for (final unit in units) ...[
        unit.id,
        ...unit.lessons.map((lesson) => lesson.id),
      ],
      for (final lesson in unitSeven.lessons) ...[
        ...lesson.practiceExercises.map((item) => item.id),
        ...lesson.quizQuestions.map((item) => item.id),
      ],
      ...unitSeven.unitQuiz.map((item) => item.id),
    ];
    expect(allIds.toSet(), hasLength(allIds.length));
    for (var index = 1; index < unitSeven.lessons.length; index++) {
      expect(
        unitSeven.lessons[index].requiredPreviousLessonId,
        unitSeven.lessons[index - 1].id,
      );
    }
  });
}
