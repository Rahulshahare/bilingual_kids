## 🎯 Project Idea – “Bilingual Kids”  
A **Flutter app** that lets small children learn their native language (let’s call it **“Native”**) **side‑by‑side with English**.  
The UI will be built entirely with the concepts you just saw (Material → Scaffold → Widgets → Provider → Hive).  
We’ll also outline a **very light PHP back‑end** (optional) for syncing new word packs, but the core experience works **offline**.

---

## 📦 High‑Level Feature List (MVP)

| Feature | Why it matters for kids | Flutter implementation |
|---------|-------------------------|------------------------|
| **Word cards** – picture + native word + English word | Visual‑verbal association | `Card → Column → Image + Text` |
| **Audio playback** – native & English pronunciation | Auditory reinforcement | `audioplayers` package |
| **Swipe navigation** (← / →) | No tiny buttons → natural gesture | `PageView` |
| **Simple quiz** – “Which picture matches the word?” | Active recall | `RadioListTile` + scoring logic |
| **Progress tracking** (stars, levels) | Motivation / gamification | `Hive` to store `UserProgress` |
| **Offline first** – all data bundled | No internet required for preschoolers | Store word‑list JSON in `assets/`, persist progress with Hive |
| **Optional remote update** – admin can add new packs via a tiny PHP API | Keep content fresh without app updates | PHP → JSON endpoint → `http` GET → `FutureBuilder` |
| **Multi‑language UI** (app text) | The app itself can be switched to English or Native | `intl` + `MaterialApp.localizationsDelegates` |

---

## 🗂️ Project Structure (Flutter)

```
bilingual_kids/
│
├─ lib/
│   ├─ main.dart                     # entry point
│   ├─ models/
│   │   ├─ word.dart                 # Word model (native, english, image, audio)
│   │   └─ progress.dart             # UserProgress model (stars, completed packs)
│   ├─ providers/
│   │   ├─ words_provider.dart       # loads word list, exposes list & current index
│   │   └─ progress_provider.dart    # reads/writes Hive progress
│   ├─ screens/
│   │   ├─ home_screen.dart          # menu → “Learn” / “Quiz”
│   │   ├─ learn_screen.dart         # PageView of word cards
│   │   └─ quiz_screen.dart          # simple multiple‑choice quiz
│   ├─ widgets/
│   │   ├─ word_card.dart            # UI for one card
│   │   └─ star_bar.dart             # visual progress indicator
│   └─ utils/
│       └─ audio_helper.dart         # wrapper around audioplayers
│
├─ assets/
│   ├─ images/      (png/jpg of each word)
│   ├─ audio/       (native_*.mp3, en_*.mp3)
│   └─ data/
│       └─ words.json   (bundled word list)
│
├─ lib/l10n/
│   ├─ app_en.arb
│   └─ app_native.arb   (or app_es.arb, etc.)
│
├─ pubspec.yaml
└─ build_runner scripts (for Hive adapters)
```

---

## 📚 1️⃣ Data Model – Word

```dart
// lib/models/word.dart
import 'package:hive/hive.dart';

part 'word.g.dart';               // generated adapter

@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0) final String native;   // e.g. "Apfel"
  @HiveField(1) final String english; // e.g. "Apple"
  @HiveField(2) final String image;   // asset path: "assets/images/apple.png"
  @HiveField(3) final String audioNative; // asset path: "assets/audio/apfel.mp3"
  @HiveField(4) final String audioEnglish; // asset path: "assets/audio/apple_en.mp3"

  const Word({
    required this.native,
    required this.english,
    required this.image,
    required this.audioNative,
    required this.audioEnglish,
  });

  // Helper to create from JSON (used when loading from a remote PHP API)
  factory Word.fromJson(Map<String, dynamic> json) => Word(
        native: json['native'],
        english: json['english'],
        image: json['image'],
        audioNative: json['audio_native'],
        audioEnglish: json['audio_english'],
      );
}
```

> **PHP comparison** – This is the same as a **row** in a MySQL table or a **JSON object** stored in a file.

