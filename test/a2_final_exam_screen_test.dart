import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/data/repositories/cefr_content_repository.dart';
import 'package:ifiye_english/models/content/final_exam_models.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:ifiye_english/screens/exam/exam_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppProvider> createState() async {
    SharedPreferences.setMockInitialValues({});
    return AppProvider(await LocalStorageService.create());
  }

  Future<FinalExamContent> loadExam() => CefrContentRepository(
    bundle: rootBundle,
  ).loadFinalExam('assets/content/a2/final_exam.json');

  Widget app(AppProvider state, FinalExamContent exam) =>
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          home: ExamScreen(standalone: true, levelId: 'A2', examContent: exam),
        ),
      );

  void useTallTestScreen(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.reset);
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Widget was not found after waiting: $finder');
  }

  testWidgets('A2 Final Exam is locked before Final Review completion', (
    tester,
  ) async {
    useTallTestScreen(tester);
    final state = await createState();
    final exam = await tester.runAsync(loadExam);
    await tester.pumpWidget(app(state, exam!));
    await pumpUntilFound(tester, find.text('70%'));

    expect(find.text('A2 Final Exam'), findsWidgets);
    expect(find.text('70%'), findsOneWidget);
    expect(
      find.text('Marka hore dhammaystir A2 Final Review.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Bilow imtixaanka'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('A2 answers persist across Next and Previous', (tester) async {
    useTallTestScreen(tester);
    final state = await createState();
    await state.completeLevelFinalReview('A2', 65);
    final exam = await tester.runAsync(loadExam);
    await tester.pumpWidget(app(state, exam!));
    await pumpUntilFound(tester, find.byType(FilledButton));

    // Helps diagnose asset-loading failures without depending on animations.
    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .join(' | ');
    expect(visibleText, isNot(contains('content-ka lama furin')));
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await pumpUntilFound(tester, find.textContaining('1 / 100'));
    expect(find.textContaining('1 / 100'), findsOneWidget);

    final optionButtons = find.byType(OutlinedButton);
    expect(optionButtons, findsAtLeastNWidgets(5));
    await tester.tap(optionButtons.first);
    await tester.pump();
    expect(state.a2FinalExamProgress.answers, hasLength(1));

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    expect(find.textContaining('2 / 100'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Previous'));
    await tester.pump();
    expect(find.textContaining('1 / 100'), findsOneWidget);
    expect(state.a2FinalExamProgress.answers, hasLength(1));
    expect(state.a2FinalExamProgress.questionIds, hasLength(100));
  });
}
