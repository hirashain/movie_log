import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '.././models/movie_log_provider.dart';
import 'movie_detail.dart';

class Movies extends StatefulWidget {
  final bool onlyFavorite;
  const Movies({super.key, required this.onlyFavorite});

  @override
  MoviesState createState() => MoviesState();
}

class MoviesState extends State<Movies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieLogProvider>(
        builder: (context, movieLogProvider, child) {
          // 登録済みの映画情報を取得
          final movies = movieLogProvider.movies;
          return movies.isEmpty
              ? const Center(
                  child: Text(
                    "No Movie",
                    textScaler: TextScaler.linear(5.0),
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: movieLogProvider.numColumns,
                    // 列間のスペース
                    crossAxisSpacing: 0,
                    // 行間のスペース
                    mainAxisSpacing: 0,
                    // 表示画像のアスペクト比(横/縦)
                    childAspectRatio: 0.75,
                  ),
                  itemCount: widget.onlyFavorite
                      ? movies
                          .where((movie) => movie.isFavorite)
                          .toList()
                          .length
                      : movies.length,
                  itemBuilder: (context, index) {
                    final movie = widget.onlyFavorite
                        ? movies
                            .where((movie) => movie.isFavorite)
                            .toList()[index]
                        : movies[index];
                    return GestureDetector(
                        onTap: () {
                          // サムネイルタップ時に映画詳細画面に遷移
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetail(movie: movie)));
                        },
                        child: movie.thumbnailPath != ''
                            ? Image.file(
                                File(movie.thumbnailPath),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 100));
                  },
                );
        },
      ),
    );
  }
}
