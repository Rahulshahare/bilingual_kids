import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/word.dart';
import '../utils/audio_helper.dart';

class WordCard extends StatelessWidget {
  final Word word;
  const WordCard({super.key, required this.word});

  String _ensureAssetImage(String path) {
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('/')) return 'assets${path}';
    if (path.startsWith('images/') || path.startsWith('audio/')) {
      return 'assets/$path';
    }
    return 'assets/images/$path';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _ensureAssetImage(word.image);

    Widget imageWidget;
    if (imagePath.toLowerCase().endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        semanticsLabel: word.native,
        placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          // ignore: avoid_print
          print('Failed to load image asset: $imagePath -> $error');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.broken_image, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image not found', textAlign: TextAlign.center),
              ],
            ),
          );
        },
      );
    }

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: imageWidget),
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
                  onPressed: () {
                    if (word.audioNative.isNotEmpty) {
                      AudioHelper.playAsset(word.audioNative);
                    }
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.orange),
                  tooltip: 'Hear English',
                  onPressed: () {
                    if (word.audioEnglish.isNotEmpty) {
                      AudioHelper.playAsset(word.audioEnglish);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}