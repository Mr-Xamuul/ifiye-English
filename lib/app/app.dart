import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/splash/splash_screen.dart';
import 'theme.dart';

class IfiyeEnglishApp extends StatelessWidget {
  const IfiyeEnglishApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ifiye English',
    theme: AppTheme.light,
    home: Consumer<AppProvider>(
      builder: (context, state, child) {
        if (!state.splashFinished || !state.initialized) {
          return const SplashScreen();
        }
        return state.onboardingComplete
            ? const AppShell()
            : const OnboardingScreen();
      },
    ),
  );
}
