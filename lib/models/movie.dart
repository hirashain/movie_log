import 'package:flutter/material.dart';
import 'dart:io';

class Movie {
  final String title;
  final File? image;

  Movie({required this.title, this.image});
}

class MovieProvider with ChangeNotifier {
  final List<Movie> _movies = [];

  List<Movie> get movies => _movies;

  void addMovieList(Movie movie) {
    print("Listennnnnnnnnnnnn");
    _movies.add(movie);
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
