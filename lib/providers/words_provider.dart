import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/word.dart';

class WordsProvider extends ChangeNotifier {
  List<Word> _words = [];
  int _currentIndex = 0;

  List<Word> get words => _words;
  int get currentIndex => _currentIndex;
  Word get currentWord => _words[_currentIndex];

  Future<void> loadLocal() async {
    try {
      final raw = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> jsonList = jsonDecode(raw);
      _words = jsonList.map((e) => Word.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> loadRemote(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      _words = jsonList.map((e) => Word.fromJson(e)).toList();
      final box = await Hive.openBox<Word>('remote_words');
      await box.clear();
      await box.addAll(_words);
      notifyListeners();
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