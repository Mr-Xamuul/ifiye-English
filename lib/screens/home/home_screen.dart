import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../learning/learning_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final done = state.completedLessons.length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: const CircleAvatar(child: Icon(Icons.person)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salaan, Arday!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Aan maanta wax cusub baranno',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weli ogeysiis cusub ma jiro.')),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heerkaaga hadda',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'A1 • Beginner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waxaad dhammaysay $done ka mid ah 10 cashar',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.tonal(
                    onPressed: () => _openNext(context, state),
                    child: const Text('Sii wad barashada'),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Hadafka maanta'),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: _Stat(
                    icon: Icons.schedule,
                    title: '${state.dailyGoal} daqiiqo',
                    subtitle: 'Hadaf maalinle',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: AppCard(
                  child: _Stat(
                    icon: Icons.local_fire_department,
                    title: '3 maalmood',
                    subtitle: 'Xiriir ah',
                  ),
                ),
              ),
            ],
          ),
          const SectionTitle('Ficillo degdeg ah'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              _Action(
                Icons.play_circle_outline,
                'Sii wad casharka',
                () => _openNext(context, state),
              ),
              _Action(
                Icons.bookmark_outline,
                'Erayada la keydiyay',
                () => state.setNavIndex(3),
              ),
              _Action(
                Icons.quiz_outlined,
                'Qaado imtixaan',
                () => state.setNavIndex(4),
              ),
              _Action(
                Icons.layers_outlined,
                'Eeg levels-ka',
                () => state.setNavIndex(1),
              ),
            ],
          ),
          const SectionTitle('Casharradii dhowaa'),
          ...a1Lessons
              .take(3)
              .map(
                (l) => AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearningScreen(lesson: l),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text('${a1Lessons.indexOf(l) + 1}'),
                    ),
                    title: Text(
                      l.titleEnglish,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(l.titleSomali),
                    trailing: Icon(
                      state.completedLessons.contains(l.id)
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: state.completedLessons.contains(l.id)
                          ? Colors.green
                          : null,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _openNext(BuildContext c, AppProvider s) {
    final i = s.completedLessons.length.clamp(0, a1Lessons.length - 1);
    Navigator.push(
      c,
      MaterialPageRoute(builder: (_) => LearningScreen(lesson: a1Lessons[i])),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(c).colorScheme.primary),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.text, this.tap);
  final IconData icon;
  final String text;
  final VoidCallback tap;
  @override
  Widget build(BuildContext c) => AppCard(
    onTap: tap,
    child: Row(
      children: [
        Icon(icon, color: Theme.of(c).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
