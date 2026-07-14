import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/content_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../lessons/lessons_screen.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  late final Future<List<CourseLevel>> _levels = CefrContentRepository()
      .loadLevels();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FutureBuilder<List<CourseLevel>>(
      future: _levels,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Heerarka CEFR lama furin. Fadlan mar kale isku day.',
          );
        }
        return _LevelsList(levels: snapshot.data!);
      },
    ),
  );
}

class _LevelsList extends StatelessWidget {
  const _LevelsList({required this.levels});
  final List<CourseLevel> levels;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Heerarka CEFR',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ka bilow A1, una gudub heerarka kale markaad imtixaanka gudubto.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 14),
        ...levels.map((level) {
          final unlocked =
              level.requiredPreviousLevelId == null ||
              state.courseProgress.hasPassedFinalExam(
                level.requiredPreviousLevelId!,
              );
          final progress = level.id == 'A1'
              ? (state.courseProgress.completedLessonIds.length / 45).clamp(
                  0.0,
                  1.0,
                )
              : 0.0;
          return AppCard(
            onTap: unlocked
                ? () {
                    if (level.id == 'A1') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LessonsScreen(showBack: true),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Content-ka heerkan waxaa lagu dari doonaa marka A1 la dhammaystiro.',
                          ),
                        ),
                      );
                    }
                  }
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Marka hore gudub ${level.requiredPreviousLevelId}.',
                      ),
                    ),
                  ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: unlocked
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey.shade200,
                  child: Text(
                    level.id,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        level.descriptionSomali,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      if (level.id == 'A1') ...[
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 5),
                      ],
                      Text(
                        '${level.unitFiles.length} units • ${unlocked ? (level.id == 'A1' ? '${(progress * 100).round()}%' : 'Diyaar') : 'Locked'}',
                        style: TextStyle(
                          color: unlocked
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontSize: 12,
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
      ],
    );
  }
}
