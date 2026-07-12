import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../lessons/lessons_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AppProvider>().progress;
    return SafeArea(
      child: ListView(
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
            'Ka bilow A1, una gudub heerarka kale.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          ...cefrLevels.map(
            (l) => AppCard(
              onTap: l.isLocked
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonsScreen(showBack: true),
                      ),
                    ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: l.isLocked
                        ? Colors.grey.shade200
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      l.id,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          l.description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${l.lessonCount} cashar • ${l.isLocked ? 'Coming soon' : '${(progress * 100).round()}%'}',
                          style: TextStyle(
                            color: l.isLocked
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(l.isLocked ? Icons.lock_outline : Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
