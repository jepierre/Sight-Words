# Project Guidelines

## Build, test, and lint

Run these commands from the repository root:

```sh
flutter pub get
flutter run -d <device-id>
flutter build apk
flutter analyze
flutter test
flutter test test/widget_test.dart
flutter test test/widget_test.dart --plain-name "records a review and shows group progress"
dart format --output=none --set-exit-if-changed lib test
```

Run a single test with `flutter test test/widget_test.dart --plain-name "records a review and shows group progress"`. Widget tests inject an in-memory `ProgressStore`; use that instead of invoking the device SQLite plugin in tests.

## Architecture

- This is a small Flutter app. UI and app state live in `lib/main.dart`; catalog models/loading and progress persistence live under `lib/src/`.
- `MyApp` provides `MyAppState` with `ChangeNotifierProvider`. `MyHomePage` shows `GeneratorPage`; selecting a color group opens `WordGroupPage`, and the drawer can open `AllWordsPage`.
- `assets/sight_words.json` is the bundled, editable word catalog. Each group contains its words; use short, unique sequential IDs such as `red-1`. Keep IDs stable when editing words or reordering the catalog because they key the local SQLite progress table.
- `SightWordCard` speaks its word through `flutter_tts` when tapped. `WordGroupPage` shuffles each group and records correct/incorrect answers through `ProgressStore`; saved per-word counts, streak, and last-reviewed time are shown on the progress page.
- SQLite persistence is device-local. Widget tests should inject an in-memory `ProgressStore` rather than call the SQLite plugin.

## Repository-specific conventions

- Word membership is defined by the containing group in `assets/sight_words.json`, not by color or numeric IDs. Keep word IDs unique and stable so saved progress remains associated with the same word.
- A missed word is queued again in the current review session. A correct answer advances the session counter; exhausting the queue starts another shuffled pass.
- Group labels combine the list position (`Level $index`) and the JSON group title.
- Android build configuration uses Gradle Kotlin DSL (`android/*.gradle.kts`) and Java 17. Preserve those formats and settings when changing the Android build.
- If Android compilation fails in `:flutter_tts:compileDebugKotlin` with Kotlin incremental-cache errors such as “already registered,” retry with per-process Gradle options before changing project build files:

  ```powershell
  $env:GRADLE_OPTS='-Dorg.gradle.project.kotlin.incremental=false -Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process'
  flutter run -d <device-id>
  ```
