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
}
