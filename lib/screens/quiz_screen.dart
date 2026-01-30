import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import '../models/word.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Word> _questions;
  int _current = 0;
  int _score = 0;
  Word? _selected;

  @override
  void initState() {
    super.initState();
    final all = Provider.of<WordsProvider>(context, listen: false).words;
    _questions = List<Word>.from(all)..shuffle();
    if (_questions.length > 10) _questions = _questions.sublist(0, 10);
  }

  void _checkAnswer() {
    if (_selected == null) return;
    if (_selected!.native == _questions[_current].native) {
      _score++;
      Provider.of<ProgressProvider>(context, listen: false).addStar();
    }
    setState(() {
      _selected = null;
      if (_current < _questions.length - 1) {
        _current++;
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Finished!'),
            content: Text('You scored $_score / ${_questions.length}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to Home'),
              )
            ],
          ),
        );
      }
    });
  }

  List<Word> _optionsFor(int idx) {
    final correct = _questions[idx];
    final all = Provider.of<WordsProvider>(context, listen: false).words;
    final wrong = (all.where((w) => w.native != correct.native).toList()..shuffle())
        .take(3)
        .toList();
    wrong.add(correct);
    wrong.shuffle();
    return wrong;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Quiz')), body: const Center(child: Text('No words available')));
    }

    final word = _questions[_current];
    final options = _optionsFor(_current);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Which picture matches: "${word.english}" ?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  return RadioListTile<Word>(
                    title: Image.asset(opt.image, height: 80),
                    value: opt,
                    groupValue: _selected,
                    onChanged: (val) => setState(() => _selected = val),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selected == null ? null : _checkAnswer,
              child: const Text('Check'),
            ),
            const SizedBox(height: 12),
            Text('Score: $_score / ${_questions.length}'),
          ],
        ),
      ),
    );
  }
}