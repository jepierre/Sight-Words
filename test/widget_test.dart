import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:namer_app/src/progress_store.dart';
import 'package:namer_app/src/sight_word_catalog.dart';
import 'package:namer_app/src/word_progress.dart';
import 'package:namer_app/src/sentence_game.dart';

void main() {
  test('bundled catalog has unique word IDs and non-empty groups', () async {
    final groups = await SightWordCatalog.load();
    final ids = groups.expand((group) => group.words.map((word) => word.id));

    expect(groups, isNotEmpty);
    expect(groups.every((group) => group.words.isNotEmpty), isTrue);
    expect(ids.toSet(), hasLength(ids.length));
    for (final group in groups) {
      for (var index = 0; index < group.words.length; index++) {
        expect(group.words[index].id, '${group.id}-${index + 1}');
      }
    }
  });

  test('word progress counts answers and resets the correct streak', () {
    final firstReview =
        WordProgress.empty('red-1').afterAnswer(true, DateTime.utc(2025));
    final secondReview =
        firstReview.afterAnswer(false, DateTime.utc(2025, 1, 2));

    expect(secondReview.attempts, 2);
    expect(secondReview.correctCount, 1);
    expect(secondReview.incorrectCount, 1);
    expect(secondReview.currentStreak, 0);
    expect(secondReview.lastReviewedAt, DateTime.utc(2025, 1, 2));
  });

  test('every catalog word has one complete sentence puzzle', () async {
    final groups = await SightWordCatalog.load();
    final words = groups
        .expand((group) => group.words)
        .map((word) => word.word.toLowerCase())
        .toSet();
    final answers =
        sentencePuzzles.map((puzzle) => puzzle.answer.toLowerCase());
    expect(answers.toSet(), words);
    expect(answers.toSet().length, sentencePuzzles.length);
    for (final puzzle in sentencePuzzles) {
      expect('___'.allMatches(puzzle.sentence).length, 1,
          reason: puzzle.answer);
      expect(puzzle.choices, hasLength(3));
      expect(puzzle.choices.toSet(), hasLength(3));
      expect(puzzle.choices, contains(puzzle.answer));
      expect(
          puzzle.choices
              .every((choice) => words.contains(choice.toLowerCase())),
          isTrue);
      expect(puzzle.picture, isNotEmpty);
    }
  });

  testWidgets('records a review and shows group progress', (tester) async {
    final progressStore = _MemoryProgressStore();
    await tester.pumpWidget(MyApp(progressStore: progressStore));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.text('Level 0: Red'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Level 0: Red'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mark as known'));
    await tester.pumpAndSettle();
    expect(progressStore.progress, hasLength(1));
    final savedProgress = progressStore.progress.values.single;
    expect(savedProgress.attempts, 1);
    expect(savedProgress.correctCount, 1);
    expect(savedProgress.incorrectCount, 0);
    expect(savedProgress.currentStreak, 1);
    expect(savedProgress.lastReviewedAt, isNotNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
        find.textContaining('1 of 13 words practiced · 1 correct · 0 missed'),
        findsOneWidget);
  });

  testWidgets('migrates saved history from the previous word IDs',
      (tester) async {
    final progressStore = _MemoryProgressStore();
    progressStore.progress['red-i'] = WordProgress.empty('red-i').afterAnswer(
      true,
      DateTime.utc(2025),
    );

    await tester.pumpWidget(MyApp(progressStore: progressStore));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(progressStore.progress, contains('red-1'));
    expect(progressStore.progress, isNot(contains('red-i')));
    expect(progressStore.progress['red-1']?.attempts, 1);
    expect(progressStore.progress['red-1']?.correctCount, 1);
    expect(
      find.textContaining('1 of 13 words practiced · 1 correct · 0 missed'),
      findsOneWidget,
    );
  });
  testWidgets('sentence safari retries, saves progress and earns a trophy',
      (tester) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final groups = await tester.runAsync(() => SightWordCatalog.load());
    final store = _MemoryProgressStore();
    await tester.pumpWidget(MaterialApp(
        home: SentenceGamePage(
      words: groups!.expand((group) => group.words).toList(),
      onAnswer: (word, correct) async {
        await store.recordAnswer(word.id, correct);
      },
    )));
    for (var index = 0; index < 5; index++) {
      final puzzle = sentencePuzzles.firstWhere((p) => find
          .text(p.sentence.replaceFirst('___', '_____'))
          .evaluate()
          .isNotEmpty);
      final wrong =
          puzzle.choices.firstWhere((choice) => choice != puzzle.answer);
      await tester.tap(find.byKey(ValueKey('choice-$wrong')));
      await tester.pumpAndSettle();
      expect(find.text('Good try! Pick another word.'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('choice-${puzzle.answer}')));
      await tester.pumpAndSettle();
      expect(find.text('You did it! A star for you!'), findsOneWidget);
      await tester.ensureVisible(
          find.text(index == 4 ? 'Get my trophy!' : 'Next sentence'));
      await tester
          .tap(find.text(index == 4 ? 'Get my trophy!' : 'Next sentence'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Safari superstar!'), findsOneWidget);
    expect(
        store.progress.values.fold<int>(0, (sum, p) => sum + p.attempts), 10);
    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 1 of 5'), findsOneWidget);
  });
}

class _MemoryProgressStore implements ProgressStore {
  final Map<String, WordProgress> progress = {};

  @override
  Future<void> migrateLegacyWordIds(Map<String, String> wordIds) async {
    for (final entry in wordIds.entries) {
      final previous = progress.remove(entry.key);
      if (previous != null) {
        progress[entry.value] = WordProgress(
          wordId: entry.value,
          attempts: previous.attempts,
          correctCount: previous.correctCount,
          incorrectCount: previous.incorrectCount,
          currentStreak: previous.currentStreak,
          lastReviewedAt: previous.lastReviewedAt,
        );
      }
    }
  }

  @override
  Future<Map<String, WordProgress>> loadAll() async => Map.of(progress);

  @override
  Future<WordProgress> recordAnswer(String wordId, bool correct) async {
    final updated =
        (progress[wordId] ?? WordProgress.empty(wordId)).afterAnswer(
      correct,
      DateTime.utc(2025),
    );
    progress[wordId] = updated;
    return updated;
  }
}
