import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

import 'package:movie_log/main.dart';
import 'package:movie_log/models/movie.dart';
import 'package:movie_log/models/movie_log_provider.dart';

class MovieAddition extends StatefulWidget {
  const MovieAddition({super.key});

  @override
  MovieAdditionState createState() => MovieAdditionState();
}

class MovieAdditionState extends State<MovieAddition> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String _selectedImage = '';
  bool _isButtonEnabled = false;
  bool _isFavorite = false;

  // ウィジェットが作成されたときに一回だけ呼び出される
  @override
  void initState() {
    super.initState();
    // 入力内容の監視
    _titleController.addListener(_updateButtonState);
  }

  // ウィジェットが画面から削除されるたびに呼び出される
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _titleController.text.isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile.path;
      });
    }
  }

  Future<void> _saveMovieToDevice() async {
    final String uuid = const Uuid().v4();

    // Save the image to the app's internal storage
    final String imagePath = await _saveImageToInternalStorage(uuid);

    // Check if the widget is still mounted before using the context
    if (!mounted) return;

    // Add the movie with the new image path
    await _addMovie(uuid, imagePath);

    // Move to the home screen
    _moveToHomeScreen();
  }

  Future<String> _saveImageToInternalStorage(String movieId) async {
    if (_selectedImage.isEmpty) return '';

    final directory = await getApplicationDocumentsDirectory();
    final String movieDirPath = '${directory.path}/$movieId';
    final Directory movieDir = Directory(movieDirPath);

    if (!movieDir.existsSync()) {
      movieDir.createSync();
    }

    final String fileName = File(_selectedImage).path.split('/').last;
    final String newPath = '$movieDirPath/$fileName';
    final File newImage = await File(_selectedImage).copy(newPath);

    return newImage.path;
  }

  void _moveToHomeScreen() {
    Navigator.pop(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  Future<void> _addMovie(String movieId, String imagePath) async {
    final String title = _titleController.text;
    final String comment = _commentController.text;

    final newMovie = Movie(
        title: title,
        imagePath: imagePath,
        comment: comment,
        isFavorite: _isFavorite,
        id: movieId);
    await Provider.of<MovieLogProvider>(context, listen: false)
        .addMovieList(newMovie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 画像
                const Text('Images', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != ''
                      ? Image.file(
                          File(_selectedImage),
                          height: 160,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 160,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_circle),
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // 自由コメント
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Comment'),
                ),
                const SizedBox(height: 16),

                // 完了ボタン
                ElevatedButton(
                    onPressed: _isButtonEnabled ? _saveMovieToDevice : null,
                    child: const Icon(Icons.check))
              ],
            ),
          ),
        ));
  }
}