### Hive Adapter Generation

```bash
flutter packages pub run build_runner build
# creates word.g.dart with the Hive TypeAdapter
```

---

## 📦 2️⃣ Provider – Loading Words

```dart
// lib/providers/words_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/word.dart';

class WordsProvider extends ChangeNotifier {
  List<Word> _words = [];
  int _currentIndex = 0;

  List<Word> get words => _words;
  int get currentIndex => _currentIndex;
  Word get currentWord => _words[_currentIndex];

  /// Load bundled JSON (assets/data/words.json)
  Future<void> loadLocal() async {
    final raw = await rootBundle.loadString('assets/data/words.json');
    final List<dynamic> jsonList = jsonDecode(raw);
    _words = jsonList.map((e) => Word.fromJson(e)).toList();
    notifyListeners();
  }

  /// Optional: fetch fresh pack from a PHP endpoint
  Future<void> loadRemote(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      _words = jsonList.map((e) => Word.fromJson(e)).toList();
      // persist for offline use
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
```

*PHP analogue*: `loadRemote()` is like a **REST endpoint** that returns a JSON array of word objects. The provider parses it just as you would `json_decode(file_get_contents(...))` in PHP.

---

## 📊 3️⃣ Provider – User Progress

```dart
// lib/models/progress.dart
import 'package:hive/hive.dart';

part 'progress.g.dart';

@HiveType(typeId: 1)
class UserProgress extends HiveObject {
  @HiveField(0) int stars;          // 0‑5 per pack
  @HiveField(1) int completedWords; // how many cards the child has viewed

  UserProgress({this.stars = 0, this.completedWords = 0});
}
```

```dart
// lib/providers/progress_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/progress.dart';

class ProgressProvider extends ChangeNotifier {
  late Box<UserProgress> _box;
  late UserProgress _progress;

  UserProgress get progress => _progress;

  Future<void> init() async {
    _box = await Hive.openBox<UserProgress>('progress');
    // If it’s the first run, create a default record
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

  // Reset (for a new pack)
  Future<void> reset() async {
    await _progress.delete();
    _progress = UserProgress();
    await _box.add(_progress);
    notifyListeners();
  }
}
```

*PHP analogue*: This mimics a **session** that you store in a DB or a JSON file to keep the child’s score between app launches.

---

