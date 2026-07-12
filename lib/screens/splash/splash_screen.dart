import 'package:flutter/material.dart';
import '../../app/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppTheme.primary,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.school_rounded,
                color: AppTheme.primary,
                size: 45,
              ),
            ),
            SizedBox(height: 22),
            Text(
              'ifiye English',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'English ku baro Af-Soomaali',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 36),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    ),
  );
}
