import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../learning/learning_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({this.showBack = false, super.key});
  final bool showBack;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final body = ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'A1 Casharrada',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Beginner • 10 cashar',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 14),
        ...a1Lessons.asMap().entries.map((e) {
          final unlocked = state.lessonUnlocked(e.key);
          final complete = state.completedLessons.contains(e.value.id);
          return AppCard(
            onTap: unlocked
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearningScreen(lesson: e.value),
                    ),
                  )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Marka hore dhammayso casharka kaa horreeya.',
                      ),
                    ),
                  ),
            child: Row(
              children: [
                CircleAvatar(
                  child: complete
                      ? const Icon(Icons.check)
                      : Text('${e.key + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value.titleEnglish,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        e.value.titleSomali,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${e.value.duration} daqiiqo',
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
      ],
    );
    return showBack
        ? Scaffold(
            appBar: AppBar(title: const Text('A1 – Beginner')),
            body: body,
          )
        : SafeArea(child: body);
  }
}
