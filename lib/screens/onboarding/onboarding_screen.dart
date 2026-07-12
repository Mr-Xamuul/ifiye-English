import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  static const pages = [
    ('English ku baro Af-Soomaali', 'Casharro English ah oo si fudud Af-Soomaali laguugu sharxayo.', Icons.translate),
    ('La soco heerkaaga', 'Barashadaada u raac nidaamka CEFR, laga bilaabo A1 ilaa C2.', Icons.bar_chart_rounded),
    ('Maalin kasta horumar samee', 'Baro casharro, keydi erayo, kadibna isku tijaabi imtixaan.', Icons.local_fire_department_rounded),
  ];

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(children: [
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: context.read<AppProvider>().finishOnboarding, child: const Text('Ka bood'))),
        Expanded(child: PageView.builder(
          controller: controller,
          itemCount: pages.length,
          onPageChanged: (value) => setState(() => page = value),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(pages[i].$3, size: 110, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 40),
              Text(pages[i].$1, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(pages[i].$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey, height: 1.5)),
            ]),
          ),
        )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(4), width: i == page ? 28 : 8, height: 8,
          decoration: BoxDecoration(color: i == page ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        ))),
        Padding(padding: const EdgeInsets.all(24), child: FilledButton(
          onPressed: () { if (page == 2) { context.read<AppProvider>().finishOnboarding(); } else { controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut); } },
          child: Text(page == 2 ? 'Bilow' : 'Xiga'),
        )),
      ]),
    ),
  );
}
