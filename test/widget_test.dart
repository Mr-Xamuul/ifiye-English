import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/models/content/course_progress.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('course progress and exam defaults are safe', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);

    expect(state.courseProgress.completedLessonIds, isEmpty);
    expect(state.bestScore, 0);
    expect(state.isCourseLessonUnlocked('lesson-not-completed'), isTrue);
  });

  test('versioned course progress is saved locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    const progress = CourseProgress(
      completedLessonIds: {'a1-u01-l01'},
      lessonQuizScores: {'a1-u01-l01': 80},
      unitQuizScores: {'a1-u01': 75},
      finalExamScores: {'A1': 76},
    );

    await storage.saveCourseProgress(progress);
    final restored = storage.courseProgress;

    expect(restored.completedLessonIds, contains('a1-u01-l01'));
    expect(restored.hasPassedLessonQuiz('a1-u01-l01'), isTrue);
    expect(restored.hasPassedUnitQuiz('a1-u01'), isTrue);
    expect(restored.hasPassedFinalExam('A1'), isTrue);
  });

  test('unit pass is persisted and unlocks the next unit', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);

    await state.completeCourseLesson('a1-u01-l01');
    await state.recordUnitQuizScore('a1-u01', 73);

    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));
    expect(state.hasPassedUnit('a1-u01'), isTrue);
    expect(storage.courseProgress.hasPassedUnitQuiz('a1-u01'), isTrue);

    await state.recordUnitQuizScore('a1-u02', 69);
    expect(state.hasPassedUnit('a1-u02'), isFalse);
    expect(state.hasPassedUnit('a1-u01'), isTrue);

    await state.recordUnitQuizScore('a1-u02', 70);
    expect(state.hasPassedUnit('a1-u02'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u03', 69);
    expect(state.hasPassedUnit('a1-u03'), isFalse);
    expect(state.hasPassedUnit('a1-u02'), isTrue);

    await state.recordUnitQuizScore('a1-u03', 70);
    expect(state.hasPassedUnit('a1-u03'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u04', 69);
    expect(state.hasPassedUnit('a1-u04'), isFalse);
    expect(state.hasPassedUnit('a1-u03'), isTrue);

    await state.recordUnitQuizScore('a1-u04', 70);
    expect(state.hasPassedUnit('a1-u04'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u05', 69);
    expect(state.hasPassedUnit('a1-u05'), isFalse);
    expect(state.hasPassedUnit('a1-u04'), isTrue);

    await state.recordUnitQuizScore('a1-u05', 70);
    expect(state.hasPassedUnit('a1-u05'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u06', 69);
    expect(state.hasPassedUnit('a1-u06'), isFalse);
    expect(state.hasPassedUnit('a1-u05'), isTrue);

    await state.recordUnitQuizScore('a1-u06', 70);
    expect(state.hasPassedUnit('a1-u06'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u07', 69);
    expect(state.hasPassedUnit('a1-u07'), isFalse);
    expect(state.hasPassedUnit('a1-u06'), isTrue);

    await state.recordUnitQuizScore('a1-u07', 70);
    expect(state.hasPassedUnit('a1-u07'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u08', 69);
    expect(state.hasPassedUnit('a1-u08'), isFalse);
    expect(state.hasPassedUnit('a1-u07'), isTrue);

    await state.recordUnitQuizScore('a1-u08', 70);
    expect(state.hasPassedUnit('a1-u08'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u09', 69);
    expect(state.hasPassedUnit('a1-u09'), isFalse);
    expect(state.hasPassedUnit('a1-u08'), isTrue);

    await state.recordUnitQuizScore('a1-u09', 70);
    expect(state.hasPassedUnit('a1-u09'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));

    await state.recordUnitQuizScore('a1-u10', 69);
    expect(state.hasPassedUnit('a1-u10'), isFalse);
    expect(state.hasPassedUnit('a1-u09'), isTrue);

    await state.recordUnitQuizScore('a1-u10', 70);
    expect(state.hasPassedUnit('a1-u10'), isTrue);
    expect(state.courseProgress.completedLessonIds, contains('a1-u01-l01'));
  });
}
