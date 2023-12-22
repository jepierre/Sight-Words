import 'dart:async';

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
    SightWordGroup("Blue", "description", Colors.blue),
    SightWordGroup("Yellow", "description", Colors.yellow),
    SightWordGroup("Purple", "description", Colors.purple),
    SightWordGroup("Green", "description", Colors.green)
  ];

  var sightWords = <SightWord>[
    SightWord(id: 0, word: "if", color: Colors.red),
    SightWord(id: 0, word: "then", color: Colors.red),
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

  void getNext() {
    setState(() {
      wordGroupIndex++;

      if (wordGroupIndex >= wordGroupList.length) {
        wordGroupIndex = 0;
      }
      print(
          "index: $wordGroupIndex, text: ${wordGroupList[wordGroupIndex].word}");
    });
  }

  void getPrevious() {
    setState(() {
      wordGroupIndex--;

      if (wordGroupIndex < 0) {
        wordGroupIndex = wordGroupList.length - 1;
      }
      print(
          "index: $wordGroupIndex, text: ${wordGroupList[wordGroupIndex].word}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    for (var sightWord in appState.sightWords) {
      if (sightWord.color.value == widget.sightWordGroup.color.value &&
          !wordGroupList.contains(sightWord)) {
        wordGroupList.add(sightWord);
      }
    }

    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sightWordGroup.title,
        style: style),
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
                  onPressed: () {
                    getPrevious();
                  },
                  icon: Icon(Icons.arrow_back),
                  // Text(''),
                ),
                SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    getNext();
                  },
                  icon: Icon(Icons.arrow_forward),
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

    return Card(
      color: sightWord.color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          sightWord.word,
          style: style,
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

// class BigCard extends StatelessWidget {
//   const BigCard({
//     super.key,
//     required this.pair,
//   });

//   final WordPair pair;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final style = theme.textTheme.displayMedium!.copyWith(
//       color: theme.colorScheme.onPrimary,
//     );

//     return Card(
//       color: theme.colorScheme.primary,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Text(
//           pair.asLowerCase,
//           style: style,
//         ),
//       ),
//     );
//   }
// }
