import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifiye_english/core/storage/local_storage_service.dart';
import 'package:ifiye_english/providers/app_provider.dart';
import 'package:ifiye_english/screens/home/home_screen.dart';
import 'package:ifiye_english/screens/lessons/lessons_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home and Learn screens display real A1 Unit 1 content', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final state = AppProvider(storage);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('Alphabet and Basic Sounds'), findsOneWidget);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: Scaffold(body: LessonsScreen())),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('Alphabet and Basic Sounds'), findsOneWidget);
    expect(find.text('The English Alphabet'), findsOneWidget);

    await state.recordUnitQuizScore('a1-u01', 70);
    await tester.pump();
    await tester.tap(find.text('Unit 2'));
    await tester.pump();

    expect(find.text('Greetings and Introductions'), findsOneWidget);
    expect(find.text('Basic Greetings'), findsOneWidget);

    await state.recordUnitQuizScore('a1-u02', 70);
    await tester.pump();
    await tester.tap(find.text('Unit 3'));
    await tester.pump();

    expect(find.text('Numbers and Personal Information'), findsOneWidget);
    expect(find.text('Numbers 0–20'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unit 4'));
    await tester.pump();

    expect(find.text('Family and People'), findsOneWidget);
    expect(find.text('Family Members'), findsOneWidget);

    final unitFiveChip = find.widgetWithText(ChoiceChip, 'Unit 5');
    expect(
      find.descendant(
        of: unitFiveChip,
        matching: find.byIcon(Icons.lock_open_outlined),
      ),
      findsOneWidget,
    );
    expect(state.hasPassedUnit('a1-u04'), isFalse);

    await tester.ensureVisible(unitFiveChip);
    await tester.pump();
    await tester.tap(unitFiveChip);
    await tester.pump();

    expect(find.text('Daily Activities and Routines'), findsOneWidget);
    expect(find.text('Morning Activities'), findsOneWidget);

    final unitSixChip = find.widgetWithText(ChoiceChip, 'Unit 6');
    expect(
      find.descendant(
        of: unitSixChip,
        matching: find.byIcon(Icons.lock_open_outlined),
      ),
      findsOneWidget,
    );
    expect(state.hasPassedUnit('a1-u05'), isFalse);

    await tester.ensureVisible(unitSixChip);
    await tester.pump();
    await tester.tap(unitSixChip);
    await tester.pump();

    expect(find.text('Time, Days and Months'), findsOneWidget);
    expect(find.text('Asking and Telling the Time'), findsOneWidget);

    final unitSevenChip = find.widgetWithText(ChoiceChip, 'Unit 7');
    expect(
      find.descendant(
        of: unitSevenChip,
        matching: find.byIcon(Icons.lock_open_outlined),
      ),
      findsOneWidget,
    );
    expect(state.hasPassedUnit('a1-u06'), isFalse);

    await tester.ensureVisible(unitSevenChip);
    await tester.pump();
    await tester.tap(unitSevenChip);
    await tester.pump();

    expect(find.text('Food and Drinks'), findsOneWidget);
    expect(find.text('Common Foods'), findsOneWidget);

    final unitEightChip = find.widgetWithText(ChoiceChip, 'Unit 8');
    expect(
      find.descendant(
        of: unitEightChip,
        matching: find.byIcon(Icons.lock_open_outlined),
      ),
      findsOneWidget,
    );
    expect(state.hasPassedUnit('a1-u07'), isFalse);

    await tester.ensureVisible(unitEightChip);
    await tester.pump();
    await tester.tap(unitEightChip);
    await tester.pump();

    expect(find.text('Home and Objects'), findsOneWidget);
    expect(find.text('Types of Homes'), findsOneWidget);

    final unitNineChip = find.widgetWithText(ChoiceChip, 'Unit 9');
    expect(
      find.descendant(
        of: unitNineChip,
        matching: find.byIcon(Icons.lock_outline),
      ),
      findsOneWidget,
    );
    expect(state.hasPassedUnit('a1-u08'), isFalse);
  });
}
