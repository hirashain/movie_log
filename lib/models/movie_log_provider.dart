import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

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
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE movies(id TEXT PRIMARY KEY, title TEXT, movieDirPath TEXT, thumbnailPath TEXT, comment TEXT, isFavorite INTEGER)',
        );
      },
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
        movieDirPath: maps[i]['movieDirPath'],
        thumbnailPath: maps[i]['thumbnailPath'],
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

  Future<void> deleteMovie(Movie movie) async {
    // Movieインスタンスに紐づいたディレクトリを削除
    final directory = await getApplicationDocumentsDirectory();
    final String movieDirPath = '${directory.path}/${movie.id}';
    final Directory movieDir = Directory(movieDirPath);
    if (movieDir.existsSync()) {
      movieDir.deleteSync(recursive: true);
    }

    // データベースから映画情報を削除
    await _moviesDatabase.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [movie.id],
    );

    // メモリ上の映画情報リストから削除
    _movies.removeWhere((m) => m.id == movie.id);

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

  Future<String> saveImageToInternalStorage(
      String orgImagePath, Movie movie) async {
    if (orgImagePath.isEmpty) return '';

    final String imgExt = orgImagePath.split('.').last;
    final String fileName = '${const Uuid().v4()}.$imgExt';
    final String newPath = '${movie.movieDirPath}/$fileName';
    await File(orgImagePath).copy(newPath);

    if (orgImagePath == movie.thumbnailPath) {
      movie.thumbnailPath = newPath;
    }

    return newPath;
  }
}
