import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieDetail extends StatelessWidget {
  final Movie movie;

  const MovieDetail({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              textScaler: const TextScaler.linear(4.0),
            ),
            // 画像表示
            movie.image != null
                ? Image.file(
                    movie.image!,
                    height: 300,
                    width: 225,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.comment ?? "Comment",
                textScaler: const TextScaler.linear(2.0),
              ),
            ),
          ],
        ));
  }
}
