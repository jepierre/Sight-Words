import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'src/progress_store.dart';
import 'src/sentence_game.dart';
import 'src/sight_word_catalog.dart';
import 'src/word_progress.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.progressStore});

  final ProgressStore? progressStore;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(
        progressStore: progressStore ?? SqliteProgressStore(),
      )..initialize(),
      child: MaterialApp(
        title: 'Sight Words!',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F4FF),
          appBarTheme: const AppBarTheme(
              centerTitle: true, backgroundColor: Color(0xFFF7F4FF)),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750C7),
          ),
        ),
        home: const MyHomePage(title: 'Sight Word Adventures'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState({required this.progressStore});

  final ProgressStore progressStore;
  List<SightWordGroup> sightWordGroups = [];
  List<SightWord> sightWords = [];
  Map<String, WordProgress> wordProgress = {};
  Object? initializationError;
  bool isLoading = true;

  Future<void> initialize() async {
    isLoading = true;
    initializationError = null;
    notifyListeners();
    try {
      final groups = await SightWordCatalog.load();
      await progressStore.migrateLegacyWordIds({
        for (final group in groups)
          for (final word in group.words)
            '${group.id}-${word.word.toLowerCase()}': word.id,
      });
      final progress = await progressStore.loadAll();
      sightWordGroups = groups;
      sightWords = groups.expand((group) => group.words).toList();
      wordProgress = progress;
    } catch (error) {
      initializationError = error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  WordProgress progressFor(SightWord word) {
    return wordProgress[word.id] ?? WordProgress.empty(word.id);
  }

  Future<void> recordAnswer(SightWord word, bool correct) async {
    final progress = await progressStore.recordAnswer(word.id, correct);
    wordProgress = {...wordProgress, word.id: progress};
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(title),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Word progress'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllWordsPage()),
                );
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info),
              applicationIcon: Icon(Icons.local_play),
              applicationName: 'Sight Words!',
              applicationVersion: '0.0.1',
              child: Text('About'),
            ),
          ],
        ),
      ),
      body: Center(
        child: appState.isLoading
            ? const CircularProgressIndicator()
            : appState.initializationError != null
                ? _LoadError(
                    error: appState.initializationError!,
                    onRetry: appState.initialize,
                  )
                : const GeneratorPage(),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load sight words or saved progress.'),
          const SizedBox(height: 8),
          SelectableText('$error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class WordGroupPage extends StatefulWidget {
  const WordGroupPage({
    super.key,
    required this.sightWordGroup,
    required this.words,
    required this.level,
  });

  final SightWordGroup sightWordGroup;
  final List<SightWord> words;
  final int level;

  @override
  State<WordGroupPage> createState() => _WordGroupPageState();
}

class _WordGroupPageState extends State<WordGroupPage> {
  late final List<int> sightWordsOrder;
  late int wordGroupIndex;
  var sightWordCounter = 1;
  var isSavingAnswer = false;

  @override
  void initState() {
    super.initState();
    sightWordsOrder = List<int>.generate(widget.words.length, (index) => index)
      ..shuffle();
    wordGroupIndex = sightWordsOrder.isEmpty ? 0 : sightWordsOrder.removeAt(0);
  }

  Future<void> answer(bool correct) async {
    if (isSavingAnswer || widget.words.isEmpty) {
      return;
    }
    setState(() => isSavingAnswer = true);
    try {
      await context
          .read<MyAppState>()
          .recordAnswer(widget.words[wordGroupIndex], correct);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save progress: $error')),
        );
      }
      return;
    } finally {
      if (mounted) {
        setState(() => isSavingAnswer = false);
      }
    }

    if (!mounted) {
      return;
    }
    if (!correct) {
      sightWordsOrder.add(wordGroupIndex);
    } else {
      sightWordCounter++;
    }

    if (sightWordsOrder.isEmpty) {
      sightWordsOrder.addAll(
        List<int>.generate(widget.words.length, (index) => index)..shuffle(),
      );
      sightWordCounter = 1;
    }
    wordGroupIndex = sightWordsOrder.removeAt(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.sightWordGroup;
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(group.title), backgroundColor: group.color),
        body: const Center(child: Text('No words in group yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(group.title),
        backgroundColor: group.color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SightWordCard(sightWord: widget.words[wordGroupIndex]),
            const SizedBox(height: 10),
            const Text('Tap the card to hear the word!',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isSavingAnswer ? null : () => answer(false),
                  icon: const Icon(Icons.close, color: Colors.red, size: 50),
                  tooltip: 'Mark as not known',
                ),
                const SizedBox(width: 50),
                IconButton(
                  onPressed: isSavingAnswer ? null : () => answer(true),
                  icon: const Icon(Icons.check, color: Colors.green, size: 50),
                  tooltip: 'Mark as known',
                ),
              ],
            ),
            Text(
              'Learning $sightWordCounter of ${widget.words.length} words!',
            ),
          ],
        ),
      ),
    );
  }
}

