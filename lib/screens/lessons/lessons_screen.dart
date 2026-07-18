import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/content_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../learning/course_learning_screen.dart';
import '../quiz/unit_quiz_screen.dart';
import '../exam/exam_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({this.showBack = false, this.level, super.key});
  final bool showBack;
  final CourseLevel? level;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  int _selectedUnit = 0;
  late final Future<List<CourseUnit>> _units;

  @override
  void initState() {
    super.initState();
    final repository = CefrContentRepository();
    _units = widget.level == null
        ? Future.wait([
            repository.loadUnit('assets/content/a1/unit_01.json'),
            repository.loadUnit('assets/content/a1/unit_02.json'),
            repository.loadUnit('assets/content/a1/unit_03.json'),
            repository.loadUnit('assets/content/a1/unit_04.json'),
            repository.loadUnit('assets/content/a1/unit_05.json'),
            repository.loadUnit('assets/content/a1/unit_06.json'),
            repository.loadUnit('assets/content/a1/unit_07.json'),
            repository.loadUnit('assets/content/a1/unit_08.json'),
            repository.loadUnit('assets/content/a1/unit_09.json'),
            repository.loadUnit('assets/content/a1/unit_10.json'),
            repository.loadUnit('assets/content/a1/final_review.json'),
          ])
        : repository.loadAvailableUnits(widget.level!);
  }

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
            if (widget.level?.id == 'A2')
              _A2UnitSelector(
                selectedUnit: _selectedUnit,
                availableUnits: units,
                plannedUnitCount: widget.level!.unitFiles.length,
                onSelected: (value) => setState(() => _selectedUnit = value),
              )
            else
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
            appBar: AppBar(title: Text(widget.level?.title ?? 'A1 – Beginner')),
            body: content,
          )
        : SafeArea(child: content);
  }
}

class _A2UnitSelector extends StatelessWidget {
  const _A2UnitSelector({
    required this.selectedUnit,
    required this.availableUnits,
    required this.plannedUnitCount,
    required this.onSelected,
  });

  final int selectedUnit;
  final List<CourseUnit> availableUnits;
  final int plannedUnitCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(plannedUnitCount, (index) {
            final unitNumber = index + 1;
            final hasContent = index < availableUnits.length;
            final unlocked =
                index == 0 ||
                (index - 1 < availableUnits.length &&
                    state.hasPassedUnit(availableUnits[index - 1].id));
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('Unit $unitNumber'),
                selected: hasContent && selectedUnit == index,
                avatar: Icon(
                  unlocked
                      ? (hasContent
                            ? Icons.lock_open_outlined
                            : Icons.schedule_outlined)
                      : Icons.lock_outline,
                  size: 18,
                ),
                onSelected: (_) {
                  if (!unlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gudub Unit ${unitNumber - 1} quiz si Unit $unitNumber u furmo.',
                        ),
                      ),
                    );
                  } else if (!hasContent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Casharrada unit-kan waa coming soon.'),
                      ),
                    );
                  } else {
                    onSelected(index);
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
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
    final unitSevenUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u06');
    final unitEightUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u07');
    final unitNineUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u08');
    final unitTenUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u09');
    final finalReviewUnlocked =
        AppProvider.unlockA1DuringDevelopment || state.hasPassedUnit('a1-u10');
    final finalExamUnlocked = state.hasCompletedFinalReview;
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
              selected: selectedUnit == 5,
              avatar: Icon(
                unitSixUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitSixUnlocked) {
                  onSelected(5);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 5 quiz si Unit 6 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 7'),
              selected: selectedUnit == 6,
              avatar: Icon(
                unitSevenUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitSevenUnlocked) {
                  onSelected(6);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 6 quiz si Unit 7 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 8'),
              selected: selectedUnit == 7,
              avatar: Icon(
                unitEightUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitEightUnlocked) {
                  onSelected(7);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 7 quiz si Unit 8 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 9'),
              selected: selectedUnit == 8,
              avatar: Icon(
                unitNineUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitNineUnlocked) {
                  onSelected(8);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 8 quiz si Unit 9 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Unit 10'),
              selected: selectedUnit == 9,
              avatar: Icon(
                unitTenUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (unitTenUnlocked) {
                  onSelected(9);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gudub Unit 9 quiz si Unit 10 u furmo.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Final Review'),
              selected: selectedUnit == 10,
              avatar: Icon(
                finalReviewUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (finalReviewUnlocked) {
                  onSelected(10);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gudub Unit 10 quiz si Final Review u furmo.',
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Final Exam'),
              selected: false,
              avatar: Icon(
                finalExamUnlocked
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 18,
              ),
              onSelected: (_) {
                if (finalExamUnlocked) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExamScreen(standalone: true),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Dhammaystir Final Review iyo Mixed Practice si Final Exam u furmo.',
                      ),
                    ),
                  );
                }
              },
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
    final developmentUnlocked =
        unit.levelId == 'A1' && AppProvider.unlockA1DuringDevelopment;
    final unitUnlocked =
        developmentUnlocked ||
        unit.requiredPreviousUnitId == null ||
        state.hasPassedUnit(unit.requiredPreviousUnitId!);
    final allLessonsComplete = unit.lessons.every(
      (item) => completed.contains(item.id),
    );
    final passed = unit.id == 'a1-final-review'
        ? state.hasCompletedFinalReview
        : state.hasPassedUnit(unit.id);
    final quizUnlocked = developmentUnlocked || allLessonsComplete;
    final nextUnitUnlocked = developmentUnlocked || passed;
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
              state.isCourseLessonUnlocked(
                lesson.requiredPreviousLessonId,
                levelId: lesson.levelId,
              );
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
