import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../exam/exam_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({required this.lesson, super.key});
  final Lesson lesson;
  @override State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int index = 0;
  bool understood = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.lesson.lessonItems[index];
    final state = context.watch<AppProvider>();
    final saved = state.isSaved('${widget.lesson.id}-${item.id}');
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)), title: Text(widget.lesson.titleEnglish, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Row(children: [Text('${index + 1}/${widget.lesson.lessonItems.length}'), const SizedBox(width: 12), Expanded(child: LinearProgressIndicator(value: (index + 1) / widget.lesson.lessonItems.length, borderRadius: BorderRadius.circular(8)))]),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: Card(child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Chip(label: Text('VOCABULARY')),
                IconButton(onPressed: () => state.toggleSaved(SavedItem(id: '${widget.lesson.id}-${item.id}', type: SavedItemType.word, englishText: item.englishText, somaliText: item.somaliText, lessonId: widget.lesson.id, createdAt: DateTime.now())), icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline)),
              ]),
              const SizedBox(height: 18),
              Text(item.englishText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(item.somaliText, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.volume_up_outlined), const SizedBox(width: 8), Text('/${item.pronunciation}/', style: const TextStyle(color: Colors.grey))]),
              const Divider(height: 36),
              Text(item.exampleEnglish, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6), Text(item.exampleSomali, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 20), FilterChip(selected: understood, onSelected: (v) => setState(() => understood = v), label: const Text('Waan fahmay'), avatar: const Icon(Icons.check_circle_outline)),
            ]),
          )))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: index == 0 ? null : () => setState(() { index--; understood = false; }), child: const Text('Hore'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: understood ? () => _next(context) : null, child: Text(index == widget.lesson.lessonItems.length - 1 ? 'Dhammaystir' : 'Xiga'))),
          ]),
        ]),
      )),
    );
  }

  Future<void> _next(BuildContext context) async {
    if (index < widget.lesson.lessonItems.length - 1) { setState(() { index++; understood = false; }); return; }
    await context.read<AppProvider>().completeLesson(widget.lesson.id);
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _Completion(lesson: widget.lesson)));
  }
}

class _Completion extends StatelessWidget {
  const _Completion({required this.lesson});
  final Lesson lesson;
  @override Widget build(BuildContext context) {
    final i = a1Lessons.indexWhere((e) => e.id == lesson.id);
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.workspace_premium, size: 100, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 22),
      Text('Hambalyo!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Text('Waxaad dhammaysay ${lesson.titleEnglish}.', textAlign: TextAlign.center), const SizedBox(height: 8), const Text('Horumar: 100%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const SizedBox(height: 28),
      FilledButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExamScreen(standalone: true))), child: const Text('Qaado quiz')),
      const SizedBox(height: 10), OutlinedButton(onPressed: i < a1Lessons.length - 1 ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LearningScreen(lesson: a1Lessons[i + 1]))) : null, child: const Text('Casharka xiga')),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ku noqo casharrada')),
    ]))));
  }
}
