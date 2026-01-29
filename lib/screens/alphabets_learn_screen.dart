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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final alphProv = Provider.of<AlphabetsProvider>(context, listen: false);
    _pageController = PageController(initialPage: alphProv.currentIndex);

    // Load the course data once when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Loading alphabets course...');
      alphProv.loadCourse();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alphProv = Provider.of<AlphabetsProvider>(context);
    print('Building AlphabetsLearnScreen, letters length: ${alphProv.letters.length}');

    return Scaffold(
      appBar: AppBar(title: const Text('Learn Alphabet')),
      body: alphProv.letters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: alphProv.letters.length,
              controller: _pageController,
              onPageChanged: (idx) => alphProv.goTo(idx),
              itemBuilder: (_, i) => WordCard(word: alphProv.letters[i]),
            ),
    );
  }
}