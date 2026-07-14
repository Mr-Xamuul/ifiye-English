import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/content/content_models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class UnitQuizScreen extends StatefulWidget {
  const UnitQuizScreen({required this.unit, super.key});
  final CourseUnit unit;

  @override
  State<UnitQuizScreen> createState() => _UnitQuizScreenState();
}

class _UnitQuizScreenState extends State<UnitQuizScreen> {
  int index = 0;
  int correct = 0;
  String? selected;
  bool finished = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('A1 Unit ${widget.unit.unitNumber} Quiz')),
    body: SafeArea(child: finished ? _result(context) : _question(context)),
  );

  Widget _question(BuildContext context) {
    final item = widget.unit.unitQuiz[index];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Su’aal ${index + 1} / ${widget.unit.unitQuiz.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (index + 1) / widget.unit.unitQuiz.length,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 24),
          Text(
            item.question,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          if (item.options.isEmpty)
            TextField(
              enabled: selected == null,
              decoration: const InputDecoration(
                hintText: 'Halkan ku qor jawaabta',
              ),
              onChanged: (value) => setState(
                () => selected = value.trim().isEmpty ? null : value.trim(),
              ),
            )
          else
            ...item.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: _answerColor(
                      item,
                      option,
                    )?.withValues(alpha: .1),
                    side: BorderSide(
                      color: _answerColor(item, option) ?? Colors.grey.shade300,
                    ),
                  ),
                  onPressed: selected == null
                      ? () => _select(item, option)
                      : null,
                  child: Text(option),
                ),
              ),
            ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            AppCard(
              child: Text(
                '${_isCorrect(item) ? 'Sax!' : 'Khalad.'} ${item.explanationSomali}',
                style: TextStyle(
                  color: _isCorrect(item)
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: selected == null ? null : _next,
            child: Text(
              index == widget.unit.unitQuiz.length - 1
                  ? 'Dhammaystir quiz-ka'
                  : 'Su’aasha xigta',
            ),
          ),
        ],
      ),
    );
  }

  Color? _answerColor(PracticeExercise item, String option) {
    if (selected == null) return null;
    if (option == item.correctAnswer) return Colors.green;
    if (option == selected) return Colors.red;
    return null;
  }

  bool _isCorrect(PracticeExercise item) =>
      selected?.toLowerCase() == item.correctAnswer.toLowerCase();

  void _select(PracticeExercise item, String answer) {
    setState(() {
      selected = answer;
      if (_isCorrect(item)) correct++;
    });
  }

  void _next() {
    final item = widget.unit.unitQuiz[index];
    if (item.options.isEmpty && _isCorrect(item)) correct++;
    if (index < widget.unit.unitQuiz.length - 1) {
      setState(() {
        index++;
        selected = null;
      });
      return;
    }
    final score = (correct / widget.unit.unitQuiz.length * 100).round();
    context.read<AppProvider>().recordUnitQuizScore(widget.unit.id, score);
    setState(() => finished = true);
  }

  Widget _result(BuildContext context) {
    final score = (correct / widget.unit.unitQuiz.length * 100).round();
    final passed = score >= 70;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Icon(
          passed ? Icons.emoji_events : Icons.refresh,
          size: 100,
          color: passed ? Colors.amber : Theme.of(context).colorScheme.primary,
        ),
        Text(
          passed ? 'Hambalyo, waad gudubtay!' : 'Weli maadan gudbin',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '$score%',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Jawaabaha saxda ah'),
                trailing: Text('$correct'),
              ),
              ListTile(
                title: const Text('Jawaabaha khaldan'),
                trailing: Text('${widget.unit.unitQuiz.length - correct}'),
              ),
              ListTile(
                title: const Text('Passing score'),
                trailing: const Text('70%'),
              ),
              Text(
                passed
                    ? 'Unit ${widget.unit.unitNumber + 1} hadda waa kuu furmay.'
                    : widget.unit.id == 'a1-u05'
                    ? 'Dib u eeg daily activities, Present Simple positive/negative/questions, do/does, third-person forms iyo frequency words; kadib mar kale isku day.'
                    : widget.unit.id == 'a1-u04'
                    ? 'Dib u eeg family vocabulary, have/has, possessive adjectives, muuqaalka, dabeecadda iyo this/that/these/those; kadib mar kale isku day.'
                    : widget.unit.id == 'a1-u03'
                    ? 'Dib u eeg tirooyinka, da’da, telefoonka, cinwaannada, qiimaha, taariikhaha iyo foomamka; kadib mar kale isku day.'
                    : widget.unit.id == 'a1-u02'
                    ? 'Dib u eeg Basic Greetings, am/is/are, formal iyo informal greetings, iyo wada sheekeysiyada; kadib mar kale isku day.'
                    : 'Dib u eeg casharrada, kadib mar kale isku day.',
                style: TextStyle(
                  color: passed ? Colors.green : Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: _retry, child: const Text('Mar kale qaado')),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Ku noqo Unit ${widget.unit.unitNumber}'),
        ),
      ],
    );
  }

  void _retry() => setState(() {
    index = 0;
    correct = 0;
    selected = null;
    finished = false;
  });
}
