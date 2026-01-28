import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/progress.dart';

class ProgressProvider extends ChangeNotifier {
  late Box<UserProgress> _box;
  late UserProgress _progress;

  UserProgress get progress => _progress;

  Future<void> init() async {
    _box = await Hive.openBox<UserProgress>('progress');
    if (_box.isEmpty) {
      _progress = UserProgress();
      await _box.add(_progress);
    } else {
      _progress = _box.getAt(0)!;
    }
    notifyListeners();
  }

  void addStar() {
    _progress.stars = (_progress.stars + 1).clamp(0, 5);
    _progress.save();
    notifyListeners();
  }

  void addSeenWord() {
    _progress.completedWords += 1;
    _progress.save();
    notifyListeners();
  }

  Future<void> reset() async {
    await _progress.delete();
    _progress = UserProgress();
    await _box.add(_progress);
    notifyListeners();
  }
}