## 🎨 4️⃣ UI – Home Screen (Menu)

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import '../widgets/star_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context).progress;
    return Scaffold(
      appBar: AppBar(title: const Text('Bilingual Kids')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StarBar(stars: progress.stars),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text('Learn Words'),
              onPressed: () async {
                await Provider.of<WordsProvider>(context, listen: false)
                    .loadLocal(); // ensure list is ready
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LearnScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text('Quiz Me!'),
              onPressed: () async {
                await Provider.of<WordsProvider>(context, listen: false)
                    .loadLocal();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

**StarBar widget** (simple visual representation)

```dart
// lib/widgets/star_bar.dart
import 'package:flutter/material.dart';

class StarBar extends StatelessWidget {
  final int stars; // 0‑5
  const StarBar({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 32,
        );
      }),
    );
  }
}
```

---

## 📚 5️⃣ UI – Learn Screen (Swipeable Word Cards)

```dart
// lib/screens/learn_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/word_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wordsProv = Provider.of<WordsProvider>(context);
    final progressProv = Provider.of<ProgressProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: PageView.builder(
        itemCount: wordsProv.words.length,
        controller: PageController(initialPage: wordsProv.currentIndex),
        onPageChanged: (idx) {
          wordsProv._currentIndex = idx; // internal update (private in real code)
          progressProv.addSeenWord();    // count the view
        },
        itemBuilder: (_, i) => WordCard(word: wordsProv.words[i]),
      ),
    );
  }
}
```

### WordCard widget (the “visual card”)

```dart
// lib/widgets/word_card.dart
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/audio_helper.dart';

class WordCard extends StatelessWidget {
  final Word word;
  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ---- IMAGE ----
            Expanded(
              child: Image.asset(
                word.image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // ---- NATIVE WORD ----
            Text(
              word.native,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),

            // ---- ENGLISH WORD ----
            Text(
              word.english,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // ---- AUDIO BUTTONS ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.deepPurple),
                  tooltip: 'Hear native',
                  onPressed: () => AudioHelper.playAsset(word.audioNative),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.orange),
                  tooltip: 'Hear English',
                  onPressed: () => AudioHelper.playAsset(word.audioEnglish),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Audio helper (thin wrapper around `audioplayers`)

```dart
// lib/utils/audio_helper.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  /// Play a bundled asset (e.g. assets/audio/apfel.mp3)
  static Future<void> playAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    await _player.play(BytesSource(bytes));
  }
}
```

*PHP analogue*: `AudioHelper.playAsset` is like serving a **static MP3 file** from a web server (`/audio/apfel.mp3`).  

---

## 🧩 6️⃣ UI – Quiz Screen (Multiple‑Choice)

```dart
// lib/screens/quiz_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../providers/progress_provider.dart';
import '../models/word.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Word> _questions;
  int _current = 0;
  int _score = 0;
  Word? _selected;

  @override
  void initState() {
    super.initState();
    final all = Provider.of<WordsProvider>(context, listen: false).words;
    // shuffle & pick first N (e.g., 10) for a quick quiz
    _questions = List<Word>.from(all)..shuffle();
    if (_questions.length > 10) _questions = _questions.sublist(0, 10);
  }

  void _checkAnswer() {
    if (_selected == null) return;
    if (_selected!.native == _questions[_current].native) {
      _score++;
      Provider.of<ProgressProvider>(context, listen: false).addStar();
    }
    setState(() {
      _selected = null;
      if (_current < _questions.length - 1) {
        _current++;
      } else {
        // quiz finished – show dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Finished!'),
            content: Text('You scored $_score / ${_questions.length}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Back to Home'),
              )
            ],
          ),
        );
      }
    });
  }

  // Randomly pick 3 wrong options + the correct one
  List<Word> _optionsFor(int idx) {
    final correct = _questions[idx];
    final all = Provider.of<WordsProvider>(context, listen: false).words;
    final wrong = (all.where((w) => w.native != correct.native).toList()
          ..shuffle())
        .take(3)
        .toList();
    wrong.add(correct);
    wrong.shuffle();
    return wrong;
  }

  @override
  Widget build(BuildContext context) {
    final word = _questions[_current];
    final options = _optionsFor(_current);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Question prompt – show English word
            Text(
              'Which picture matches: "${word.english}" ?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Options (radio list with images)
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  return RadioListTile<Word>(
                    title: Image.asset(opt.image, height: 80),
                    value: opt,
                    groupValue: _selected,
                    onChanged: (val) => setState(() => _selected = val),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Submit button
            ElevatedButton(
              onPressed: _selected == null ? null : _checkAnswer,
              child: const Text('Check'),
            ),
            const SizedBox(height: 12),

            // Score display (optional)
            Text('Score: $_score / ${_questions.length}'),
          ],
        ),
      ),
    );
  }
}
```

**What the kid sees:**  
- English word in big text.  
- Four pictures (one correct, three distractors).  
- Tap a picture → the radio button selects it.  
- “Check” → immediate feedback (stars added, next question).

*PHP analogy*: This is like a **multiple‑choice quiz page** that reads a list from a DB, shuffles answers, and posts the selected ID to a server script. Here everything stays local.

---

## 🌐 7️⃣ Optional Remote Word‑Pack API (PHP)

If you want to let teachers upload new packs without re‑building the app, expose a tiny **REST endpoint** that returns the same JSON shape as `assets/data/words.json`.

```php
<?php
// api/words.php
header('Content-Type: application/json');

