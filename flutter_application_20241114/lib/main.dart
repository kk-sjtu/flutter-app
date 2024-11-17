import 'package:english_words/english_words.dart';
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
        title: 'Namer App',
        debugShowCheckedModeBanner: false, // 添加这一行
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 59, 46, 117)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[];

  void getLast() {
  if (history.isNotEmpty) {
    current = history.removeLast();
    print('Current word pair: $current'); // 调试输出
    notifyListeners();
  } else {
    print('History is empty'); // 调试输出
  }
}
  // ↓ Add this.
  void getNext() {
    history.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  void clearFavorites() {
    favorites.clear();
    notifyListeners();
  }

}

// ...
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
        break;
      case 1:
        page = FavoritesPage();  
        break;
      default:
    throw UnimplementedError('no widget for $selectedIndex');
    }


    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 450,// 这段话是什么意思？//
                  // 这个属性是用来控制导航栏是否展开的，当屏幕宽度大于等于300时，导航栏展开，否则收起。
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
      }
    );
  }
}
class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
        var appState = context.watch<MyAppState>(); // 这个是什么意思？ //// 这个是一个监听器，用来监听MyAppState的变化。
        // 当MyAppState发生变化时，FavoritesPage会自动刷新。
        var favorites = context.watch<MyAppState>().favorites;
        var theme = Theme.of(context); // 获取当前主题

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              appState.clearFavorites();
            },
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Center(
        child: favorites.isEmpty
            ? Text('No favorites yet.')
            : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(favorites[index].asLowerCase),
                ),
              ),
      ),
    );
            
          
        
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),

              SizedBox(width: 10),
              ElevatedButton(
                onPressed:(){
                  appState.getLast();
                },
                child:Text('Last'),
              ),
              SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),

            ],

          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.all(40),

        // ↓ Make the following change.
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
  
}