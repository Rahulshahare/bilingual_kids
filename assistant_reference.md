# Assistant Reference (for automated edits)

This file documents concise rules, important paths, and CI expectations used by the automated coding assistant.

- Project root: c:\Users\rahul\Desktop\bilingual_kids
- Important folders:
  - lib/ (source files)
  - assets/ (images, audio, data)
  - lib/models, lib/providers, lib/screens, lib/widgets, lib/utils
  - .github/workflows/ (CI workflows)

- Code generation: Hive adapters generated with build_runner create *.g.dart files in lib/models.
- Flutter dependencies are declared in pubspec.yaml. Use flutter pub get before building.

- CI behavior (GitHub Actions):
  - Workflow file: .github/workflows/flutter-ci.yml
  - Installs Flutter (stable), caches pub, runs flutter pub get, analyze, test, and builds release APK.
  - Artifact location: build/app/outputs/flutter-apk/app-release.apk

- Edit rules for assistant:
  - When editing files, insert new content using small contextual snippets and `// ...existing code...` to indicate unchanged sections.
  - Do not output file changes directly in chat; edits are applied to files in the workspace.
  - When creating new files pick paths under the project root.

- Local run steps (developer):
  1. flutter pub get
  2. flutter packages pub run build_runner build --delete-conflicting-outputs
  3. flutter build apk --release