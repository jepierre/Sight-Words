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
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        // page = Placeholder();
        page = FavoritePage();
      default:
        throw UnimplementedError('no widget selected for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                // extended: true,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  print('selected: $value');
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoriteList = appState.favorites;

    if (favoriteList.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${favoriteList.length} favorites:'),
        ),
        for (var pair in favoriteList)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          )
      ],
    );
  }
}

class WordGroupPage extends StatelessWidget {
  const WordGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var appStateCurrentIndex = appState.wordIndex;
    var pair = appState.wordPairList[appStateCurrentIndex];

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Word group"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
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
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WordGroupCard(name: "Red", color: Color.fromRGBO(255, 0, 0, 1)),
          WordGroupCard(name: "Blue", color: Color.fromARGB(255, 0, 0, 255)),
          WordGroupCard(
              name: "Yellow", color: Color.fromARGB(255, 255, 255, 0)),
          WordGroupCard(name: "Green", color: Color.fromARGB(255, 8, 253, 0)),
        ],
      ),
    );
  }
}

class WordGroupCard extends StatelessWidget {
  const WordGroupCard({
    super.key,
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: color,
    );

    return InkWell(
      onTap: () {
        print("$name card clicked");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const WordGroupPage()));
      },
      child: Card(
        color: Color.fromARGB(255, 202, 202, 202),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            name,
            style: style,
          ),
        ),
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

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}
