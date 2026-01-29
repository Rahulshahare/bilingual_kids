# Bilingual Kids 🎓

A Flutter-based educational mobile application designed to help children learn languages through interactive flashcards, audio pronunciation, quizzes, and alphabet learning. The app supports bilingual education with English and Marathi (native language), featuring an offline-first architecture.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development](#development)
- [Architecture](#architecture)
- [Data Models](#data-models)
- [Screens](#screens)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

**Bilingual Kids** is an educational app that enables young children to learn their native language alongside English through visual and auditory learning methods. The app is designed with a child-friendly interface, featuring:

- Interactive word cards with images
- Audio pronunciation in both languages
- Swipe-based navigation
- Gamified progress tracking with stars
- Quiz mode for active recall
- Alphabet learning module
- Complete offline functionality

## ✨ Features

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Word Cards** | Picture + native word + English word | Visual-verbal association |
| **Audio Playback** | Native & English pronunciation | Auditory reinforcement |
| **Swipe Navigation** | Left/right swipe to navigate cards | Natural gesture for kids |
| **Quiz Mode** | Multiple-choice questions | Active recall & testing |
| **Progress Tracking** | Stars and completion tracking | Motivation & gamification |
| **Alphabet Learning** | A-Z with audio and visuals | Foundation for reading |
| **Offline First** | All data bundled in app | No internet required |
| **Persistent Storage** | Hive database for progress | Data survives app restarts |

## 🛠 Tech Stack

### Core Technologies
- **Flutter** - Cross-platform mobile UI framework
- **Dart** - Programming language (SDK >=2.17.0 <4.0.0)

### State Management
- **Provider** (^6.0.5) - State management solution

### Data Persistence
- **Hive** (^2.2.3) - Lightweight, fast NoSQL database
- **Hive Flutter** (^1.1.0) - Flutter integration for Hive

### Media & Assets
- **Audioplayers** (^6.5.1) - Audio playback functionality
- **Flutter SVG** (^1.1.6) - SVG image rendering

### Utilities
- **Intl** (^0.18.0) - Internationalization support
- **HTTP** (^0.13.6) - Network requests (for future remote updates)

### Development Tools
- **Build Runner** (^2.4.6) - Code generation
- **Hive Generator** (^2.0.0) - Hive adapter generation

## 📁 Project Structure

```
bilingual_kids/
│
├── lib/
│   ├── main.dart                          # App entry point
│   ├── l10n/                              # Localization files
│   ├── models/                            # Data models
│   │   ├── word.dart                      # Word model with Hive adapter
│   │   └── progress.dart                  # User progress model
│   ├── providers/                         # State management
│   │   ├── words_provider.dart            # Word list management
│   │   ├── progress_provider.dart         # Progress tracking
│   │   └── alphabets_provider.dart        # Alphabet data management
│   ├── screens/                           # UI screens
│   │   ├── home_screen.dart               # Main menu
│   │   ├── learn_screen.dart              # Word learning cards
│   │   ├── quiz_screen.dart               # Quiz interface
│   │   └── alphabets_learn_screen.dart    # Alphabet learning
│   ├── widgets/                           # Reusable widgets
│   │   ├── word_card.dart                 # Individual word card
│   │   └── star_bar.dart                  # Progress star display
│   └── utils/                             # Utility functions
│       └── audio_helper.dart              # Audio playback wrapper
│
├── assets/
│   ├── images/                            # Word images (JPG, SVG)
│   │   ├── Apple_eng.jpg
│   │   ├── DOG_eng.jpg
│   │   └── alphabets/                     # A-Z alphabet images
│   ├── audio/                             # Audio files
│   │   ├── Apple_eng.wav
│   │   ├── Apple_mar.wav
│   │   ├── Dog_eng.wav
│   │   ├── Dog_mar.wav
│   │   └── alphabets/                     # A-Z alphabet audio
│   └── data/                              # JSON data files
│       ├── words.json                     # Word list data
│       └── alphabets_course.json          # Alphabet course data
│
├── .github/
│   └── workflows/                         # CI/CD workflows
│       └── flutter-ci.yml
│
├── pubspec.yaml                           # Flutter dependencies
├── .gitignore
├── project.md                             # Project documentation
├── assistant_reference.md                # Development reference
└── README.md                              # This file
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0 <4.0.0)
- Android Studio / VS Code with Flutter extension
- Android SDK (for Android builds)
- Xcode (for iOS builds - macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bilingual_kids
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 💻 Development

### Code Generation

The project uses `build_runner` to generate Hive adapters. After modifying models:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### CI/CD

The project includes GitHub Actions workflow (`.github/workflows/flutter-ci.yml`) that:
- Installs Flutter (stable channel)
- Caches pub dependencies
- Runs `flutter pub get`
- Executes code analysis
- Runs tests
- Builds release APK

## 🏗 Architecture

### State Management Pattern

The app uses the **Provider** pattern for state management:

```
┌─────────────────────────────────────────┐
│           MaterialApp                    │
│  ┌───────────────────────────────────┐  │
│  │      MultiProvider                │  │
│  │  ┌─────────────────────────────┐ │  │
│  │  │  ProgressProvider            │ │  │
│  │  │  - UserProgress (Hive)       │ │  │
│  │  └─────────────────────────────┘ │  │
│  │  ┌─────────────────────────────┐ │  │
│  │  │  WordsProvider              │ │  │
│  │  │  - List<Word>               │ │  │
│  │  │  - Current index            │ │  │
│  │  └─────────────────────────────┘ │  │
│  │  ┌─────────────────────────────┐ │  │
│  │  │  AlphabetsProvider          │ │  │
│  │  │  - Alphabet data            │ │  │
│  │  └─────────────────────────────┘ │  │
│  └───────────────────────────────────┘  │
│           │                              │
│           ▼                              │
│  ┌───────────────────────────────────┐  │
│  │         Screens                   │  │
│  │  - HomeScreen                     │  │
│  │  - LearnScreen                    │  │
│  │  - QuizScreen                     │  │
│  │  - AlphabetsLearnScreen           │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Data Flow

1. **Initialization**: [`main.dart`](lib/main.dart:1) initializes Hive and registers adapters
2. **Loading**: Providers load data from assets (JSON) or Hive database
3. **Display**: Screens consume provider data via `Provider.of()`
4. **Interaction**: User actions update provider state
5. **Persistence**: Changes are saved to Hive automatically

### Offline-First Design

- All word data is bundled in `assets/data/`
- Audio files are included in `assets/audio/`
- Images are stored in `assets/images/`
- User progress persists in local Hive database
- No network connection required for core functionality

## 📊 Data Models

### Word Model

Located in [`lib/models/word.dart`](lib/models/word.dart:1)

```dart
@HiveType(typeId: 0)
class Word extends HiveObject {
  final String native;          // Native language word (e.g., "सेब")
  final String english;         // English translation (e.g., "Apple")
  final String image;           // Image asset path
  final String audioNative;     // Native audio path
  final String audioEnglish;    // English audio path
}
```

### UserProgress Model

Located in [`lib/models/progress.dart`](lib/models/progress.dart:1)

```dart
@HiveType(typeId: 1)
class UserProgress extends HiveObject {
  int stars;              // 0-5 stars earned
  int completedWords;     // Number of words viewed
}
```

## 📱 Screens

### Home Screen
- **File**: [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart:1)
- **Purpose**: Main menu with navigation options
- **Features**: Star display, Learn Words, Quiz Me!, Learn Alphabet buttons

### Learn Screen
- **File**: [`lib/screens/learn_screen.dart`](lib/screens/learn_screen.dart:1)
- **Purpose**: Interactive word learning with swipeable cards
- **Features**: PageView navigation, word cards, audio playback

### Quiz Screen
- **File**: [`lib/screens/quiz_screen.dart`](lib/screens/quiz_screen.dart:1)
- **Purpose**: Multiple-choice quiz for testing knowledge
- **Features**: Random questions, scoring, star rewards

### Alphabets Learn Screen
- **File**: [`lib/screens/alphabets_learn_screen.dart`](lib/screens/alphabets_learn_screen.dart:1)
- **Purpose**: Alphabet learning (A-Z)
- **Features**: Letter display, audio pronunciation, visual representation

## 🎨 Widgets

### WordCard
- **File**: [`lib/widgets/word_card.dart`](lib/widgets/word_card.dart:1)
- **Purpose**: Display individual word with image, text, and audio buttons

### StarBar
- **File**: [`lib/widgets/star_bar.dart`](lib/widgets/star_bar.dart:1)
- **Purpose**: Visual progress indicator with 0-5 stars

## 🔧 Utilities

### AudioHelper
- **File**: [`lib/utils/audio_helper.dart`](lib/utils/audio_helper.dart:1)
- **Purpose**: Wrapper around `audioplayers` for asset audio playback

## 🌍 Localization

The app supports multiple languages through Flutter's internationalization:
- Localization files in `lib/l10n/`
- Uses `intl` package for formatting
- Material app localization delegates configured

## 📈 Future Enhancements

- [ ] Remote word pack updates via API
- [ ] More language pairs (Hindi, Spanish, etc.)
- [ ] Advanced quiz modes
- [ ] Parent dashboard for progress tracking
- [ ] Cloud sync for progress across devices
- [ ] More interactive animations
- [ ] Voice recognition for pronunciation practice

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Dart effective guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Run `flutter analyze` before committing

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Created with ❤️ for bilingual education

## 📞 Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.

---

**Made with Flutter** ❤️
