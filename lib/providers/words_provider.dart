import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/word.dart';

class WordsProvider extends ChangeNotifier {
  List<Word> _words = [];
  int _currentIndex = 0;

  List<Word> get words => _words;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }
  
  Word? get currentWord {
    if (_words.isEmpty || _currentIndex < 0 || _currentIndex >= _words.length) {
      return null;
    }
    return _words[_currentIndex];
  }

  Future<void> loadLocal() async {
    try {
      final raw = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = jsonDecode(raw);
      _words = jsonList.map((e) => Word.fromJson(e)).toList();
      _currentIndex = 0;

      for (var w in _words) {
        print('Loaded word: native=${w.native}, english=${w.english}, image=${w.image}, audioNative=${w.audioNative}, audioEnglish=${w.audioEnglish}');
      }

      notifyListeners();
    } catch (e) {
      print('Error loading local words: $e');
    }
  }

  Future<void> loadRemote(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _words = jsonList.map((e) => Word.fromJson(e)).toList();
        _currentIndex = 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading remote words: $e');
    }
  }

  void next() {
    if (_currentIndex < _words.length - 1) {
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
