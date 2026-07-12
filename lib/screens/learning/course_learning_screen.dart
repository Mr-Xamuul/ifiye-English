import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/content/content_models.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class CourseLearningScreen extends StatelessWidget {
  const CourseLearningScreen({required this.lesson, super.key});
  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final completed = state.courseProgress.completedLessonIds.contains(
      lesson.id,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.titleEnglish,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            lesson.titleSomali,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.shortDescriptionSomali,
            style: const TextStyle(height: 1.5),
          ),
          const SectionTitle('Waxaad baranaysaa'),
          ...lesson.learningObjectives.map(
            (objective) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              title: Text(objective),
            ),
          ),
          const SectionTitle('Vocabulary iyo pronunciation'),
          ...lesson.vocabulary.map((word) {
            final savedId =
                '${lesson.id}-${word.englishWord.toLowerCase().replaceAll(' ', '-')}';
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          word.englishWord,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Keydi erayga',
                        onPressed: () => state.toggleSaved(
                          SavedItem(
                            id: savedId,
                            type: SavedItemType.word,
                            englishText: word.englishWord,
                            somaliText: word.somaliMeaning,
                            lessonId: lesson.id,
                            createdAt: DateTime.now(),
                          ),
                        ),
                        icon: Icon(
                          state.isSaved(savedId)
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    word.somaliMeaning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    '${word.partOfSpeech} • /${word.pronunciation}/',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(word.explanationSomali),
                  const Divider(height: 22),
                  Text(
                    word.exampleEnglish,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    word.exampleSomali,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (word.commonMistakeSomali.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ka digtoonow: ${word.commonMistakeSomali}',
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SectionTitle('Tusaalooyin'),
          ...lesson.examples.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.record_voice_over_outlined),
              title: Text(item.english),
              subtitle: Text(item.somali),
            ),
          ),
          const SectionTitle('Practice exercises'),
          ...lesson.practiceExercises.asMap().entries.map(
            (entry) => Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 16,
                  child: Text('${entry.key + 1}'),
                ),
                title: Text(entry.value.question),
                subtitle: Text(entry.value.type.name),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  if (entry.value.options.isNotEmpty)
                    Text(entry.value.options.join('  •  ')),
                  const SizedBox(height: 8),
                  Text(
                    'Jawaab: ${entry.value.correctAnswer}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(entry.value.explanationSomali),
                ],
              ),
            ),
          ),
          const SectionTitle('Speaking practice'),
          Text(lesson.speakingPractice, style: const TextStyle(height: 1.5)),
          const SectionTitle('Writing practice'),
          Text(lesson.writingPractice, style: const TextStyle(height: 1.5)),
          const SectionTitle('Soo koobid'),
          AppCard(
            child: Text(
              lesson.summarySomali,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: completed
                ? null
                : () async {
                    await state.completeCourseLesson(lesson.id);
                    if (context.mounted) Navigator.pop(context);
                  },
            icon: Icon(completed ? Icons.check : Icons.task_alt),
            label: Text(
              completed
                  ? 'Casharkan waa la dhammaystiray'
                  : 'Dhammaystir casharka',
            ),
          ),
        ],
      ),
    );
  }
}
