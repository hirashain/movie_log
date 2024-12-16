import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      body: ListView.builder(
        itemCount: movieProvider.favorites.length,
        itemBuilder: (context, index) {
          final movie = movieProvider.favorites[index];
          return ListTile(
            leading: movie.images.isNotEmpty
                ? Image(image: movie.images[0], width: 50, height: 50)
                : const Icon(Icons.image),
            title: Text(movie.name),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
              ),
            ),
          );
        },
      ),
    );
  }
}
