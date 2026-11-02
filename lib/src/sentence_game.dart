import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'sight_word_catalog.dart';

class SentencePuzzle {
  const SentencePuzzle(this.sentence, this.answer, this.choices, this.picture);

  final String sentence;
  final String answer;
  final List<String> choices;
  final String picture;
}

const sentencePuzzles = [
  // One puzzle per catalog word, in catalog order. Distractors are chosen so
  // only the target word completes the sentence naturally.
  SentencePuzzle('___ am happy.', 'I', ['I', 'the', 'and'], '😊'),
  SentencePuzzle('I ___ jump.', 'can', ['can', 'the', 'and'], '🐸'),
  SentencePuzzle('Look at ___ moon.', 'the', ['the', 'can', 'we'], '🌙'),
  SentencePuzzle('A stop sign is ___.', 'red', ['red', 'can', 'and'], '🛑'),
  SentencePuzzle('Can ___ play together?', 'we', ['we', 'the', 'and'], '🛝'),
  SentencePuzzle('I can ___ a bird.', 'see', ['see', 'the', 'and'], '🐦'),
  SentencePuzzle('The sun is ___.', 'yellow', ['yellow', 'can', 'and'], '☀️'),
  SentencePuzzle('I see ___ cat.', 'a', ['a', 'we', 'and'], '🐱'),
  SentencePuzzle(
      'The night sky is ___.', 'black', ['black', 'can', 'and'], '🌌'),
  SentencePuzzle('We ___ to play.', 'like', ['like', 'the', 'my'], '🛝'),
  SentencePuzzle('We go ___ the park.', 'to', ['to', 'can', 'the'], '🌳'),
  SentencePuzzle('The snow is ___.', 'white', ['white', 'can', 'and'], '⛄'),
  SentencePuzzle('A dog ___ a cat.', 'and', ['and', 'the', 'can'], '🐶 🐱'),

  SentencePuzzle(
      'The bear has ___ fur.', 'brown', ['brown', 'we', 'and'], '🐻'),
  SentencePuzzle('We can ___ home.', 'go', ['go', 'the', 'my'], '🏠'),
  SentencePuzzle(
      'Can ___ clap your hands?', 'you', ['you', 'the', 'and'], '👏'),
  SentencePuzzle('Look ___ the moon.', 'at', ['at', 'can', 'we'], '🌙'),
  SentencePuzzle('I can ___ a little dance.', 'do', ['do', 'the', 'and'], '💃'),
  SentencePuzzle(
      'We can play outside ___ it is sunny.', 'if', ['if', 'the', 'my'], '☀️'),
  SentencePuzzle(
      'The bird flew ___ of the cage.', 'out', ['out', 'the', 'and'], '🐦'),
  SentencePuzzle('It is time to eat ___.', 'now', ['now', 'the', 'and'], '🍎'),
  SentencePuzzle(
      'An elephant is a ___ animal.', 'big', ['big', 'we', 'and'], '🐘'),
  SentencePuzzle('This is ___ dog.', 'my', ['my', 'and', 'can'], '🐕'),
  SentencePuzzle(
      'The ducks ___ in the pond.', 'are', ['are', 'am', 'is'], '🦆'),
  SentencePuzzle('Can you ___ the ball?', 'get', ['get', 'the', 'and'], '⚽'),
  SentencePuzzle('A fish is ___ a bird.', 'not', ['not', 'the', 'and'], '🐟'),

  SentencePuzzle('Come play ___ me.', 'with', ['with', 'the', 'can'], '🧸'),
  SentencePuzzle('Dad says ___ can help me.', 'he', ['he', 'the', 'and'], '👨'),
  SentencePuzzle(
      'I have a ball, and ___ is red.', 'it', ['it', 'the', 'and'], '🔴'),
  SentencePuzzle(
      'We ate ___ of the apples.', 'all', ['all', 'can', 'we'], '🍎'),
  SentencePuzzle(
      'I was cold, ___ I put on a coat.', 'so', ['so', 'the', 'my'], '🧥'),
  SentencePuzzle(
      'I can hop, ___ I cannot fly.', 'but', ['but', 'the', 'my'], '🐰'),
  SentencePuzzle('The sun ___ yellow.', 'is', ['is', 'and', 'my'], '☀️'),
  SentencePuzzle(
      'The kitten is very ___.', 'little', ['little', 'the', 'and'], '🐱'),
  SentencePuzzle('I ___ glad to see you.', 'am', ['am', 'is', 'are'], '😊'),
  SentencePuzzle(
      'Mom says ___ can read to me.', 'she', ['she', 'the', 'and'], '👩'),
  SentencePuzzle(
      'Yesterday, I ___ at the park.', 'was', ['was', 'am', 'are'], '🌳'),
  SentencePuzzle(
      'The box is empty. There are ___ toys.', 'no', ['no', 'can', 'we'], '📦'),
  SentencePuzzle('I will ___ kind.', 'be', ['be', 'the', 'and'], '💛'),

  SentencePuzzle(
      'Tomorrow, we ___ go to the zoo.', 'will', ['will', 'the', 'my'], '🦁'),
  SentencePuzzle(
      'I nod my head to say ___.', 'yes', ['yes', 'the', 'and'], '🙂'),
  SentencePuzzle('This gift is ___ you.', 'for', ['for', 'can', 'we'], '🎁'),
  SentencePuzzle('I ___ a big ball.', 'have', ['have', 'the', 'and'], '⚽'),
  SentencePuzzle(
      'Put your hat ___ your head.', 'on', ['on', 'can', 'and'], '🧢'),
  SentencePuzzle('I drink a cup ___ milk.', 'of', ['of', 'can', 'we'], '🥛'),
  SentencePuzzle(
      'The kids say ___ want to play.', 'they', ['they', 'the', 'and'], '🛝'),
  SentencePuzzle('The cat is ___ the box.', 'in', ['in', 'and', 'can'], '📦'),
  SentencePuzzle(
      'Mom ___ it is time for bed.', 'said', ['said', 'the', 'and'], '🛏️'),
  SentencePuzzle('I ___ to play outside.', 'want', ['want', 'the', 'my'], '🌳'),
  SentencePuzzle(
      'What ___ you eat yesterday?', 'did', ['did', 'the', 'and'], '🍽️'),
  SentencePuzzle(
      'The balloon went ___ into the sky.', 'up', ['up', 'the', 'and'], '🎈'),
  SentencePuzzle(
      'Yesterday, I ___ a rainbow.', 'saw', ['saw', 'the', 'and'], '🌈'),

  SentencePuzzle('Can you ___ hello?', 'say', ['say', 'the', 'and'], '👋'),
  SentencePuzzle('The dog wags ___ tail.', 'its', ['its', 'we', 'and'], '🐕'),
  SentencePuzzle(
      'Come and sit ___ by me.', 'here', ['here', 'the', 'and'], '🪑'),
  SentencePuzzle('Can you help ___?', 'me', ['me', 'and', 'the'], '🤝'),
  SentencePuzzle(
      'The moon is very ___ away.', 'far', ['far', 'the', 'and'], '🌙'),
  SentencePuzzle(
      'Look at ___ little bug.', 'this', ['this', 'we', 'and'], '🐞'),
  SentencePuzzle(
      'Tell me ___ is in the box.', 'what', ['what', 'the', 'and'], '📦'),
  SentencePuzzle('Dad is a kind ___.', 'man', ['man', 'the', 'and'], '👨'),
  SentencePuzzle(
      'Give one apple to ___ child.', 'each', ['each', 'we', 'and'], '🍎'),
  SentencePuzzle(
      'The frog jumps ___ the pond.', 'into', ['into', 'the', 'and'], '🐸'),
  SentencePuzzle(
      'You did very ___ today!', 'well', ['well', 'the', 'and'], '⭐'),
  SentencePuzzle(
      'Yesterday, the dog ___ home.', 'ran', ['ran', 'the', 'and'], '🐕'),
  SentencePuzzle(
      'Can you ___ me tie my shoe?', 'help', ['help', 'the', 'and'], '👟'),
];