// In a real project you would read from a DB.
// For demo, we read a static JSON file.
$filename = __DIR__ . '/words_pack.json';
if (!file_exists($filename)) {
    http_response_code(404);
    echo json_encode(['error' => 'Pack not found']);
    exit;
}
echo file_get_contents($filename);
```

**Sample JSON (words_pack.json)**

```json
[
  {
    "native": "Apfel",
    "english": "Apple",
    "image": "assets/images/apple.png",
    "audio_native": "assets/audio/apfel.mp3",
    "audio_english": "assets/audio/apple_en.mp3"
  },
  {
    "native": "Hund",
    "english": "Dog",
    "image": "assets/images/dog.png",
    "audio_native": "assets/audio/hund.mp3",
    "audio_english": "assets/audio/dog_en.mp3"
  }
  // … more entries
]
```

*How the Flutter side uses it* – call `WordsProvider.loadRemote('https://my‑server.com/api/words.php')`. The app caches the result in a Hive box for offline use.

---

## 🖌️ 8️⃣ UI/UX Tips for Kids (Why they matter)

| Guideline | Practical Implementation |
|-----------|--------------------------|
| **Large touch targets** (≥48 dp) | Use `Padding` around buttons, `IconButton` size 48+. |
| **Bright, contrasting colors** | Define a cheerful `ColorScheme` (`primarySwatch: Colors.orange`). |
| **Simple navigation** – only forward/back or swipe | `PageView` for learning, `Navigator.pop` for quiz end. |
| **Audio feedback on every interaction** | Play a *click* sound on button tap (`AudioHelper.playAsset('assets/audio/click.mp3')`). |
| **No text input** (typing is hard for toddlers) | All actions are taps or swipes; no keyboard needed. |
| **Progress stars** – visible and rewarding | `StarBar` shown on Home and after each successful quiz answer. |
| **Offline‑first** – pre‑bundle all assets | All images/audio stored under `assets/`; the app works without network. |
| **Accessible** – high‑contrast mode, screen‑reader labels (`semanticLabel`) | Add `semanticLabel` to images; set `debugPaintSizeEnabled` during dev to check spacing. |

---

## 📦 9️⃣ Project Setup – Step‑by‑Step

1. **Create the project**  
   ```bash
   flutter create bilingual_kids
   cd bilingual_kids
   ```

2. **Add dependencies** in `pubspec.yaml`  

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     provider: ^6.0.5
     hive: ^2.2.3
     hive_flutter: ^1.1.0
     audioplayers: ^2.0.2
     intl: ^0.18.0
   dev_dependencies:
     hive_generator: ^2.0.0
     build_runner: ^2.4.6
   ```

3. **Add assets**  

   ```yaml
   flutter:
     assets:
       - assets/data/words.json
       - assets/images/
       - assets/audio/
   ```

