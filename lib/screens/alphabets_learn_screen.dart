import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alphabets_provider.dart';
import '../widgets/word_card.dart';

class AlphabetsLearnScreen extends StatelessWidget {
  const AlphabetsLearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alphProv = Provider.of<AlphabetsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Alphabet')),
      body: FutureBuilder(
        future: alphProv.loadCourse(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (alphProv.letters.isEmpty) {
            return const Center(child: Text('No alphabet data'));
          }

          return PageView.builder(
            itemCount: alphProv.letters.length,
            controller: PageController(initialPage: alphProv.currentIndex),
            onPageChanged: (idx) => alphProv.goTo(idx),
            itemBuilder: (_, i) => WordCard(word: alphProv.letters[i]),
          );
        },
      ),
    );
  }
}