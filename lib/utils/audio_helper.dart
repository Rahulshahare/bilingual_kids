import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAsset(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      await _player.play(BytesSource(bytes));
    } catch (e) {
      // ignore errors in demo
    }
  }
}