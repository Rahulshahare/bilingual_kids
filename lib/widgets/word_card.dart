import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/audio_helper.dart';

class WordCard extends StatelessWidget {
  final Word word;
  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                word.image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              word.native,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              word.english,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.deepPurple),
                  tooltip: 'Hear native',
                  onPressed: () => AudioHelper.playAsset(word.audioNative),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.orange),
                  tooltip: 'Hear English',
                  onPressed: () => AudioHelper.playAsset(word.audioEnglish),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}