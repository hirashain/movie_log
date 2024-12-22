import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';

class MovieLogProvider with ChangeNotifier {
  List<Movie> _movies = [];
  int _numColumns = 3;
  late Database _database;

  MovieLogProvider() {
    _initDatabase();
  }

  List<Movie> get movies => _movies;
  int get numColumns => _numColumns;

  Future<void> _initDatabase() async {
    final databasePath = join(await getDatabasesPath(), 'movie_log.db');

    _database = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE movies(id INTEGER PRIMARY KEY, title TEXT, imagePath TEXT, comment TEXT, isFavorite INTEGER)',
        );
      },
      version: 1,
    );
    await _loadMovies(_database);
  }

  Future<void> addMovieList(Movie movie) async {
    await _database.insert(
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
      );
    });
    notifyListeners();
  }

  void changeNumColumns(int newNumColumns) {
    _numColumns = newNumColumns;
    notifyListeners();
  }
}
