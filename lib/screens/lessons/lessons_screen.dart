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
  late final Future<CourseUnit> _unit = CefrContentRepository().loadUnit(
    'assets/content/a1/unit_01.json',
  );

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<CourseUnit>(
      future: _unit,
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
        return _UnitContent(unit: snapshot.data!);
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

class _UnitContent extends StatelessWidget {
  const _UnitContent({required this.unit});
  final CourseUnit unit;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final completed = state.courseProgress.completedLessonIds;
    final allLessonsComplete = unit.lessons.every(
      (item) => completed.contains(item.id),
    );
    final passed = state.hasPassedUnit(unit.id);
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
          final unlocked = state.isCourseLessonUnlocked(
            lesson.requiredPreviousLessonId,
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
          onTap: allLessonsComplete
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
              allLessonsComplete
                  ? '15 su’aalood • Gudub 70% • Best $bestScore%'
                  : 'Dhammaystir 6-da cashar si quiz-ku u furmo',
            ),
            trailing: Icon(
              allLessonsComplete ? Icons.chevron_right : Icons.lock_outline,
            ),
          ),
        ),
        AppCard(
          onTap: passed
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unit 2 content-ka waxaa lagu dari doonaa tallaabada xigta.',
                    ),
                  ),
                )
              : () => _lockedMessage(context),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Text('2')),
            title: const Text(
              'Unit 2',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              passed
                  ? 'Unlocked • Content coming next'
                  : 'Locked • Gudub Unit 1 quiz',
            ),
            trailing: Icon(
              passed ? Icons.lock_open_outlined : Icons.lock_outline,
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
