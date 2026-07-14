import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content/a1_exam_data.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({this.standalone = false, super.key});
  final bool standalone;
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  bool started = false, finished = false;
  int index = 0, correct = 0;
  String? selected;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final content = !started
        ? _intro(context, state)
        : finished
        ? _result(context, state)
        : _question(context);
    return widget.standalone
        ? Scaffold(
            appBar: AppBar(title: const Text('Imtixaanka A1')),
            body: content,
          )
        : SafeArea(child: content);
  }

  Widget _intro(BuildContext c, AppProvider s) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      Text(
        'Imtixaanka A1',
        style: Theme.of(
          c,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      const AppCard(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.layers),
              title: Text('Heerka'),
              trailing: Text('A1'),
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Su’aalaha'),
              trailing: Text('10'),
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Guusha'),
              trailing: Text('70%'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          children: [
            ListTile(
              title: const Text('Natiijadii hore'),
              trailing: Text('${s.previousScore}%'),
            ),
            ListTile(
              title: const Text('Natiijada ugu fiican'),
              trailing: Text('${s.bestScore}%'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => setState(() => started = true),
        child: const Text('Bilow imtixaanka'),
      ),
    ],
  );
  Widget _question(BuildContext c) {
    final q = examQuestions[index];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Su’aal ${index + 1} / ${examQuestions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (index + 1) / examQuestions.length,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 28),
          Text(
            q.question,
            style: Theme.of(
              c,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...q.options.map((o) {
            final chosen = selected == o;
            Color? color;
            if (selected != null) {
              if (o == q.correctAnswer) color = Colors.green;
              if (chosen && o != q.correctAnswer) color = Colors.red;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 54),
                  backgroundColor: color?.withValues(alpha: .1),
                  side: BorderSide(color: color ?? Colors.grey.shade300),
                ),
                onPressed: selected == null
                    ? () => setState(() {
                        selected = o;
                        if (o == q.correctAnswer) correct++;
                      })
                    : null,
                child: Text(o),
              ),
            );
          }),
          if (selected != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (selected == q.correctAnswer ? Colors.green : Colors.red)
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${selected == q.correctAnswer ? 'Sax!' : 'Khalad.'} ${q.explanationSomali}',
              ),
            ),
          const Spacer(),
          FilledButton(
            onPressed: selected == null
                ? null
                : () => setState(() {
                    if (index == examQuestions.length - 1) {
                      finished = true;
                      _save();
                    } else {
                      index++;
                      selected = null;
                    }
                  }),
            child: Text(
              index == examQuestions.length - 1 ? 'Dhammaystir' : 'Xiga',
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final score = (correct / examQuestions.length * 100).round();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppProvider>().addExamScore(score);
    });
  }

  Widget _result(BuildContext c, AppProvider s) {
    final score = (correct / examQuestions.length * 100).round(),
        passed = score >= 70;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Icon(
          passed ? Icons.emoji_events : Icons.refresh,
          size: 100,
          color: passed ? Colors.amber : Theme.of(c).colorScheme.primary,
        ),
        Text(
          passed ? 'Waad gudubtay!' : 'Mar kale isku day',
          textAlign: TextAlign.center,
          style: Theme.of(
            c,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '$score%',
          textAlign: TextAlign.center,
          style: Theme.of(c).textTheme.displayMedium?.copyWith(
            color: Theme.of(c).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Jawaabaha saxda ah'),
                trailing: Text('$correct'),
              ),
              ListTile(
                title: const Text('Jawaabaha khaldan'),
                trailing: Text('${examQuestions.length - correct}'),
              ),
              ListTile(
                title: const Text('Natiijo'),
                trailing: Text(passed ? 'Passed' : 'Failed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => setState(() {
            started = true;
            finished = false;
            index = 0;
            correct = 0;
            selected = null;
          }),
          child: const Text('Mar kale qaado'),
        ),
        OutlinedButton(
          onPressed: () =>
              widget.standalone ? Navigator.pop(c) : s.setNavIndex(0),
          child: const Text('Ku noqo Home'),
        ),
      ],
    );
  }
}
