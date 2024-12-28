import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';

class MovieLogProvider with ChangeNotifier {
  List<Movie> _movies = [];
  int _numColumns = 3;
  late Database _moviesDatabase;
  late Database _userSettingsDatabase;

  MovieLogProvider() {
    _initUserSettingsDatabase();
    _initMoviesDatabase();
  }

  List<Movie> get movies => _movies;
  int get numColumns => _numColumns;

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

    final List<Map<String, dynamic>> maps =
        await _userSettingsDatabase.query('user_settings');
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

  Future<void> addMovieList(Movie movie) async {
    await _moviesDatabase.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _movies.add(movie);
    notifyListeners();
  }

  Future<void> _loadMovies(Database database) async {
    final List<Map<String, dynamic>> maps = await database.query('movies');
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

  Future<void> updateMovie(Movie movie) async {
    await _moviesDatabase.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
    int index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _movies[index] = movie;
      notifyListeners();
    }
  }

  void changeNumColumns(int newNumColumns) {
    _numColumns = newNumColumns;
    _userSettingsDatabase.update(
      'user_settings',
      {'numColumns': newNumColumns},
      where: 'id = 1',
    );
    notifyListeners();
  }
}
