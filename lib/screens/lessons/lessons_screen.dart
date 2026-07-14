import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/content_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../learning/course_learning_screen.dart';
import '../quiz/unit_quiz_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({this.showBack = false, super.key});
  final bool showBack;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  int _selectedUnit = 0;
  late final Future<List<CourseUnit>> _units = Future.wait([
    CefrContentRepository().loadUnit('assets/content/a1/unit_01.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_02.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_03.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_04.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_05.json'),
  ]);

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<CourseUnit>>(
      future: _units,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Casharrada lama furin. Fadlan mar kale isku day.',
          );
        }
        final units = snapshot.data!;
        return Column(
          children: [
            _UnitSelector(
              selectedUnit: _selectedUnit,
              onSelected: (value) => setState(() => _selectedUnit = value),
            ),
            Expanded(
              child: _UnitContent(
                unit: units[_selectedUnit],
                onOpenNextUnit: _selectedUnit < units.length - 1
                    ? () => setState(() => _selectedUnit += 1)
                    : null,
              ),
            ),
          ],
        );
      },
    );
    return widget.showBack
        ? Scaffold(
            appBar: AppBar(title: const Text('A1 – Beginner')),
            body: content,
          )
        : SafeArea(child: content);
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.selectedUnit, required this.onSelected});
  final int selectedUnit;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final unitTwoUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u01');
    final unitThreeUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u02');
    final unitFourUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u03');
    final unitFiveUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u04');
    final unitSixUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u05');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Unit 1'),
              selected: selectedUnit == 0,
              onSelected: (_) => onSelected(0),
              avatar: const Icon(Icons.looks_one_outlined, size: 18),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 2'),
              selected: selectedUnit == 1,
              avatar: Icon(
                unitTwoUnlocked ? Icons.looks_two_outlined : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitTwoUnlocked) {
                  onSelected(1);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 1 quiz si Unit 2 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 3'),
              selected: selectedUnit == 2,
              avatar: Icon(
                unitThreeUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitThreeUnlocked) {
                  onSelected(2);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 2 quiz si Unit 3 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 4'),
              selected: selectedUnit == 3,
              avatar: Icon(
                unitFourUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitFourUnlocked) {
                  onSelected(3);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 3 quiz si Unit 4 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 5'),
              selected: selectedUnit == 4,
              avatar: Icon(
                unitFiveUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitFiveUnlocked) {
                  onSelected(4);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 4 quiz si Unit 5 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 6'),
              selected: false,
              avatar: Icon(
                unitSixUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    unitSixUnlocked
                        ? 'Unit 6 waa furmay; content-kiisu coming soon ayuu yahay.'
                        : 'Gudub Unit 5 quiz si Unit 6 u furmo.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitContent extends StatelessWidget {
  const _UnitContent({required this.unit, this.onOpenNextUnit});
  final CourseUnit unit;
  final VoidCallback? onOpenNextUnit;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final completed = state.courseProgress.completedLessonIds;
    final unitUnlocked =
        AppProvider.unlockA1DuringDevelopment ||
        unit.requiredPreviousUnitId == null ||
        state.hasPassedUnit(unit.requiredPreviousUnitId!);
    final allLessonsComplete = unit.lessons.every(
      (item) => completed.contains(item.id),
    );
    final passed = state.hasPassedUnit(unit.id);
    final quizUnlocked =
        AppProvider.unlockA1DuringDevelopment || allLessonsComplete;
    final nextUnitUnlocked = AppProvider.unlockA1DuringDevelopment || passed;
    final bestScore = state.courseProgress.unitQuizScores[unit.id] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          unit.titleEnglish,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          unit.titleSomali,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unit.introductionSomali,
          style: const TextStyle(color: Colors.grey, height: 1.45),
        ),
        const SizedBox(height: 16),
        ...unit.lessons.map((lesson) {
          final unlocked =
              unitUnlocked &&
              state.isCourseLessonUnlocked(lesson.requiredPreviousLessonId);
          final isComplete = completed.contains(lesson.id);
          return AppCard(
            onTap: unlocked
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseLearningScreen(lesson: lesson),
                    ),
                  )
                : () => _lockedMessage(context),
            child: Row(
              children: [
                CircleAvatar(
                  child: isComplete
                      ? const Icon(Icons.check)
                      : Text('${lesson.lessonNumber}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.titleEnglish,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        lesson.titleSomali,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${lesson.estimatedMinutes} daqiiqo • ${lesson.lessonType.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(unlocked ? Icons.chevron_right : Icons.lock_outline),
              ],
            ),
          );
        }),
        AppCard(
          onTap: quizUnlocked
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UnitQuizScreen(unit: unit)),
                )
              : () => _lockedMessage(context),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(passed ? Icons.verified : Icons.quiz_outlined),
            ),
            title: const Text(
              'Unit Quiz',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              quizUnlocked
                  ? '${unit.unitQuiz.length} su’aalood • Gudub 70% • Best $bestScore%'
                  : 'Dhammaystir ${unit.lessons.length}-da cashar si quiz-ku u furmo',
            ),
            trailing: Icon(
              quizUnlocked ? Icons.chevron_right : Icons.lock_outline,
            ),
          ),
        ),
        AppCard(
          onTap: nextUnitUnlocked
              ? onOpenNextUnit ??
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unit-ka xiga content-kiisu coming soon ayuu yahay.',
                        ),
                      ),
                    )
              : () => _lockedMessage(context),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${unit.unitNumber + 1}')),
            title: Text(
              'Unit ${unit.unitNumber + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              nextUnitUnlocked
                  ? (onOpenNextUnit == null
                        ? 'Unlocked • Content coming next'
                        : 'Unlocked • Fur casharrada')
                  : 'Locked • Gudub Unit ${unit.unitNumber} quiz',
            ),
            trailing: Icon(
              nextUnitUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
            ),
          ),
        ),
      ],
    );
  }

  void _lockedMessage(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marka hore dhammaystir qaybta kaa horreysa.'),
        ),
      );
}
