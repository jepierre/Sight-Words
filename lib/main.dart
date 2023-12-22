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
  var wordPairList = <WordPair>[WordPair.random()];
  var redWordList = ["you", "if"];
  var blueWordList = ["blue", "two"];
  var sightWordGroups = <SightWordGroup>[
    SightWordGroup("Red", "", Colors.red),
    SightWordGroup("Blue", "description", Colors.blue),
    SightWordGroup("Yellow", "description", Colors.yellow),
    SightWordGroup("Purple", "description", Colors.purple),
    SightWordGroup("Green", "description", Colors.green)
  ];

  var sightWords = <SightWord>[
    SightWord(id: 0, word: "if", color: Colors.red),
    SightWord(id: 1, word: "if", color: Colors.blue),
    SightWord(id: 2, word: "what", color: Colors.green),
    SightWord(id: 3, word: "who", color: Colors.purple),
  ];
  final maxList = 10;
  var wordIndex = 0;

  void getNext() {
    wordIndex++;

    if (wordIndex >= wordPairList.length) {
      var tempWordPair = WordPair.random();

      if (!wordPairList.contains(tempWordPair)) {
        wordPairList.add(tempWordPair);
      } else {
        wordIndex--;
        getNext();
      }
    }

    if (wordIndex >= maxList) {
      wordIndex = 0;
    }

    print("wordList: $wordPairList ");
    notifyListeners();
  }

  void getPrevious() {
    wordIndex--;

    if (wordIndex < 0) {
      wordIndex = wordPairList.length - 1;
    }
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    var current = wordPairList[wordIndex];

    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var appStateCurrentIndex = appState.wordIndex;
    var pair = appState.wordPairList[appStateCurrentIndex];

    var wordGroupList = <SightWord>[];

    for (var sightWord in appState.sightWords) {
      if (sightWord.color == widget.sightWordGroup.color) {
        wordGroupList.add(sightWord);
      }
    }

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sightWordGroup}.title"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SightWordCard(sightWord: wordGroupList[wordGroupIndex]),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    appState.getPrevious();
                  },
                  icon: Icon(Icons.arrow_back),
                  // Text(''),
                ),
                SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    appState.getNext();
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
                title: Text(appState.sightWordGroups[index].title),
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
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       WordGroupCard(
      //         name: "Red",
      //         color: Color.fromRGBO(240, 5, 5, 1),
      //         wordList: ["if", "sdf"],
      //       ),
      //       WordGroupCard(
      //         name: "Blue",
      //         color: Color.fromARGB(255, 0, 0, 255),
      //         wordList: ["x", "y", "z"],
      //       ),
      //       WordGroupCard(
      //         name: "Yellow",
      //         color: Color.fromARGB(255, 255, 255, 0),
      //         wordList: ['dsf'],
      //       ),
      //       WordGroupCard(
      //         name: "Green",
      //         color: Color.fromARGB(255, 8, 253, 0),
      //         wordList: ['green', "words"],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

// class WordGroupCard extends StatelessWidget {
//   const WordGroupCard({
//     super.key,
//     required this.name,
//     required this.color,
//     required this.wordList,
//   });

//   final String name;
//   final Color color;
//   final List wordList;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final style = theme.textTheme.displayMedium!.copyWith(
//       color: color,
//     );

//     return InkWell(
//       onTap: () {
//         print("$name card clicked");
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 // builder: (context) => const WordGroupPage(wordList: wordList)));
//                 builder: (context) => const WordGroupPage(sightWordGroup: ,)));
//       },
//       child: Card(
//         color: Color.fromARGB(255, 202, 202, 202),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Text(
//             name,
//             style: style,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
      color: Color.fromARGB(255, 255, 255, 255),
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
