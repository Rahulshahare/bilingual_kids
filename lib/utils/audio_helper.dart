import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  /// Play a bundled asset (e.g. assets/audio/apfel.mp3 or audio/apfel.mp3 or apfel.mp3)
  static Future<void> playAsset(String assetPath) async {
    try {
      // Determine the key to check in the asset bundle
      String checkKey = assetPath;
      if (!checkKey.startsWith('assets/')) {
        checkKey = 'assets/$checkKey';
      }

      // Try to load the asset to ensure it exists
      try {
        await rootBundle.load(checkKey);
      } catch (e) {
        // ignore: avoid_print
        print('Audio asset not found in bundle: $checkKey');
        return;
      }

      // Prepare the relative path for AssetSource (audioplayers expects path relative to assets/)
      var relative = checkKey.replaceFirst(RegExp(r'^assets/'), '');
      // Ensure it points into the audio/ subfolder
      if (!relative.startsWith('audio/')) {
        relative = 'audio/$relative';
      }

      // Stop any currently playing audio
      try {
        await _player.stop();
      } catch (_) {}

      await _player.play(AssetSource(relative));
    } catch (e, st) {
      // ignore: avoid_print
      print('AudioHelper.playAsset error: $e\n$st');
    }
  }
}