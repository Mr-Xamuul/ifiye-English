import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/final_exam_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({this.standalone = false, super.key});
  final bool standalone;
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final Future<FinalExamContent> _content = CefrContentRepository()
      .loadFinalExam('assets/content/a1/final_exam.json');
  bool started = false, finished = false, reviewing = false;
  String reviewFilter = 'all';
  int index = 0;
  Map<String, String> answers = {};

  @override
  Widget build(BuildContext context) => FutureBuilder<FinalExamContent>(
    future: _content,
    builder: (context, snapshot) {
      final body = snapshot.connectionState != ConnectionState.done
          ? const Center(child: CircularProgressIndicator())
          : snapshot.hasError || !snapshot.hasData
          ? const EmptyState(
              icon: Icons.error_outline,
              message: 'Final Exam content-ka lama furin.',
            )
          : reviewing
          ? _review(snapshot.data!)
          : finished
          ? _result(snapshot.data!)
          : started
          ? _question(snapshot.data!)
          : _intro(snapshot.data!);
      return widget.standalone
          ? Scaffold(
              appBar: AppBar(title: const Text('A1 Final Level Exam')),
              body: SafeArea(child: body),
            )
          : SafeArea(child: body);
    },
  );

  Widget _intro(FinalExamContent exam) {
    final state = context.watch<AppProvider>();
    final progress = state.finalExamProgress;
    final unlocked =
        AppProvider.unlockAllDuringDevelopment || state.hasCompletedFinalReview;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          exam.titleEnglish,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          exam.titleSomali,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Su’aalaha'),
                trailing: Text('${exam.questions.length}'),
              ),
              const ListTile(
                title: Text('Passing score'),
                trailing: Text('75%'),
              ),
              ListTile(
                title: const Text('Attempts'),
                trailing: Text('${progress.attempts}'),
              ),
              ListTile(
                title: const Text('Best score'),
                trailing: Text('${progress.bestScore}%'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const AppCard(
          child: Text(
            'Xeerarka: Jawaabaha saxda ah lama muujinayo inta imtixaanku socdo. '
            'Waxaad isticmaali kartaa Previous iyo Next. Jawaabahaaga iyo su’aasha aad joogto way kaydsamayaan. '
            'Ka hor submit digniin ayaa lagu siinayaa haddii su’aalo bannaan jiraan. A2 wuxuu furmaa markaad hesho 75% ama ka badan.',
            style: TextStyle(height: 1.5),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: unlocked ? () => _start(progress) : null,
          icon: Icon(
            progress.started && !progress.completed
                ? Icons.play_arrow
                : Icons.quiz_outlined,
          ),
          label: Text(
            progress.started && !progress.completed
                ? 'Sii wad imtixaanka'
                : 'Bilow imtixaanka',
          ),
        ),
        if (!unlocked)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Marka hore dhammaystir A1 Final Review.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  void _start(FinalExamProgress progress) {
    setState(() {
      started = true;
      if (progress.started && !progress.completed) {
        index = progress.currentQuestion;
        answers = {...progress.answers};
      }
    });
  }

  Widget _question(FinalExamContent exam) {
    final q = exam.questions[index];
    final selected = answers[q.id];
    final sectionNumber = const {
      'vocabulary': 1,
      'grammar': 2,
      'reading': 3,
      'situations': 4,
      'translation': 5,
    }[q.sectionId];
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Qaybta $sectionNumber • ${q.sectionId.toUpperCase()}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        Text(
          'Su’aal ${index + 1} / ${exam.questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (index + 1) / exam.questions.length),
        const SizedBox(height: 20),
        Text(
          q.question,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...q.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: selected == option
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
              onPressed: () async {
                setState(() => answers[q.id] = option);
                await context.read<AppProvider>().saveFinalExamSession(
                  index,
                  answers,
                );
              },
              child: Text(option),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: index == 0 ? null : () => _move(index - 1),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: index == exam.questions.length - 1
                    ? () => _confirmSubmit(exam)
                    : () => _move(index + 1),
                child: Text(
                  index == exam.questions.length - 1 ? 'Submit' : 'Next',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _move(int value) {
    setState(() => index = value);
    context.read<AppProvider>().saveFinalExamSession(index, answers);
  }

  Future<void> _confirmSubmit(FinalExamContent exam) async {
    final unanswered = exam.questions.length - answers.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gudbi imtixaanka?'),
        content: Text(
          unanswered == 0
              ? 'Waxaad ka jawaabtay dhammaan su’aalaha.'
              : '$unanswered su’aalood ayaan laga jawaabin. Waxay noqonayaan khalad.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Dib u eeg'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gudbi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final score = _score(exam.questions);
    await context.read<AppProvider>().finishFinalExam(
      score,
      _sectionScores(exam.questions),
    );
    if (mounted) setState(() => finished = true);
  }

  int _score(List<FinalExamQuestion> questions) {
    final correct = questions
        .where((q) => answers[q.id] == q.correctAnswer)
        .length;
    return (correct / questions.length * 100).round();
  }

  Map<String, int> _sectionScores(List<FinalExamQuestion> questions) {
    final result = <String, int>{};
    for (final section in questions.map((q) => q.sectionId).toSet()) {
      final items = questions.where((q) => q.sectionId == section).toList();
      final correct = items
          .where((q) => answers[q.id] == q.correctAnswer)
          .length;
      result[section] = (correct / items.length * 100).round();
    }
    return result;
  }

  Widget _result(FinalExamContent exam) {
    final progress = context.watch<AppProvider>().finalExamProgress;
    final score = progress.latestScore;
    final category = score >= 90
        ? 'Aad u wanaagsan'
        : score >= 80
        ? 'Aad u fiican'
        : score >= 75
        ? 'Waad gudubtay'
        : score >= 60
        ? 'Dib-u-eegis ayaad u baahan tahay'
        : 'Tababar dheeraad ah ayaad u baahan tahay';
    final correct = exam.questions
        .where((q) => answers[q.id] == q.correctAnswer)
        .length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(
          progress.passed ? Icons.emoji_events : Icons.refresh,
          size: 88,
          color: progress.passed ? Colors.amber : Colors.deepOrange,
        ),
        Text(
          category,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          '$score%',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        AppCard(
          child: Column(
            children: [
              ListTile(title: const Text('Sax'), trailing: Text('$correct')),
              ListTile(
                title: const Text('Khalad'),
                trailing: Text('${exam.questions.length - correct}'),
              ),
              ListTile(
                title: const Text('Best score'),
                trailing: Text('${progress.bestScore}%'),
              ),
              ListTile(
                title: const Text('Attempts'),
                trailing: Text('${progress.attempts}'),
              ),
              ...progress.sectionScores.entries.map(
                (e) =>
                    ListTile(title: Text(e.key), trailing: Text('${e.value}%')),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () => setState(() => reviewing = true),
          child: const Text('Dib u eeg jawaabaha'),
        ),
        OutlinedButton(onPressed: _retry, child: const Text('Mar kale qaado')),
        if (progress.passed)
          FilledButton.icon(
            onPressed: () => context.read<AppProvider>().setNavIndex(1),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('U gudub A2'),
          ),
        OutlinedButton(
          onPressed: () => widget.standalone
              ? Navigator.pop(context)
              : context.read<AppProvider>().setNavIndex(0),
          child: const Text('Ku noqo A1'),
        ),
      ],
    );
  }

  Widget _review(FinalExamContent exam) {
    final filtered = exam.questions.where((q) {
      if (reviewFilter == 'correct') return answers[q.id] == q.correctAnswer;
      if (reviewFilter == 'incorrect') return answers[q.id] != q.correctAnswer;
      if (reviewFilter.startsWith('section:')) {
        return q.sectionId == reviewFilter.substring(8);
      }
      return true;
    });
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Review Answers',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Text(
          'Dhammaan • sax iyo khalad • section kasta topic/unit ayaa ku qoran.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            for (final filter in const [
              ('all', 'All'),
              ('correct', 'Correct'),
              ('incorrect', 'Incorrect'),
              ('section:vocabulary', 'Vocabulary'),
              ('section:grammar', 'Grammar'),
              ('section:reading', 'Reading'),
              ('section:situations', 'Situations'),
              ('section:translation', 'Translation'),
            ])
              ChoiceChip(
                label: Text(filter.$2),
                selected: reviewFilter == filter.$1,
                onSelected: (_) => setState(() => reviewFilter = filter.$1),
              ),
          ],
        ),
        ...filtered.map((q) {
          final answer = answers[q.id] ?? 'Lama jawaabin';
          final correct = answer == q.correctAnswer;
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${q.sectionId} • ${q.topic} • ${q.unitSource}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  q.question,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Jawaabtaada: $answer',
                  style: TextStyle(color: correct ? Colors.green : Colors.red),
                ),
                Text('Jawaabta saxda ah: ${q.correctAnswer}'),
                Text(q.explanationSomali),
              ],
            ),
          );
        }),
        FilledButton(
          onPressed: () => setState(() => reviewing = false),
          child: const Text('Ku noqo natiijada'),
        ),
      ],
    );
  }

  Future<void> _retry() async {
    await context.read<AppProvider>().retryFinalExam();
    setState(() {
      started = true;
      finished = false;
      reviewing = false;
      index = 0;
      answers = {};
    });
  }
}
