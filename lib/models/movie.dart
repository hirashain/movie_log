import 'package:flutter/material.dart';
import 'dart:io';

class Movie {
  final String title;
  final File? image;
  final String? comment;
  final bool isFavorite;

  Movie(
      {required this.title,
      this.image,
      this.comment,
      required this.isFavorite});
}

class MovieLogProvider with ChangeNotifier {
  int _numColumns = 3;
  final List<Movie> _movies = [];

  int get numColumns => _numColumns;
  List<Movie> get movies => _movies;

  void addMovieList(Movie movie) {
    _movies.add(movie);
    notifyListeners();
  }

  void changeNumColumns(int num) {
    _numColumns = num;
    notifyListeners();
  }

  // void toggleFavorite(Movie movie) {
  //   if (_favorites.contains(movie)) {
  //     _favorites.remove(movie);
  //   } else {
  //     _favorites.add(movie);
  //   }
  //   notifyListeners();
  // }
}
