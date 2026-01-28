import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/alphabets_provider.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import 'alphabets_learn_screen.dart';
import '../widgets/star_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context).progress;
    return Scaffold(
      appBar: AppBar(title: const Text('Bilingual Kids')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StarBar(stars: progress.stars),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text('Learn Words'),
              onPressed: () async {
                await Provider.of<WordsProvider>(context, listen: false).loadLocal();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LearnScreen()));
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text('Quiz Me!'),
              onPressed: () async {
                await Provider.of<WordsProvider>(context, listen: false).loadLocal();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.abc),
              label: const Text('Learn Alphabet'),
              onPressed: () async {
                await Provider.of<AlphabetsProvider>(context, listen: false).loadCourse();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlphabetsLearnScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}