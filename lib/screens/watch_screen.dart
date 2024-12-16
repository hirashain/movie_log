import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import './movie_detail_screen.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      body: ListView.builder(
        itemCount: movieProvider.watchList.length,
        itemBuilder: (context, index) {
          final movie = movieProvider.watchList[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(context, 'watchlist'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMovieDialog(BuildContext context, String listType) async {
    final TextEditingController nameController = TextEditingController();
    final List<ImageProvider> images = [];

    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Movie to $listType'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Movie Name')),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    images.add(Image.file(File(pickedFile.path)).image);
                  }
                },
                child: const Text('Add Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final movie = Movie(
                id: DateTime.now().toString(),
                name: nameController.text,
                images: images,
              );
              if (listType == 'watchlist') {
                Provider.of<MovieProvider>(context, listen: false)
                    .addToWatchList(movie);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