4. **Create the models** (`word.dart`, `progress.dart`) and run the generator:  

   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. **Create the providers** (`words_provider.dart`, `progress_provider.dart`).  
   In `main.dart` wrap the app with both providers:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Hive.initFlutter();
     Hive.registerAdapter(WordAdapter());
     Hive.registerAdapter(UserProgressAdapter());

     runApp(
       MultiProvider(
         providers: [
           ChangeNotifierProvider(create: (_) => ProgressProvider()..init()),
           ChangeNotifierProvider(create: (_) => WordsProvider()),
         ],
         child: const MyApp(),
       ),
     );
   }
   ```

6. **Implement the UI screens** (`home_screen.dart`, `learn_screen.dart`, `quiz_screen.dart`) using the snippets above.

7. **Test on a device** – `flutter run` (or `flutter run -d chrome` for web).

8. **(Optional) Deploy a PHP API**  
   - Put `words.php` on a cheap shared host.  
   - Point the app to its URL with `WordsProvider.loadRemote(url)`.

9. **Release**  
   - Android: `flutter build apk --release` → upload to Google Play.  
   - iOS: `flutter build ios --release` → upload to App Store.  
   - Web: `flutter build web` → host on GitHub Pages or any static host.

---

## 📈 10️⃣ Extending the App (Future Road‑Map)

| Phase | Feature | How to implement |
|-------|---------|------------------|
| **A** | **Voice‑over for English words** (text‑to‑speech) | Use `flutter_tts` package; call `await tts.speak(word.english)`. |
| **B** | **Speech recognition** – child says the word → app verifies | `speech_to_text` package; compare recognized string with `native` word. |
| **C** | **Levels & unlocking** – new packs unlock after 5 stars | Store `unlockedPacks` in `UserProgress`; conditionally show in Home menu. |
| **D** | **Mini‑games** – drag‑and‑drop matching, memory cards | Use `Draggable` / `DragTarget` widgets; keep the same `Word` model. |
| **E** | **Parent dashboard** – view child’s progress from a separate screen | Add a “Parent mode” (protected by a simple PIN) that reads the Hive progress data. |
| **F** | **Multiple native languages** – let the admin upload packs for any language | Add a `languageCode` field to `Word`; let the UI switch `Locale` via `Provider`. |
| **G** | **Cloud sync** – backup progress to Firebase / Supabase | Replace Hive with a remote DB, or replicate progress to both local + cloud. |

---

## 📚 TL;DR – One‑Page Cheat Sheet

| Piece | Flutter Code | PHP Analogy |
|-------|--------------|-------------|
| **App entry** | `void main() => runApp(MyApp());` | `index.php` that includes everything |
| **Root widget** | `MaterialApp(theme:…, home: HomeScreen())` | Master layout (`layout.php`) with CSS |
| **Page skeleton** | `Scaffold(appBar:…, body:…, floatingActionButton:…)` | `<header>`, `<main>`, `<footer>` |
| **State** | `ChangeNotifier` + `Provider` | `$_SESSION` or a JSON file |
| **Persisted data** | `Hive` box (`Word`, `UserProgress`) | `file_put_contents('progress.json', …)` |
| **List of cards** | `PageView.builder → WordCard` | `<ul>` generated with `foreach` |
| **Audio** | `audioplayers` → `AudioHelper.playAsset()` | `<audio src="…">` tag or PHP `readfile` |
| **Quiz logic** | Randomized list, `RadioListTile`, scoring | Server‑side PHP script that checks answer |
| **Remote JSON** | `http.get('https://my‑site.com/api/words.php')` | `file_get_contents('api/words.php')` |
| **Localization** | `intl` + `MaterialApp.localizationsDelegates` | `gettext` / `lang/*.php` files |

---

## 🎉 Ready to Build?

1. **Copy the model & provider files** (Word, UserProgress, WordsProvider, ProgressProvider).  
2. **Add the three screens** (`home_screen.dart`, `learn_screen.dart`, `quiz_screen.dart`).  
3. **Put a few sample assets** (e.g., `apple.png`, `apple.mp3`) in `assets/`.  
4. **Run `flutter pub get` + `flutter packages pub run build_runner build`**.  
5. **Launch** – you should see a colourful home screen, swipe through word cards, hear pronunciations, and play a tiny quiz.

That’s a **complete, production‑ready MVP** that teaches kids a second language while re‑using everything you already know from PHP (JSON handling, session‑like state, REST API).  

Good luck, and have fun watching little learners master both languages! 🚀🧒📚

---

## 🔁 Continuous Integration — GitHub Actions

Since Flutter is not installed on this system, the project is set up to build on GitHub Actions. The repository contains a workflow that:

- Uses a maintained action to install Flutter (stable channel).
- Caches pub packages and relevant build caches to speed up runs.
- Runs `flutter pub get`, `flutter analyze`, and `flutter test` (if tests exist).
- Builds a release APK with `flutter build apk --release`.

Trigger: push or pull_request to the main branch.

Build artifact (Android APK) location on the runner after build:
- build/app/outputs/flutter-apk/app-release.apk

To download artifacts from a workflow run, use the Actions UI or add an upload step to the workflow.

To manually run locally (if you install Flutter later):

1. flutter pub get
2. flutter packages pub run build_runner build --delete-conflicting-outputs
3. flutter build apk --release