import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/models/content/content_models.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:ifiye_english/screens/quiz/unit_quiz_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Final Review quiz flow completes and persists 100%', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);
    const representativeReview = CourseUnit(
      id: 'a1-final-review',
      levelId: 'A1',
      unitNumber: 11,
      titleEnglish: 'A1 Final Review',
      titleSomali: 'Dib-u-eegista Guud ee Heerka A1',
      introductionSomali: 'Final Review flow test.',
      requiredPreviousUnitId: 'a1-u10',
      lessons: [],
      unitQuiz: [
        PracticeExercise(
          id: 'a1-fr-widget-q01',
          type: ExerciseType.multipleChoice,
          question: 'Hospital maxay ka dhigan tahay?',
          options: ['isbitaal', 'suuq', 'guri', 'quraac'],
          correctAnswer: 'isbitaal',
          explanationSomali: 'Hospital waa isbitaal.',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: UnitQuizScreen(unit: representativeReview)),
      ),
    );
    await tester.pump();

    expect(find.text('Su’aal 1 / 1'), findsOneWidget);
    const answer = 'isbitaal';
    await tester.tap(find.widgetWithText(OutlinedButton, answer).first);
    await tester.pump();
    expect(find.textContaining('Sax!'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(find.text('Final Review waa la dhammaystiray!'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(state.hasCompletedFinalReview, isTrue);
    expect(state.courseProgress.unitQuizScores['a1-final-review'], 100);
    expect(
      storage.courseProgress.completedLessonIds,
      contains(AppProvider.finalReviewCompletionId),
    );
  });
}