class AllWordsPage extends StatelessWidget {
  const AllWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Word Progress')),
      body: appState.sightWords.isEmpty
          ? const Center(child: Text('No words added yet.'))
          : ListView.builder(
              itemCount: appState.sightWords.length,
              itemBuilder: (context, index) {
                final word = appState.sightWords[index];
                final progress = appState.progressFor(word);
                final lastReviewed = progress.lastReviewedAt == null
                    ? 'Never reviewed'
                    : 'Last reviewed ${MaterialLocalizations.of(context).formatMediumDate(progress.lastReviewedAt!.toLocal())}';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  color: word.color,
                  child: ListTile(
                    title: Text(
                      word.word,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    subtitle: Text(
                      '${progress.attempts} attempts · ${progress.correctCount} correct · '
                      '${progress.incorrectCount} missed · '
                      '${progress.currentStreak} correct in a row\n$lastReviewed',
                      style: const TextStyle(color: Colors.white),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appState.sightWordGroups.length + 1,
      itemBuilder: (context, itemIndex) {
        if (itemIndex == 0) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Ready, set, read!',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                const Text('Little words. Big adventures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Card(
                    color: const Color(0xFFDFD5FF),
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          const Icon(Icons.explore_rounded,
                              size: 56, color: Color(0xFF5134A3)),
                          const Text('Sentence Safari',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              'Find the missing word. Collect five stars!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SentenceGamePage(
                                          words: appState.sightWords,
                                          onAnswer: appState.recordAnswer))),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Let’s play!')),
                        ]))),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Choose a word adventure',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))),
              ]);
        }
        final index = itemIndex - 1;
        final group = appState.sightWordGroups[index];
        final ink = ThemeData.estimateBrightnessForColor(group.color) ==
                Brightness.light
            ? const Color(0xFF29213D)
            : Colors.white;
        final progress =
            group.words.map(appState.progressFor).toList(growable: false);
        final reviewedCount =
            progress.where((word) => word.attempts > 0).length;
        final correctCount =
            progress.fold(0, (total, word) => total + word.correctCount);
        final incorrectCount =
            progress.fold(0, (total, word) => total + word.incorrectCount);

        return Card(
          margin: const EdgeInsets.all(8),
          color: group.color,
          child: ListTile(
            minVerticalPadding: 24,
            leading: Icon(Icons.auto_awesome_rounded, color: ink),
            trailing: Icon(Icons.chevron_right_rounded, color: ink),
            title: Text(
              'Level $index: ${group.title}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: ink, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              '$reviewedCount of ${group.words.length} words practiced · '
              '$correctCount correct · $incorrectCount missed',
              style: TextStyle(color: ink),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WordGroupPage(
                    sightWordGroup: group,
                    words: group.words,
                    level: index,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SightWordCard extends StatelessWidget {
  const SightWordCard({super.key, required this.sightWord});

  final SightWord sightWord;

  @override
  Widget build(BuildContext context) {
    final flutterTts = FlutterTts();
    return SizedBox(
      height: 150,
      width: 300,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: sightWord.color,
        child: InkWell(
          onTap: () async {
            await flutterTts.speak(sightWord.word);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                sightWord.word,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
