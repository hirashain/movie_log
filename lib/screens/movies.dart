import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '.././models/movie.dart';

class Movies extends StatelessWidget {
  const Movies({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(builder: (context, movieProvider, child) {
        final movies = movieProvider.movies;
        return movies.isEmpty
            ? const Center(
                child: Text(
                  "No Movie",
                  textScaler: TextScaler.linear(5.0),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 横に3列表示
                  crossAxisSpacing: 0, // 列間のスペース
                  mainAxisSpacing: 0, // 行間のスペース
                  childAspectRatio: 0.75, // サムネイルのアスペクト比
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                      onTap: () {
                        // サムネイルタップ時に映画詳細を表示する処理
                      },
                      child: movie.image != null
                          ? Image.file(
                              movie.image!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 100));
                },
              );
      }),
    );
  }
}
