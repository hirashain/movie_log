import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/movie.dart';
import 'screens/records_screen.dart';
import 'screens/watch_screen.dart';
import 'screens/favorites_screen.dart';

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
      title: 'MovieLog',
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
  // 選択中のタブのインデックス
  int _selectedIndex = 0;

  // タブとして切り替えたいウィジェットのリスト
  // constを使用することで画面が再構築されるたびに新しいインスタンスを作成しないようにする
  // _screens変数はリストとして扱い続けるため、finalで再代入を防ぐ
  final List<Widget> _screens = [
    const RecordsScreen(),
    const WatchScreen(),
    const FavoritesScreen(),
  ];

  // タブがタップされたときに呼び出したい関数
  // タブのインデックスを受け取り、選択中のタブのインデックスを更新する
  void _onTabTapped(int index) {
    // setStateが呼び出されるとbuildが再実行される
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面全体の構造を定義するウィジェット
    return Scaffold(
      appBar: AppBar(title: const Text('MovieLog')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // これがないと選択中のタブがハイライトされない
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Watch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}
