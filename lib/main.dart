import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/word.dart';
import 'models/progress.dart';
import 'providers/words_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/alphabets_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WordAdapter());
  Hive.registerAdapter(UserProgressAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()..init()),
        ChangeNotifierProvider(create: (_) => WordsProvider()),
        ChangeNotifierProvider(create: (_) => AlphabetsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilingual Kids',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}