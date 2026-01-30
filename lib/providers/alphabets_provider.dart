import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../models/word.dart';

class AlphabetsProvider extends ChangeNotifier {
  List<Word> _letters = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  List<Word> get letters => _letters;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  
  Word? get currentLetter {
    if (_letters.isEmpty || _currentIndex < 0 || _currentIndex >= _letters.length) {
      return null;
    }
    return _letters[_currentIndex];
  }

  Future<void> loadCourse() async {
    if (_isLoading || _letters.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final raw = await rootBundle.loadString('assets/data/alphabets_course.json');
      final List<dynamic> jsonList = jsonDecode(raw);
      _letters = jsonList.map((e) => Word.fromJson(e)).toList();
      _currentIndex = 0;
      print('Loaded ${_letters.length} alphabet letters');
    } catch (e) {
      print('Error loading alphabets course: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
