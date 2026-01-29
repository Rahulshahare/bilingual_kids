import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  /// Play a bundled asset (e.g. assets/audio/apple_en.wav)
  static Future<void> playAsset(String assetPath) async {
    try {
      // Ensure the path starts with 'assets/' for checking in the bundle
      String fullPath = assetPath;
      if (!fullPath.startsWith('assets/')) {
        fullPath = 'assets/$fullPath';
      }

      // Verify the asset exists in the bundle
      try {
        await rootBundle.load(fullPath);
      } catch (e) {
        // ignore: avoid_print
        print('Audio asset not found in bundle: $fullPath');
        return;
      }

      // Prepare the path for AssetSource (audioplayers expects path relative to assets/)
      final relativePath = fullPath.replaceFirst('assets/', '');

      // Stop any currently playing audio
      try {
        await _player.stop();
      } catch (_) {}

      await _player.play(AssetSource(relativePath));
    } catch (e, st) {
      // ignore: avoid_print
      print('AudioHelper.playAsset error: $e\n$st');
    }
  }
}