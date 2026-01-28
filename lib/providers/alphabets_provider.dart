import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../models/word.dart';

class AlphabetsProvider extends ChangeNotifier {
    
  List<Word> _letters = [];
  int _currentIndex = 0;

  List<Word> get letters => _letters;
  int get currentIndex => _currentIndex;
  Word get currentLetter => _letters[_currentIndex];

  Future<void> loadCourse() async {
    try {
      final raw = await rootBundle.loadString('assets/data/alphabets_course.json');
      final List<dynamic> jsonList = jsonDecode(raw);
      _letters = jsonList.map((e) => Word.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading alphabets course: $e');
    }
  }

  void goTo(int idx) {
    if (idx >= 0 && idx < _letters.length) {
      _currentIndex = idx;
      notifyListeners();
    }
  }

  void next() {
    if (_currentIndex < _letters.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }
}