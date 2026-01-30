import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';

class ProgressProvider extends ChangeNotifier {
  static const String _prefsKey = 'user_progress';
  late UserProgress _progress;
  bool _isInitialized = false;

  UserProgress get progress => _progress;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        _progress = UserProgress.fromJson(json);
      } catch (e) {
        _progress = UserProgress();
      }
    } else {
      _progress = UserProgress();
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_progress.toJson()));
  }

  void addStar() {
    _progress.stars = (_progress.stars + 1).clamp(0, 5);
    _save();
    notifyListeners();
  }

  void addSeenWord() {
    _progress.completedWords += 1;
    _save();
    notifyListeners();
  }

  Future<void> reset() async {
    _progress = UserProgress();
    await _save();
    notifyListeners();
  }
}
