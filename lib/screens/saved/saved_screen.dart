import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/english_speech_button.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with WidgetsBindingObserver {
  int filter = 0;
  late final TextToSpeechService _tts = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _tts.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tts.disposeService().whenComplete(_tts.dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    final values = state.savedItems
        .where((e) => filter == 0 || e.type == SavedItemType.values[filter - 1])
        .toList();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Text(
              'Waxyaabaha la keydiyay',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: ['Dhammaan', 'Erayo', 'Weedho', 'Casharro']
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        selected: filter == e.key,
                        onSelected: (_) => setState(() => filter = e.key),
                        label: Text(e.value),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: values.isEmpty
                ? const EmptyState(
                    icon: Icons.bookmark_border,
                    message:
                        'Weli wax ma aadan keydin. Erayada aad xiisaynayso waxaad ka keydin kartaa casharrada.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: values.length,
                    itemBuilder: (_, i) {
                      final x = values[i];
                      return AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            x.englishText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${x.somaliText}\n${x.type.name}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (x.type != SavedItemType.lesson)
                                EnglishSpeechButton(
                                  service: _tts,
                                  text: x.englishText,
                                  compact: true,
                                ),
                              IconButton(
                                onPressed: () => state.removeSaved(x.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
