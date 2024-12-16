import 'package:flutter/material.dart';

class Movie {
  final String id;
  final String name;
  final List<ImageProvider> images;
  final String? review;
  final double? rating;
  bool isFavorite;

  Movie({
    required this.id,
    required this.name,
    required this.images,
    this.review,
    this.rating,
    this.isFavorite = false,
  });
}

class MovieProvider with ChangeNotifier {
  final List<Movie> _records = [];
  final List<Movie> _watchList = [];
  final List<Movie> _favorites = [];

  List<Movie> get records => _records;
  List<Movie> get watchList => _watchList;
  List<Movie> get favorites => _favorites;

  // Movieをrecordsリストに追加するメソッド
  void addToRecords(Movie movie) {
    _records.add(movie);
    notifyListeners();
  }

  // MovieをwatchListに追加するメソッド
  void addToWatchList(Movie movie) {
    _watchList.add(movie);
    notifyListeners();
  }

  // Movieをfavoritesリストに追加するメソッド
  void addToFavorites(Movie movie) {
    _favorites.add(movie);
    notifyListeners();
  }

  // お気に入りのオン/オフを切り替えるメソッド
  void toggleFavorite(Movie movie) {
    if (_favorites.contains(movie)) {
      _favorites.remove(movie);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }
}
