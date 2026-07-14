import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/content_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../learning/course_learning_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/unit_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<CourseUnit>> _units = Future.wait([
    CefrContentRepository().loadUnit('assets/content/a1/unit_01.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_02.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_03.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_04.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_05.json'),
    CefrContentRepository().loadUnit('assets/content/a1/unit_06.json'),
  ]);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FutureBuilder<List<CourseUnit>>(
      future: _units,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Xogta waxbarashada lama furin. Fadlan app-ka dib u fur.',
          );
        }
        return _Dashboard(units: snapshot.data!);
      },
    ),
  );
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.units});
  final List<CourseUnit> units;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final unit = state.hasPassedUnit('a1-u05')
        ? units[5]
        : state.hasPassedUnit('a1-u04')
        ? units[4]
        : state.hasPassedUnit('a1-u03')
        ? units[3]
        : state.hasPassedUnit('a1-u02')
        ? units[2]
        : state.hasPassedUnit('a1-u01')
        ? units[1]
        : units[0];
    final completedIds = state.courseProgress.completedLessonIds;
    final completedCount = unit.lessons
        .where((lesson) => completedIds.contains(lesson.id))
        .length;
    final totalLessons = units.fold<int>(
      0,
      (total, item) => total + item.lessons.length,
    );
    final totalCompleted = units
        .expand((item) => item.lessons)
        .where((lesson) => completedIds.contains(lesson.id))
        .length;
    final progress = totalCompleted / totalLessons;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              borderRadius: BorderRadius.circular(30),
              child: const CircleAvatar(child: Icon(Icons.person)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salaan, Arday!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Aan maanta tallaabo kale qaadno',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weli ogeysiis cusub ma jiro.')),
              ),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Heerkaaga hadda',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                const Text(
                  'A1 • Beginner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unit.titleEnglish,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text(
                  'A1: $totalCompleted ka mid ah $totalLessons cashar • Unit ${unit.unitNumber}: $completedCount/${unit.lessons.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                FilledButton.tonal(
                  onPressed: () => _openNext(context, state, unit),
                  child: Text(
                    completedCount == unit.lessons.length
                        ? 'Qaado Unit Quiz'
                        : 'Sii wad barashada',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('Hadafka maanta'),
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: _Stat(
                  icon: Icons.schedule,
                  title: '${state.dailyGoal} daqiiqo',
                  subtitle: 'Hadaf maalinle',
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: AppCard(
                child: _Stat(
                  icon: Icons.local_fire_department,
                  title: '3 maalmood',
                  subtitle: 'Xiriir ah',
                ),
              ),
            ),
          ],
        ),
        const SectionTitle('Ficillo degdeg ah'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: [
            _Action(
              Icons.play_circle_outline,
              'Sii wad casharka',
              () => _openNext(context, state, unit),
            ),
            _Action(
              Icons.bookmark_outline,
              'Erayada la keydiyay',
              () => state.setNavIndex(3),
            ),
            _Action(
              Icons.quiz_outlined,
              'Unit Quiz',
              () => _openQuiz(context, state, unit),
            ),
            _Action(
              Icons.layers_outlined,
              'Eeg levels-ka',
              () => state.setNavIndex(1),
            ),
          ],
        ),
        SectionTitle('Casharrada A1 Unit ${unit.unitNumber}'),
        ...unit.lessons.take(3).map((lesson) {
          final complete = completedIds.contains(lesson.id);
          final unlocked = state.isCourseLessonUnlocked(
            lesson.requiredPreviousLessonId,
          );
          return AppCard(
            onTap: unlocked
                ? () => _openLesson(context, lesson)
                : () => _lockedMessage(context),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: complete
                    ? const Icon(Icons.check)
                    : Text('${lesson.lessonNumber}'),
              ),
              title: Text(
                lesson.titleEnglish,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(lesson.titleSomali),
              trailing: Icon(
                complete
                    ? Icons.check_circle
                    : (unlocked ? Icons.chevron_right : Icons.lock_outline),
                color: complete ? Colors.green : null,
              ),
            ),
          );
        }),
      ],
    );
  }

  void _openNext(BuildContext context, AppProvider state, CourseUnit unit) {
    final next = unit.lessons
        .where(
          (lesson) =>
              !state.courseProgress.completedLessonIds.contains(lesson.id) &&
              state.isCourseLessonUnlocked(lesson.requiredPreviousLessonId),
        )
        .firstOrNull;
    if (next != null) {
      _openLesson(context, next);
    } else {
      _openQuiz(context, state, unit);
    }
  }

  void _openQuiz(BuildContext context, AppProvider state, CourseUnit unit) {
    final ready = unit.lessons.every(
      (lesson) => state.courseProgress.completedLessonIds.contains(lesson.id),
    );
    if (!AppProvider.unlockA1DuringDevelopment && !ready) {
      _lockedMessage(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UnitQuizScreen(unit: unit)),
    );
  }

  void _openLesson(BuildContext context, CourseLesson lesson) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CourseLearningScreen(lesson: lesson)),
  );

  void _lockedMessage(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marka hore dhammaystir casharka kaa horreeya.'),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.text, this.onTap);
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
