import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/text_to_speech_service.dart';
import '../../models/content/content_models.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/english_speech_button.dart';

class CourseLearningScreen extends StatefulWidget {
  const CourseLearningScreen({required this.lesson, super.key});
  final CourseLesson lesson;

  @override
  State<CourseLearningScreen> createState() => _CourseLearningScreenState();
}

class _CourseLearningScreenState extends State<CourseLearningScreen>
    with WidgetsBindingObserver {
  int _step = 0;
  final Map<String, String> _answers = {};
  final Set<String> _completedPrompts = {};
  late final TextToSpeechService _tts = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _tts.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tts.disposeService().whenComplete(_tts.dispose);
    super.dispose();
  }

  int get _grammarSteps => widget.lesson.grammar == null ? 0 : 1;
  int get _vocabularyStart => 2 + _grammarSteps;
  int get _examplesStart => _vocabularyStart + widget.lesson.vocabulary.length;
  int get _dialoguesStart => _examplesStart + widget.lesson.examples.length;
  int get _exercisesStart => _dialoguesStart + widget.lesson.dialogues.length;
  int get _speakingStep =>
      _exercisesStart + widget.lesson.practiceExercises.length;
  int get _writingStep => _speakingStep + 1;
  int get _summaryStep => _writingStep + 1;
  int get _totalSteps => _summaryStep + 1;

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _totalSteps;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Xir casharka',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.titleEnglish,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Tallaabada ${_step + 1} / $_totalSteps',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: _buildStep(context),
                ),
              ),
            ),
            _LessonNavigation(
              canGoBack: _step > 0,
              canContinue: _canContinue,
              isLast: _step == _summaryStep,
              onBack: () => setState(() => _step--),
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    if (_step == 0) {
      return _introCard(context);
    }
    if (_step == 1) {
      return _objectivesCard(context);
    }
    if (_grammarSteps == 1 && _step == 2) {
      return _grammarCard(context, widget.lesson.grammar!);
    }
    if (_step < _examplesStart) {
      return _vocabularyCard(
        context,
        widget.lesson.vocabulary[_step - _vocabularyStart],
      );
    }
    if (_step < _dialoguesStart) {
      return _exampleCard(
        context,
        widget.lesson.examples[_step - _examplesStart],
        _step - _examplesStart,
      );
    }
    if (_step < _exercisesStart) {
      return _dialogueCard(
        context,
        widget.lesson.dialogues[_step - _dialoguesStart],
        _step - _dialoguesStart,
      );
    }
    if (_step < _speakingStep) {
      return _exerciseCard(
        context,
        widget.lesson.practiceExercises[_step - _exercisesStart],
        _step - _exercisesStart,
      );
    }
    if (_step == _speakingStep) {
      return _promptCard(
        context,
        id: 'speaking',
        icon: Icons.mic_none_rounded,
        label: 'Speaking practice',
        title: 'Cod dheer ku celceli',
        content: widget.lesson.speakingPractice,
        color: Colors.purple,
      );
    }
    if (_step == _writingStep) {
      return _promptCard(
        context,
        id: 'writing',
        icon: Icons.edit_note_rounded,
        label: 'Writing practice',
        title: 'Hadda adigu qor',
        content: widget.lesson.writingPractice,
        color: Colors.blue,
      );
    }
    return _summaryCard(context);
  }

  Widget _introCard(BuildContext context) => _StepCard(
    color: Theme.of(context).colorScheme.primary,
    icon: Icons.waving_hand_outlined,
    eyebrow: 'BILOW CASHARKA',
    child: Column(
      children: [
        Text(
          widget.lesson.titleEnglish,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.lesson.titleSomali,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          widget.lesson.shortDescriptionSomali,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, height: 1.55),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _InfoChip(
              icon: Icons.schedule,
              text: '${widget.lesson.estimatedMinutes} daqiiqo',
            ),
            _InfoChip(icon: Icons.signal_cellular_alt, text: 'Bilow'),
            _InfoChip(
              icon: Icons.layers_outlined,
              text: widget.lesson.lessonType.name,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _objectivesCard(BuildContext context) => _StepCard(
    color: Colors.green,
    icon: Icons.flag_outlined,
    eyebrow: 'UJEEDDOOYINKA',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Casharkan kadib waxaad awoodi doontaa:',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.lesson.learningObjectives.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _grammarCard(BuildContext context, GrammarTopic topic) => _StepCard(
    color: Colors.blueGrey,
    icon: Icons.account_tree_outlined,
    eyebrow: 'GRAMMAR FUDUD',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          topic.titleEnglish,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          topic.titleSomali,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 16),
        Text(topic.explanationSomali, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 14),
        _SoftPanel(
          icon: Icons.rule_outlined,
          color: Colors.blueGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.rule,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Qaabka: ${topic.sentenceStructure}'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Tusaalooyin',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...topic.positiveExamples.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.english,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(item.somali, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        if (topic.commonMistakesSomali.isNotEmpty)
          _SoftPanel(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topic.commonMistakesSomali
                  .map((mistake) => Text('• $mistake'))
                  .toList(),
            ),
          ),
      ],
    ),
  );

  Widget _vocabularyCard(BuildContext context, VocabularyEntry word) {
    final state = context.watch<AppProvider>();
    final id =
        '${widget.lesson.id}-${word.englishWord.toLowerCase().replaceAll(' ', '-')}';
    final saved = state.isSaved(id);
    return _StepCard(
      color: Colors.deepOrange,
      icon: Icons.translate_rounded,
      eyebrow:
          'ERAYGA ${_step - _vocabularyStart + 1} / ${widget.lesson.vocabulary.length}',
      trailing: IconButton.filledTonal(
        tooltip: saved ? 'Ka saar saved' : 'Keydi erayga',
        onPressed: () => state.toggleSaved(
          SavedItem(
            id: id,
            type: SavedItemType.word,
            englishText: word.englishWord,
            somaliText: word.somaliMeaning,
            lessonId: widget.lesson.id,
            createdAt: DateTime.now(),
          ),
        ),
        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            word.englishWord,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            word.somaliMeaning,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EnglishSpeechButton(service: _tts, text: word.englishWord),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '/${word.pronunciation}/ • ${word.partOfSpeech}',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SoftPanel(
            icon: Icons.lightbulb_outline,
            child: Text(
              word.explanationSomali,
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  word.exampleEnglish,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              EnglishSpeechButton(
                service: _tts,
                text: word.exampleEnglish,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            word.exampleSomali,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          if (word.commonMistakeSomali.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SoftPanel(
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              child: Text(word.commonMistakeSomali),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exampleCard(
    BuildContext context,
    BilingualExample item,
    int index,
  ) => _StepCard(
    color: Colors.teal,
    icon: Icons.chat_bubble_outline,
    eyebrow: 'TUSAALE ${index + 1} / ${widget.lesson.examples.length}',
    child: Column(
      children: [
        const SizedBox(height: 8),
        Icon(Icons.format_quote_rounded, size: 48, color: Colors.teal.shade200),
        Text(
          item.english,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 54,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.somali,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 18, height: 1.4),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Jumladda si cod dheer u akhri, kadib mar kale ku celi.',
              ),
            ),
          ),
          icon: const Icon(Icons.record_voice_over_outlined),
          label: const Text('Ku celceli cod dheer'),
        ),
      ],
    ),
  );

  Widget _dialogueCard(
    BuildContext context,
    LessonDialogue dialogue,
    int index,
  ) => _StepCard(
    color: Colors.cyan.shade700,
    icon: Icons.forum_outlined,
    eyebrow: 'WADA SHEEKAYSI ${index + 1} / ${widget.lesson.dialogues.length}',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          dialogue.titleSomali,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...dialogue.lines.asMap().entries.map((entry) {
          final line = entry.value;
          final alternate = entry.key.isOdd;
          return Align(
            alignment: alternate ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: alternate
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.speaker,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line.english,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(line.somali, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );

  Widget _exerciseCard(BuildContext context, PracticeExercise item, int index) {
    final selected = _answers[item.id];
    final answered = selected != null;
    final correct =
        answered && selected.toLowerCase() == item.correctAnswer.toLowerCase();
    final isPrompt = item.options.isEmpty;
    return _StepCard(
      color: Colors.indigo,
      icon: Icons.extension_outlined,
      eyebrow: 'LAYLI ${index + 1} / ${widget.lesson.practiceExercises.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _exerciseLabel(item.type),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (isPrompt)
            _PromptAction(
              completed: _completedPrompts.contains(item.id),
              onChanged: (value) => setState(
                () => value
                    ? _completedPrompts.add(item.id)
                    : _completedPrompts.remove(item.id),
              ),
            )
          else
            ...item.options.map((option) {
              final isSelected = selected == option;
              final isCorrectOption = answered && option == item.correctAnswer;
              final color = isCorrectOption
                  ? Colors.green
                  : (isSelected && !correct ? Colors.red : null);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size(0, 54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    backgroundColor: color?.withValues(alpha: .08),
                    side: BorderSide(color: color ?? Colors.grey.shade300),
                  ),
                  onPressed: answered
                      ? null
                      : () => setState(() => _answers[item.id] = option),
                  child: Row(
                    children: [
                      Icon(
                        isCorrectOption
                            ? Icons.check_circle
                            : (isSelected && !correct
                                  ? Icons.cancel
                                  : Icons.radio_button_unchecked),
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option)),
                    ],
                  ),
                ),
              );
            }),
          if (answered) ...[
            const SizedBox(height: 8),
            _SoftPanel(
              icon: correct ? Icons.check_circle_outline : Icons.info_outline,
              color: correct ? Colors.green : Colors.deepOrange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correct
                        ? 'Waa sax! 🎉'
                        : 'Jawaabta saxda ah: ${item.correctAnswer}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(item.explanationSomali),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _promptCard(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String label,
    required String title,
    required String content,
    required Color color,
  }) => _StepCard(
    color: color,
    icon: icon,
    eyebrow: label.toUpperCase(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _SoftPanel(
          icon: icon,
          color: color,
          child: Text(
            content,
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
        ),
        const SizedBox(height: 18),
        _PromptAction(
          completed: _completedPrompts.contains(id),
          onChanged: (value) => setState(
            () => value
                ? _completedPrompts.add(id)
                : _completedPrompts.remove(id),
          ),
        ),
      ],
    ),
  );

  Widget _summaryCard(BuildContext context) {
    final completed = context
        .watch<AppProvider>()
        .courseProgress
        .completedLessonIds
        .contains(widget.lesson.id);
    return _StepCard(
      color: Colors.green,
      icon: Icons.workspace_premium_outlined,
      eyebrow: 'DHAMMAADKA CASHARKA',
      child: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 72,
            color: Colors.amber.shade700,
          ),
          const SizedBox(height: 14),
          Text(
            'Shaqo fiican!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.lesson.summarySomali,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, height: 1.55),
          ),
          const SizedBox(height: 20),
          _SoftPanel(
            icon: Icons.auto_graph,
            color: Colors.green,
            child: Text(
              completed
                  ? 'Casharkan hore ayaad u dhammaystirtay. Waxaad dib ugu soo noqon kartaa mar kasta.'
                  : 'Markaad gujiso “Dhammaystir”, horumarkaaga waa la kaydinayaa, casharka xigana wuu furmayaa.',
            ),
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    if (_step >= _exercisesStart && _step < _speakingStep) {
      final exercise = widget.lesson.practiceExercises[_step - _exercisesStart];
      return exercise.options.isEmpty
          ? _completedPrompts.contains(exercise.id)
          : _answers.containsKey(exercise.id);
    }
    if (_step == _speakingStep) return _completedPrompts.contains('speaking');
    if (_step == _writingStep) return _completedPrompts.contains('writing');
    return true;
  }

  String _exerciseLabel(ExerciseType type) => switch (type) {
    ExerciseType.multipleChoice => 'Dooro jawaabta saxda ah',
    ExerciseType.fillInTheBlank => 'Buuxi meesha bannaan',
    ExerciseType.matchWords => 'Isku aadi erayga iyo macnihiisa',
    ExerciseType.arrangeSentence => 'Jumladda hagaaji',
    ExerciseType.englishToSomali => 'English → Soomaali',
    ExerciseType.somaliToEnglish => 'Soomaali → English',
    ExerciseType.trueFalse => 'Run mise khalad?',
    ExerciseType.speakingPrompt => 'Ku celceli hadalka',
    ExerciseType.shortWriting => 'Layli qoraal',
    _ => 'Ka jawaab layliga',
  };

  Future<void> _next() async {
    if (_step < _summaryStep) {
      setState(() => _step++);
      return;
    }
    await context.read<AppProvider>().completeCourseLesson(widget.lesson.id);
    if (mounted) Navigator.pop(context);
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.color,
    required this.icon,
    required this.eyebrow,
    required this.child,
    this.trailing,
  });
  final Color color;
  final IconData icon;
  final String eyebrow;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: color.withValues(alpha: .1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .15),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  eyebrow,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(22), child: child),
      ],
    ),
  );
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({
    required this.icon,
    required this.child,
    this.color = Colors.amber,
  });
  final IconData icon;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: .18)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 17), label: Text(text));
}

class _PromptAction extends StatelessWidget {
  const _PromptAction({required this.completed, required this.onChanged});
  final bool completed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!completed),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withValues(alpha: .1)
            : Colors.grey.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              completed ? 'Waan sameeyay' : 'Markaan sameeyo halkan taabo',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LessonNavigation extends StatelessWidget {
  const _LessonNavigation({
    required this.canGoBack,
    required this.canContinue,
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });
  final bool canGoBack;
  final bool canContinue;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .06),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            onPressed: canGoBack ? onBack : null,
            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: canContinue ? onNext : null,
            icon: Icon(
              isLast ? Icons.check_circle_outline : Icons.arrow_forward,
            ),
            label: Text(isLast ? 'Dhammaystir casharka' : 'Sii wad'),
          ),
        ),
      ],
    ),
  );
}