class SentenceGamePage extends StatefulWidget {
  const SentenceGamePage({
    super.key,
    required this.words,
    required this.onAnswer,
  });

  final List<SightWord> words;
  final Future<void> Function(SightWord word, bool correct) onAnswer;

  @override
  State<SentenceGamePage> createState() => _SentenceGamePageState();
}

class _SentenceGamePageState extends State<SentenceGamePage> {
  final _tts = FlutterTts();
  late List<SentencePuzzle> _round;
  List<String> _choices = [];
  final Set<String> _tried = {};
  int _index = 0;
  bool _solved = false;
  bool _saving = false;
  String _feedback = 'Tap the word that fits!';

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _round = (sentencePuzzles
            .where((puzzle) => widget.words.any(
                  (word) =>
                      word.word.toLowerCase() == puzzle.answer.toLowerCase(),
                ))
            .toList()
          ..shuffle())
        .take(10)
        .toList();
    _index = 0;
    _prepare();
  }

  void _prepare() {
    _choices =
        _round.isEmpty ? [] : (List.of(_round[_index].choices)..shuffle());
    _tried.clear();
    _solved = false;
    _feedback = 'Tap the word that fits!';
  }

  Future<void> _speak() async {
    try {
      await _tts.setSpeechRate(0.4);
      if (!mounted) return;
      await _tts.speak(_solved
          ? _round[_index].sentence.replaceFirst('___', _round[_index].answer)
          : _round[_index].sentence.replaceFirst('___', 'blank'));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sound is unavailable. Let’s read together!')),
        );
      }
    }
  }

  Future<void> _answer(String choice) async {
    if (_saving || _solved || _tried.contains(choice)) return;
    final puzzle = _round[_index];
    final correct = choice == puzzle.answer;
    setState(() => _saving = true);
    try {
      await widget.onAnswer(
          widget.words.firstWhere(
            (word) => word.word.toLowerCase() == puzzle.answer.toLowerCase(),
          ),
          correct);
      if (!mounted) return;
      setState(() {
        _tried.add(choice);
        _solved = correct;
        _feedback = correct
            ? 'You did it! A star for you!'
            : 'Good try! Pick another word.';
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finished = _round.isNotEmpty && _index == _round.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Sentence Safari')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              if (_round.isEmpty)
                const Text('Add some sight words to start playing.')
              else if (finished) ...[
                const Text('🏆',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 88)),
                const Text('Safari superstar!',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('You finished ${_round.length} sentences. Keep shining!',
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                    onPressed: () => setState(_start),
                    icon: const Icon(Icons.replay),
                    label: const Text('Play again')),
              ] else ...[
                Text('Sentence ${_index + 1} of ${_round.length}',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                    value: (_index + (_solved ? 1 : 0)) / _round.length,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(12)),
                const SizedBox(height: 20),
                Text(_round[_index].picture,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 64)),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _round[_index].sentence.replaceFirst(
                              '___', _solved ? _round[_index].answer : '_____'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.5),
                        ))),
                TextButton.icon(
                    onPressed: _speak,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Hear the sentence')),
                const SizedBox(height: 12),
                Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: _choices
                        .map((choice) => FilledButton.tonal(
                              key: ValueKey('choice-$choice'),
                              onPressed:
                                  _saving || _solved || _tried.contains(choice)
                                      ? null
                                      : () => _answer(choice),
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(96, 72),
                                  textStyle: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              child: Text(choice),
                            ))
                        .toList()),
                const SizedBox(height: 24),
                Semantics(
                    liveRegion: true,
                    child: Text(_feedback,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600))),
                const SizedBox(height: 16),
                if (_solved) ...[
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFE8A000), size: 56),
                  FilledButton.icon(
                      onPressed: () {
                        _tts.stop();
                        setState(() {
                          _index++;
                          if (_index < _round.length) _prepare();
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_index == _round.length - 1
                          ? 'Get my trophy!'
                          : 'Next sentence')),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
