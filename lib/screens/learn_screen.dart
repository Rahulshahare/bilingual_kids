import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/word_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wordsProv = Provider.of<WordsProvider>(context);
    final progressProv = Provider.of<ProgressProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: PageView.builder(
        itemCount: wordsProv.words.length,
        controller: PageController(initialPage: wordsProv.currentIndex),
        onPageChanged: (idx) {
          // update internal index via provider methods
          wordsProv.currentIndex = idx;
          progressProv.addSeenWord();
        },
        itemBuilder: (_, i) => WordCard(word: wordsProv.words[i]),
      ),
    );
  }
}