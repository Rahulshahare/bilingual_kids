import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alphabets_provider.dart';
import '../widgets/word_card.dart';

class AlphabetsLearnScreen extends StatefulWidget {
  const AlphabetsLearnScreen({super.key});

  @override
  State<AlphabetsLearnScreen> createState() => _AlphabetsLearnScreenState();
}

class _AlphabetsLearnScreenState extends State<AlphabetsLearnScreen> {
  @override
  void initState() {
    super.initState();
    // Load the course data once when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlphabetsProvider>(context, listen: false).loadCourse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alphProv = Provider.of<AlphabetsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Alphabet')),
      body: alphProv.letters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: alphProv.letters.length,
              controller: PageController(initialPage: alphProv.currentIndex),
              onPageChanged: (idx) => alphProv.goTo(idx),
              itemBuilder: (_, i) => WordCard(word: alphProv.letters[i]),
            ),
    );
  }
}