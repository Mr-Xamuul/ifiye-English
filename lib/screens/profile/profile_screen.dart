import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(radius: 42, child: Icon(Icons.person, size: 45)),
                SizedBox(height: 10),
                Text(
                  'Arday',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text('Heerka A1', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('Casharro la dhammaystiray'),
                  trailing: Text(
                    '${s.courseProgress.completedLessonIds.length}',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Waxyaabo la keydiyay'),
                  trailing: Text('${s.savedItems.length}'),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Imtixaanka ugu fiican'),
                  trailing: Text('${s.bestScore}%'),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Hadafka maalinlaha'),
                  subtitle: Text('${s.dailyGoal} daqiiqo'),
                  trailing: DropdownButton<int>(
                    value: s.dailyGoal,
                    items: [5, 10, 15, 20]
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) s.updateDailyGoal(v);
                    },
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Luqadda'),
                  trailing: Text('Af-Soomaali'),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.business),
                  title: Text('About Garaad Tech'),
                  subtitle: Text(
                    'ifiye English V1 • English ku baro Af-Soomaali',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.red),
                  title: const Text(
                    'Dib u bilow horumarka',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmReset(context, s),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext c, AppProvider s) async {
    final ok = await showDialog<bool>(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text('Dib u bilow?'),
        content: const Text(
          'Casharrada, saved items iyo natiijooyinka imtixaanka waa la tirtirayaa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Maya'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Haa, tirtir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await s.resetProgress();
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          const SnackBar(content: Text('Horumarka dib ayaa loo bilaabay.')),
        );
      }
    }
  }
}
