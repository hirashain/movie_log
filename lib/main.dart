import 'package:flutter/material.dart';
import 'package:movie_log/screens/add_movie.dart';
import 'package:provider/provider.dart';
import 'models/movie.dart';
import 'screens/movies.dart';

// flutter runすると、lib/main.dartのmain関数が最初に呼び出される
void main() {
  // 指定したウィジェットをアプリケーションのルートウィジェットとして起動
  runApp(
    // 複数のプロバイダーを管理する
    // 今は一つだが、拡張性を考慮してマルチを使う
    MultiProvider(
      // リスト形式で複数のプロバイダーを定義可能
      providers: [
        // 受け渡すデータを更新可能にするため、ChangeNotifierProviderを使用
        // 受け渡すデータとはMovieProvider内で定義される変数たち
        // MovieProviderがChangeNotifierを継承(or mixin)するのが条件
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      // アプリの本体
      // MultiProviderに紐づいている
      child: const MovieLogApp(),
    ),
  );
}

// Statelessウィジェットを継承したMovieLogウィジェット
// このウィジェット自体は状態を持たない（=見た目が変化しない）
class MovieLogApp extends StatelessWidget {
  // keyはWidgetの識別子
  // 識別可能にすることでキャッシュ的なかんじでビルドを効率化する
  const MovieLogApp({super.key});

  // 画面のビルドを定義
  // 描画時のコンテキスト情報が勝手に渡ってくる
  @override
  Widget build(BuildContext context) {
    // アプリ全体の設定や構造を提供するウィジェット
    // こいつの子ウィジェットとしてScaffoldとかが登場する
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

// ホーム画面
// 見た目が変化する(可能性がある)ウィジェットのため、StatefulWidgeを継承
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // ウィジェットに結び付いた、実際に状態を管理するオブジェクト
  // 名称はウィジェット名+Stateが条件
  @override
  HomeScreenState createState() => HomeScreenState();
}

// ホーム画面の状態を管理するStateオブジェクト
class HomeScreenState extends State<HomeScreen> {
  bool _onlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    // 画面全体の構造を定義するウィジェット
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Movie Log'),
        actions: [
          // 映画追加
          IconButton(
            // 押したときに呼ばれる関数
            onPressed: () {
              Navigator.push(
                context,
                // 遷移先の画面
                MaterialPageRoute(
                  builder: (context) => const MovieAddition(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: "Register",
          ),
          // お気に入りボタン
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
          // フィルターボタン
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Movies(onlyFavorite: _onlyFavorite),
    );
  }
}
