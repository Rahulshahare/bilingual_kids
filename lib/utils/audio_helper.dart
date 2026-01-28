import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAsset(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // ignore errors in demo
    }
  }
}