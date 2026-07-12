import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../exam/exam_screen.dart';
import '../home/home_screen.dart';
import '../levels/levels_screen.dart';
import '../lessons/lessons_screen.dart';
import '../saved/saved_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});
  static const pages = [
    HomeScreen(),
    LevelsScreen(),
    LessonsScreen(),
    SavedScreen(),
    ExamScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>();
    return Scaffold(
      body: IndexedStack(index: state.navIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.navIndex,
        onDestinationSelected: state.setNavIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Levels',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Exam',
          ),
        ],
      ),
    );
  }
}
