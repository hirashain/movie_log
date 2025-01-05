import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';

class MovieLogProvider with ChangeNotifier {
  List<Movie> _movies = [];
  // 映画一覧画面に表示する列数
  int _numColumns = 3;
  // 映画のメタデータを保存するデータベース
  late Database _moviesDatabase;
  // ユーザー設定を保存するデータベース
  late Database _userSettingsDatabase;

  MovieLogProvider() {
    _initUserSettingsDatabase();
    _initMoviesDatabase();
  }

  List<Movie> get movies => _movies;
  int get numColumns => _numColumns;

  // ユーザー設定を保存するデータベースの初期化
  Future<void> _initUserSettingsDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'user_settings.db');

    _userSettingsDatabase = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_settings(id INTEGER PRIMARY KEY, numColumns INTEGER)',
        );
      },
      version: 1,
    );

    // データベースからユーザー設定を取得
    final List<Map<String, dynamic>> maps =
        await _userSettingsDatabase.query('user_settings');

    // データベースが空の場合は初期値を設定
    if (maps.isEmpty) {
      await _userSettingsDatabase.insert(
        'user_settings',
        {'numColumns': 3},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _numColumns = maps[0]['numColumns'];
    }
  }

  // 映画のメタデータを保存するデータベースの初期化
  Future<void> _initMoviesDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'movie_log.db');

    _moviesDatabase = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE movies(id TEXT PRIMARY KEY, title TEXT, imagePath TEXT, comment TEXT, isFavorite INTEGER)',
        );
      },
      version: 1,
    );
    await _loadMovies(_moviesDatabase);
  }

  // 映画情報を追加
  Future<void> addMovieList(Movie movie) async {
    // データベースに映画情報を追加
    await _moviesDatabase.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // メモリ上の映画情報リストにも追加
    _movies.add(movie);
    notifyListeners();
  }

  // データベースから映画情報を読み込む
  Future<void> _loadMovies(Database database) async {
    // データベースから映画情報を取得
    final List<Map<String, dynamic>> maps = await database.query('movies');
    // メモリ上の映画情報リストへMovie型に変換して追加
    _movies = List.generate(maps.length, (i) {
      return Movie(
        title: maps[i]['title'],
        imagePath: maps[i]['imagePath'],
        comment: maps[i]['comment'],
        isFavorite: maps[i]['isFavorite'] == 1,
        id: maps[i]['id'],
      );
    });
    notifyListeners();
  }

  // 映画情報を更新
  Future<void> updateMovie(Movie movie) async {
    // データベースの映画情報を更新
    await _moviesDatabase.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
    // メモリ上の映画情報リストも更新
    int index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _movies[index] = movie;
      notifyListeners();
    }
  }

  // 映画情報を削除
  Future<void> deleteMovie(String id) async {
    // データベースから映画情報を削除
    await _moviesDatabase.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    // メモリ上の映画情報リストからも削除
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
  }

  void changeNumColumns(int newNumColumns) {
    // 表示列数を更新
    _numColumns = newNumColumns;
    // データベースのユーザー設定を更新
    _userSettingsDatabase.update(
      'user_settings',
      {'numColumns': newNumColumns},
      where: 'id = 1',
    );
    notifyListeners();
  }
}
