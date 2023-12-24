import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        routes: {
          '/allwords': (context) => AllWordsPage(),
        },
        title: 'Sight Words!',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 34, 93, 255)),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(title: "Sight Words!"),
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
    SightWordGroup("Purple", "description", Colors.purple),
    SightWordGroup("Pink", "description", Colors.pink),
    SightWordGroup("Black", "description", Colors.black),
  ];

  var sightWords = SightWords().sightWords;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      // drawer: Drawer(
      //     child: ListView(
      //   // Important: Remove any padding from the ListView.
      //   padding: EdgeInsets.zero,
      //   children: [
      //     DrawerHeader(
      //       decoration: BoxDecoration(
      //         color: Colors.blue,
      //       ),
      //       child: Text(widget.title),
      //     ),
      //     ListTile(
      //       leading: Icon(
      //         Icons.home,
      //       ),
      //       title: const Text('Home'),
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //     ),
      //     ListTile(
      //       leading: Icon(
      //         Icons.abc,
      //       ),
      //       title: const Text('All Words'),
      //       onTap: () {
      //         Navigator.pop(context);
      //         Navigator.push(context,
      //             MaterialPageRoute(builder: (context) => AllWordsPage()));
      //       },
      //     ),
      //     AboutListTile(
      //       icon: Icon(
      //         Icons.info,
      //       ),
      //       applicationIcon: Icon(Icons.local_play),
      //       applicationName: "Sight Words!",
      //       applicationVersion: "0.0.1",
      //       child: const Text('About'),
      //     ),
      //   ],
      // )),
      body: Center(
        child: GeneratorPage(),
      ),
    );
  }
}

class WordGroupPage extends StatefulWidget {
  const WordGroupPage(
      {super.key, required this.sightWordGroup, required this.level});

  final SightWordGroup sightWordGroup;
  final int level;

  @override
  State<WordGroupPage> createState() => _WordGroupPageState();
}

class _WordGroupPageState extends State<WordGroupPage> {
  var wordGroupIndex = 0;
  var wordGroupList = <SightWord>[];
  var sightWordsOrder = [];
  var sightWordCounter = 1;
  final FlutterTts flutterTts = FlutterTts();
  var sightWords = SightWords().sightWords;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (var sightWord in sightWords) {
      if (sightWord.color.value == widget.sightWordGroup.color.value &&
          !wordGroupList.contains(sightWord)) {
        wordGroupList.add(sightWord);
      }
    }
    if (sightWordsOrder.isEmpty) {
      sightWordsOrder = Iterable<int>.generate(wordGroupList.length).toList();
      sightWordsOrder.shuffle();

      print(sightWordsOrder);
      wordGroupIndex = sightWordsOrder.removeAt(0);
    }
  }

  void getNext(bool lastWordStatusGood) {
    if (!lastWordStatusGood) {
      sightWordsOrder.add(wordGroupIndex);
    } else {
      sightWordCounter++;
    }
    if (sightWordsOrder.isEmpty) {
      sightWordsOrder = Iterable<int>.generate(wordGroupList.length).toList();
      sightWordsOrder.shuffle();

      print(sightWordsOrder);
      sightWordCounter = 1;
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

    if (wordGroupList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Level ${widget.level}", style: style),
            backgroundColor: widget.sightWordGroup.color),
        body: Center(child: Text("No words in group yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Level ${widget.level}", style: style),
        // title: Text(widget.sightWordGroup.title, style: style),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
        backgroundColor: widget.sightWordGroup.color,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 45,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                    getNext(false);
                  },
                  icon: Icon(Icons.close, color: Colors.red, size: 50),
                  // Text(''),
                ),
                SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    getNext(true);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 50,
                  ),
                  // Text(''),
                ),
              ],
            ),
            Center(
              child: Text(
                  "Learning $sightWordCounter of ${wordGroupList.length} words!"),
            )
          ],
        ),
      ),
    );
  }
}

class AllWordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.sightWords.isEmpty) {
      return Center(child: Text("No words added yet!"));
    }

    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Words'),
      ),
      body: ListView.builder(
        itemCount: appState.sightWords.length,
        itemBuilder: (context, index) {
          return Container(
            // height: 150,
            color: appState.sightWords[index].color,
            margin: const EdgeInsets.all(8),
            child: Center(
              child: ListTile(
                title: Text(
                  appState.sightWords[index].word,
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
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

    return ListView.builder(
      itemCount: appState.sightWordGroups.length,
      itemBuilder: (context, index) {
        return Container(
          height: 150,
          color: appState.sightWordGroups[index].color,
          margin: const EdgeInsets.all(8),
          child: Center(
            child: ListTile(
                title: Text(
                  "Level $index",
                  // appState.sightWordGroups[index].title,
                  style: style,
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WordGroupPage(
                              sightWordGroup: appState.sightWordGroups[index],
                              level: index)));
                }),
          ),
        );
      },
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

    return SizedBox(
      height: 150,
      width: 300,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: sightWord.color,
        child: InkWell(
          onTap: () async {
            await flutterTts.speak(sightWord.word);
            print("sightword tapped");
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                sightWord.word,
                style: style,
                textAlign: TextAlign.center,
              ),
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

class SightWords {
  var sightWords = <SightWord>[
    // red words
    SightWord(id: 0, word: "I", color: Colors.red),
    SightWord(id: 0, word: "can", color: Colors.red),
    SightWord(id: 0, word: "the", color: Colors.red),
    SightWord(id: 0, word: "see", color: Colors.red),
    SightWord(id: 0, word: "we", color: Colors.red),
    SightWord(id: 0, word: "a", color: Colors.red),
    SightWord(id: 0, word: "like", color: Colors.red),
    SightWord(id: 0, word: "to", color: Colors.red),
    SightWord(id: 0, word: "and", color: Colors.red),
    SightWord(id: 0, word: "go", color: Colors.red),
    SightWord(id: 0, word: "is", color: Colors.red),
    SightWord(id: 0, word: "my", color: Colors.red),
    SightWord(id: 0, word: "on", color: Colors.red),
    // orange words
    SightWord(id: 1, word: "me", color: Colors.orange),
    SightWord(id: 1, word: "in", color: Colors.orange),
    SightWord(id: 1, word: "so", color: Colors.orange),
    SightWord(id: 1, word: "it", color: Colors.orange),
    SightWord(id: 1, word: "up", color: Colors.orange),
    SightWord(id: 1, word: "at", color: Colors.orange),
    SightWord(id: 1, word: "he", color: Colors.orange),
    SightWord(id: 1, word: "do", color: Colors.orange),
    SightWord(id: 1, word: "you", color: Colors.orange),
    SightWord(id: 1, word: "no", color: Colors.orange),
    SightWord(id: 1, word: "am", color: Colors.orange),
    SightWord(id: 1, word: "big", color: Colors.orange),
    SightWord(id: 1, word: "play", color: Colors.orange),
    // yellow words
    SightWord(id: 1, word: "went", color: Colors.yellow),
    SightWord(id: 1, word: "are", color: Colors.yellow),
    SightWord(id: 1, word: "this", color: Colors.yellow),
    SightWord(id: 1, word: "look", color: Colors.yellow),
    SightWord(id: 1, word: "for", color: Colors.yellow),
    SightWord(id: 1, word: "get", color: Colors.yellow),
    SightWord(id: 1, word: "come", color: Colors.yellow),
    SightWord(id: 1, word: "not", color: Colors.yellow),
    SightWord(id: 1, word: "two", color: Colors.yellow),
    SightWord(id: 1, word: "was", color: Colors.yellow),
    SightWord(id: 1, word: "make", color: Colors.yellow),
    SightWord(id: 1, word: "they", color: Colors.yellow),
    // green words
    SightWord(id: 2, word: "will", color: Colors.green),
    SightWord(id: 2, word: "too", color: Colors.green),
    SightWord(id: 2, word: "all", color: Colors.green),
    SightWord(id: 2, word: "be", color: Colors.green),
    SightWord(id: 2, word: "ate", color: Colors.green),
    SightWord(id: 2, word: "one", color: Colors.green),
    SightWord(id: 2, word: "funny", color: Colors.green),
    SightWord(id: 2, word: "what", color: Colors.green),
    SightWord(id: 2, word: "did", color: Colors.green),
    SightWord(id: 2, word: "has", color: Colors.green),
    SightWord(id: 2, word: "of", color: Colors.green),
    SightWord(id: 2, word: "or", color: Colors.green),
    SightWord(id: 2, word: "with", color: Colors.green),
    // blue words
    SightWord(id: 3, word: "back", color: Colors.blue),
    SightWord(id: 3, word: "if", color: Colors.blue),
    SightWord(id: 3, word: "but", color: Colors.blue),
    SightWord(id: 3, word: "made", color: Colors.blue),
    SightWord(id: 3, word: "day", color: Colors.blue),
    SightWord(id: 3, word: "far", color: Colors.blue),
    SightWord(id: 3, word: "said", color: Colors.blue),
    SightWord(id: 3, word: "out", color: Colors.blue),
    SightWord(id: 3, word: "now", color: Colors.blue),
    SightWord(id: 3, word: "does", color: Colors.blue),
    SightWord(id: 3, word: "have", color: Colors.blue),
    SightWord(id: 3, word: "ran", color: Colors.blue),
    // purple words
    SightWord(id: 4, word: "came", color: Colors.purple),
    SightWord(id: 4, word: "its", color: Colors.purple),
    SightWord(id: 4, word: "man", color: Colors.purple),
    SightWord(id: 4, word: "she", color: Colors.purple),
    SightWord(id: 4, word: "use", color: Colors.purple),
    SightWord(id: 4, word: "word", color: Colors.purple),
    SightWord(id: 4, word: "his", color: Colors.purple),
    SightWord(id: 4, word: "more", color: Colors.purple),
    SightWord(id: 4, word: "write", color: Colors.purple),
    SightWord(id: 4, word: "yes", color: Colors.purple),
    SightWord(id: 4, word: "saw", color: Colors.purple),
    SightWord(id: 4, word: "way", color: Colors.purple),
    SightWord(id: 4, word: "who", color: Colors.purple),
    // pink words
    SightWord(id: 5, word: "been", color: Colors.pink),
    SightWord(id: 5, word: "your", color: Colors.pink),
    SightWord(id: 5, word: "each", color: Colors.pink),
    SightWord(id: 5, word: "good", color: Colors.pink),
    SightWord(id: 5, word: "hand", color: Colors.pink),
    SightWord(id: 5, word: "first", color: Colors.pink),
    SightWord(id: 5, word: "help", color: Colors.pink),
    SightWord(id: 5, word: "into", color: Colors.pink),
    SightWord(id: 5, word: "here", color: Colors.pink),
    SightWord(id: 5, word: "many", color: Colors.pink),
    SightWord(id: 5, word: "little", color: Colors.pink),
    SightWord(id: 5, word: "long", color: Colors.pink),
    // black words
    SightWord(id: 6, word: "must", color: Colors.black),
    SightWord(id: 6, word: "find", color: Colors.black),
    SightWord(id: 6, word: "new", color: Colors.black),
    SightWord(id: 6, word: "part", color: Colors.black),
    SightWord(id: 6, word: "please", color: Colors.black),
    SightWord(id: 6, word: "say", color: Colors.black),
    SightWord(id: 6, word: "there", color: Colors.black),
    SightWord(id: 6, word: "time", color: Colors.black),
    SightWord(id: 6, word: "want", color: Colors.black),
    SightWord(id: 6, word: "were", color: Colors.black),
    SightWord(id: 6, word: "well", color: Colors.black),
    SightWord(id: 6, word: "ride", color: Colors.black),
  ];
}
