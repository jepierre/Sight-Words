import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 34, 93, 255)),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var sightWordGroups = <SightWordGroup>[
    SightWordGroup("Red", "", Colors.red),
    SightWordGroup("Orange", "description", Colors.orange),
    SightWordGroup("Yellow", "description", Colors.yellow),
    SightWordGroup("Green", "description", Colors.green),
    SightWordGroup("Blue", "description", Colors.blue),
    SightWordGroup("Indigo", "description", Colors.indigo),
    SightWordGroup("Purple", "description", Colors.purple),
  ];

  var sightWords = <SightWord>[
    SightWord(id: 0, word: "if", color: Colors.red),
    SightWord(id: 0, word: "then", color: Colors.red),
    SightWord(id: 0, word: "what", color: Colors.red),
    SightWord(id: 0, word: "why", color: Colors.red),
    SightWord(id: 1, word: "if", color: Colors.blue),
    SightWord(id: 1, word: "so", color: Colors.yellow),
    SightWord(id: 2, word: "what", color: Colors.green),
    SightWord(id: 3, word: "who", color: Colors.purple),
  ];
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GeneratorPage(),
      ),
    );
  }
}

class WordGroupPage extends StatefulWidget {
  const WordGroupPage({super.key, required this.sightWordGroup});

  final SightWordGroup sightWordGroup;

  @override
  State<WordGroupPage> createState() => _WordGroupPageState();
}

class _WordGroupPageState extends State<WordGroupPage> {
  var wordGroupIndex = 0;
  var wordGroupList = <SightWord>[];
  var sightWordsOrder = [];
    final FlutterTts flutterTts = FlutterTts();

  void getNext() {
    if (sightWordsOrder.isEmpty) {
      sightWordsOrder = Iterable<int>.generate(wordGroupList.length).toList();
      sightWordsOrder.shuffle();

      print(sightWordsOrder);
    }
    wordGroupIndex = sightWordsOrder.removeAt(0);

    print("remaining elements: $sightWordsOrder");
    print(
        "index: $wordGroupIndex, text: ${wordGroupList[wordGroupIndex].word}");
    setState(() {});
  }

  void getPrevious() {
    wordGroupIndex--;

    if (wordGroupIndex < 0) {
      wordGroupIndex = wordGroupList.length - 1;
    }
    print(
        "index: $wordGroupIndex, text: ${wordGroupList[wordGroupIndex].word}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    for (var sightWord in appState.sightWords) {
      if (sightWord.color.value == widget.sightWordGroup.color.value &&
          !wordGroupList.contains(sightWord)) {
        wordGroupList.add(sightWord);
      }
    }

    if (wordGroupList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.sightWordGroup.title, style: style),
            backgroundColor: widget.sightWordGroup.color),
        body: Center(child: Text("No words in group yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.sightWordGroup.title, style: style),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
          backgroundColor: widget.sightWordGroup.color),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SightWordCard(
              sightWord: wordGroupList[wordGroupIndex],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    await flutterTts.speak(wordGroupList[wordGroupIndex].word);
                    getNext();
                  },
                  icon: Icon(Icons.close, color: Colors.red),
                  // Text(''),
                ),
                SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    getNext();
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  // Text(''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sight Words!"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: ListView.builder(
        itemCount: appState.sightWordGroups.length,
        itemBuilder: (context, index) {
          return Container(
            height: 150,
            color: appState.sightWordGroups[index].color,
            margin: const EdgeInsets.all(8),
            child: ListTile(
                title:
                    Text(appState.sightWordGroups[index].title, style: style),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WordGroupPage(
                              sightWordGroup:
                                  appState.sightWordGroups[index])));
                }),
          );
          // },);
        },
      ),
    );
  }
}

class SightWord {
  final int id;
  final String word;
  final Color color;

  const SightWord({required this.id, required this.word, required this.color});

  // Convert a Card into a Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "word": word,
      "color": color,
    };
  }

  // Implement toString to make it easier to see information about each card
  @override
  String toString() {
    return 'Card{id: $id, word: $word, color: $color}';
  }
}

class SightWordCard extends StatelessWidget {
  const SightWordCard({
    super.key,
    required this.sightWord,
  });

  final SightWord sightWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: Colors.white,
    );

    final FlutterTts flutterTts = FlutterTts();

    return InkWell(
      onTap: () async {
        await flutterTts.speak(sightWord.word);
        print("sightword tapped");
      },
      child: Card(
        color: sightWord.color,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: InkWell(
            child: Text(
              sightWord.word,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}

class SightWordGroup {
  final String title;
  final String description;
  final Color color;

  const SightWordGroup(this.title, this.description, this.color);
}
