import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/final_exam_engine.dart';
import '../../data/repositories/cefr_content_repository.dart';
import '../../models/content/final_exam_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({
    this.standalone = false,
    this.levelId = 'A1',
    this.contentPath,
    this.examContent,
    super.key,
  });
  final bool standalone;
  final String levelId;
  final String? contentPath;
  final FinalExamContent? examContent;
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  static const _engine = FinalExamEngine();
  late final Future<FinalExamContent> _content;
  bool started = false, finished = false, reviewing = false;
  String reviewFilter = 'all';
  int index = 0;
  Map<String, String> answers = {};
  List<FinalExamQuestion> attemptQuestions = [];

  @override
  void initState() {
    super.initState();
    _content = widget.examContent != null
        ? Future.value(widget.examContent)
        : CefrContentRepository().loadFinalExam(
            widget.contentPath ??
                'assets/content/${widget.levelId.toLowerCase()}/final_exam.json',
          );
  }

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
              appBar: AppBar(title: Text('${widget.levelId} Final Exam')),
              body: SafeArea(child: body),
            )
          : SafeArea(child: body);
    },
  );

  Widget _intro(FinalExamContent exam) {
    final state = context.watch<AppProvider>();
    final progress = state.finalExamProgressFor(widget.levelId);
    final unlocked = widget.levelId == 'A2'
        ? state.hasCompletedFinalReviewFor('A2')
        : AppProvider.unlockAllDuringDevelopment ||
              state.hasCompletedFinalReviewFor(widget.levelId);
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
                title: Text(
                  widget.levelId == 'A2' ? 'Su’aalaha attempt-ka' : 'Su’aalaha',
                ),
                trailing: Text(
                  '${exam.attemptQuestionCount ?? exam.questions.length}',
                ),
              ),
              if (widget.levelId == 'A2')
                ListTile(
                  title: const Text('Question bank'),
                  trailing: Text('${exam.questions.length}'),
                ),
              ListTile(
                title: const Text('Passing score'),
                trailing: Text('${exam.passingScore}%'),
              ),
              if (widget.levelId == 'A2')
                ListTile(
                  title: const Text('Waqtiga la qiyaasay'),
                  trailing: Text('${exam.estimatedMinutes} daqiiqo'),
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
        AppCard(
          child: Text(
            '${exam.descriptionSomali}\n\n'
            'Akhri su’aal kasta si taxaddar leh. Dooro jawaabta ugu habboon. '
            'Su’aalaha qaarkood waxay ku salaysan yihiin qoraal, jadwal ama wada-hadal. '
            'Waxaad u baahan tahay ugu yaraan ${exam.passingScore}% si aad u gudubto. '
            'Natiijadaada waa la keydin doonaa. Hubi jawaabahaaga kahor submit.',
            style: const TextStyle(height: 1.5),
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
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Marka hore dhammaystir ${widget.levelId} Final Review.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  void _start(FinalExamProgress progress) async {
    final exam = await _content;
    if (!mounted) return;
    setState(() {
      started = true;
      if (progress.started && !progress.completed) {
        index = progress.currentQuestion;
        answers = {...progress.answers};
        attemptQuestions =
            progress.questionIds.isEmpty && exam.attemptQuestionCount == null
            ? List<FinalExamQuestion>.of(exam.questions)
            : _engine.restoreAttempt(exam, progress.questionIds);
      }
      if (attemptQuestions.isEmpty) {
        attemptQuestions = _engine.selectAttempt(
          exam,
          seed: DateTime.now().microsecondsSinceEpoch,
        );
        index = 0;
        answers = {};
      }
    });
    await context.read<AppProvider>().saveLevelFinalExamSession(
      widget.levelId,
      index,
      answers,
      attemptQuestions.map((question) => question.id).toList(),
    );
  }

  Widget _question(FinalExamContent exam) {
    final q = attemptQuestions[index];
    final selected = answers[q.id];
    final sectionNumber = const {
      'vocabulary': 1,
      'grammar': 2,
      'reading': 3,
      'documents': 4,
      'communication': 5,
      'correction': 6,
      'somaliToEnglish': 7,
      'englishToSomali': 8,
    }[q.sectionId];
    final resource = q.resourceId == null
        ? null
        : exam.resources.where((item) => item.id == q.resourceId).firstOrNull;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Qaybta $sectionNumber • ${q.sectionId.toUpperCase()}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        Text(
          'Su’aal ${index + 1} / ${attemptQuestions.length} • '
          '${attemptQuestions.length - index - 1} ayaa haray',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (index + 1) / attemptQuestions.length),
        const SizedBox(height: 20),
        if (resource != null) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(resource.content),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: selected == option
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
              onPressed: () async {
                setState(() => answers[q.id] = option);
                await context.read<AppProvider>().saveLevelFinalExamSession(
                  widget.levelId,
                  index,
                  answers,
                  attemptQuestions.map((question) => question.id).toList(),
                );
              },
              icon: Icon(
                selected == option
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              label: Text(option),
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
                onPressed: index == attemptQuestions.length - 1
                    ? () => _confirmSubmit(exam)
                    : () => _move(index + 1),
                child: Text(
                  index == attemptQuestions.length - 1 ? 'Submit' : 'Next',
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
    context.read<AppProvider>().saveLevelFinalExamSession(
      widget.levelId,
      index,
      answers,
      attemptQuestions.map((question) => question.id).toList(),
    );
  }

  Future<void> _confirmSubmit(FinalExamContent exam) async {
    final unanswered = attemptQuestions.length - answers.length;
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
    final score = _engine.score(attemptQuestions, answers);
    await context.read<AppProvider>().finishLevelFinalExam(
      widget.levelId,
      exam.passingScore,
      score,
      _engine.categoryScores(attemptQuestions, answers),
    );
    if (mounted) setState(() => finished = true);
  }

  Widget _result(FinalExamContent exam) {
    final progress = context.watch<AppProvider>().finalExamProgressFor(
      widget.levelId,
    );
    final score = progress.latestScore;
    final category = widget.levelId == 'A2'
        ? score >= 85
              ? 'Waxqabad aad u wanaagsan'
              : score >= 70
              ? 'Waad gudubtay'
              : score >= 50
              ? 'Weli ma gudbin'
              : 'Dib-u-eegis dheeraad ah ayaa loo baahan yahay'
        : score >= 90
        ? 'Aad u wanaagsan'
        : score >= 80
        ? 'Aad u fiican'
        : score >= exam.passingScore
        ? 'Waad gudubtay'
        : score >= 60
        ? 'Dib-u-eegis ayaad u baahan tahay'
        : 'Tababar dheeraad ah ayaad u baahan tahay';
    final correct = attemptQuestions
        .where((q) => answers[q.id] == q.correctAnswer)
        .length;
    final unanswered = attemptQuestions
        .where((question) => !answers.containsKey(question.id))
        .length;
    final incorrect = attemptQuestions.length - correct - unanswered;
    final strongest = _engine.strongest(progress.sectionScores);
    final weakest = _engine.weakest(progress.sectionScores);
    final recommendations = _engine.recommendations(attemptQuestions, answers);
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
        if (progress.passed && widget.levelId == 'A2')
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Waxaad dhammaystirtay heerka A2 ee app-kan.'),
              subtitle: Text(
                'B1 waa furmay • Completion: ${progress.completionDate ?? 'la keydiyay'}',
              ),
            ),
          ),
        AppCard(
          child: Column(
            children: [
              ListTile(title: const Text('Sax'), trailing: Text('$correct')),
              ListTile(
                title: const Text('Khalad'),
                trailing: Text('$incorrect'),
              ),
              ListTile(
                title: const Text('Lama jawaabin'),
                trailing: Text('$unanswered'),
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
              ListTile(
                title: const Text('Meelaha ugu fiican'),
                subtitle: Text(strongest.join(', ')),
              ),
              ListTile(
                title: const Text('Meelaha dib loo eegayo'),
                subtitle: Text(weakest.join(', ')),
              ),
              ListTile(
                title: const Text('Review Weak Areas'),
                subtitle: Text(recommendations.join(', ')),
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
            label: Text(
              widget.levelId == 'A2' ? 'Continue to B1' : 'U gudub A2',
            ),
          ),
        if (widget.levelId == 'A2')
          OutlinedButton(
            onPressed: () => context.read<AppProvider>().setNavIndex(2),
            child: const Text('Review A2'),
          ),
        OutlinedButton(
          onPressed: () => widget.standalone
              ? Navigator.pop(context)
              : context.read<AppProvider>().setNavIndex(0),
          child: Text('Ku noqo ${widget.levelId}'),
        ),
      ],
    );
  }

  Widget _review(FinalExamContent exam) {
    final filtered = attemptQuestions.where((q) {
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
              ('section:documents', 'Documents'),
              ('section:communication', 'Communication'),
              ('section:correction', 'Correction'),
              ('section:somaliToEnglish', 'Soomaali → English'),
              ('section:englishToSomali', 'English → Soomaali'),
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
    final exam = await _content;
    if (!mounted) return;
    await context.read<AppProvider>().retryLevelFinalExam(widget.levelId);
    if (!mounted) return;
    setState(() {
      started = true;
      finished = false;
      reviewing = false;
      index = 0;
      answers = {};
      attemptQuestions = _engine.selectAttempt(
        exam,
        seed: DateTime.now().microsecondsSinceEpoch,
      );
    });
    if (!mounted) return;
    await context.read<AppProvider>().saveLevelFinalExamSession(
      widget.levelId,
      0,
      const {},
      attemptQuestions.map((question) => question.id).toList(),
    );
  }
}
