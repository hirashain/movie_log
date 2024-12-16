import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '.././models/movie.dart'; // Movieクラスをインポート

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: GridView.builder(
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
                    ? Image(
                        image: movie.images[0], fit: BoxFit.cover) // 画像を全体表示
                    : const Icon(Icons.image, size: 100),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMovieDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final List<ImageProvider> images = [];

    // 画像選択用のImagePickerインスタンスを作成
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Movie to Records'),
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
              Provider.of<MovieProvider>(context, listen: false)
                  .addToRecords(movie);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
