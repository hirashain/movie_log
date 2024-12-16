import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '.././models/movie.dart';

class Movies extends StatelessWidget {
  const Movies({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 横に3列表示
        crossAxisSpacing: 8.0, // 列間のスペース
        mainAxisSpacing: 8.0, // 行間のスペース
        childAspectRatio: 1.0, // サムネイルのアスペクト比（正方形）
      ),
      itemCount: movieProvider.records.length,
      itemBuilder: (context, index) {
        final movie = movieProvider.records[index];

        return GestureDetector(
          onTap: () {
            // サムネイルタップ時に映画詳細を表示する処理
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: movie.images.isNotEmpty
                  ? Image(image: movie.images[0], fit: BoxFit.cover) // 画像を全体表示
                  : const Icon(Icons.image, size: 100),
            ),
          ),
        );
      },
    );
  }
}
