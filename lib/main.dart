import 'package:flutter/material.dart';
import 'package:movie_log/screens/add_movie.dart';
import 'package:movie_log/screens/settings.dart';
import 'package:provider/provider.dart';
import 'models/movie_log_provider.dart';
import 'screens/movies.dart';

void main() {
  runApp(
    // 複数のプロバイダーを管理する
    // 今は一つだが、拡張性を考慮してマルチを使う
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieLogProvider()),
      ],
      child: const MovieLogApp(),
    ),
  );
}

class MovieLogApp extends StatelessWidget {
  // key識別子によって識別可能にすることでキャッシュを利用してビルドを効率化する
  const MovieLogApp({super.key});

  // 親ウィジェットの情報をcontextとして受け取る
  @override
  Widget build(BuildContext context) {
    // アプリ全体の設定や構造を提供するウィジェット
    return MaterialApp(
      // タスクマネージャー等に表示されるアプリ名
      title: 'Movie Log',
      // アプリ全体のテーマ設定
      theme: ThemeData(primarySwatch: Colors.blue),
      // アプリの画面
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// ホーム画面の状態を管理するStateオブジェクト
class HomeScreenState extends State<HomeScreen> {
  bool _onlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Movie Log'),
        actions: [
          // 映画追加ボタン
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovieAddition(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: "Register",
          ),
          // お気に入りのみ/全て表示の切り替えボタン
          IconButton(
            onPressed: () {
              setState(() {
                _onlyFavorite = !_onlyFavorite;
              });
            },
            icon: Icon(
              _onlyFavorite ? Icons.favorite : Icons.favorite_border,
              color: _onlyFavorite ? Colors.red : Colors.grey,
            ),
          ),
          // 設定画面に遷移するボタン
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Movies(onlyFavorite: _onlyFavorite),
    );
  }
}
