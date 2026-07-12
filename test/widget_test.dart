import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/models/content/course_progress.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('progress and exam defaults are safe', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);

    expect(state.progress, 0);
    expect(state.bestScore, 0);
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
}
