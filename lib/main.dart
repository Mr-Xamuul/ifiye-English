import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/storage/local_storage_service.dart';
import 'providers/app_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(storage)..initialize(),
      child: const IfiyeEnglishApp(),
    ),
  );
}
