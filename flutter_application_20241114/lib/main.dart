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

  // ↓ Add this.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

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
        page = FavoritesPage();  // 这个是什么意思？//
        // 这个是一个占位符，用来占据空间，不显示任何内容。
        // 这里的意思是，当selectedIndex为1时，显示一个占位符。
        // selectedIndex是什么？
        // selectedIndex是一个变量，用来记录当前选中的导航栏目录的索引。
        // 当selectedIndex为0时，显示GeneratorPage，当selectedIndex为1时，显示一个占位符。
        // 怎么知道选中的某个导航栏目录的索引？
        // 通过NavigationRail的selectedIndex属性来控制。
        // 能具体讲讲NavigationRail的selectedIndex属性的控制过程吗
        // NavigationRail的selectedIndex属性是一个int类型的值，用来记录当前选中的导航栏目录的索引。
        // 当用户点击某个导航栏目录时，会触发onDestinationSelected回调，这个回调会传入一个int类型的值，这个值就是当前选中的导航栏目录的索引。
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