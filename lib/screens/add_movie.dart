import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

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
  List<String> _selectedImagePaths = [];
  bool _isButtonEnabled = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
  }

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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImagePaths = pickedFiles.map((file) => file.path).toList();
      });
    }
  }

  Future<void> _saveMovieToDevice() async {
    Movie newMovie = await _makeNewMovie();

    final Directory movieDir = Directory(newMovie.movieDirPath);
    if (!movieDir.existsSync()) {
      movieDir.createSync();
    }

    // 選択された画像をアプリ内ストレージに保存(失敗の場合ディレクトリを削除)
    for (String imagePath in _selectedImagePaths) {
      if (!mounted) {
        if (Directory(newMovie.movieDirPath).existsSync()) {
          Directory(newMovie.movieDirPath).deleteSync(recursive: true);
        }
        return;
      }
      String _ = await Provider.of<MovieLogProvider>(context, listen: false)
          .saveImageToInternalStorage(imagePath, newMovie);
    }

    // addMovieListでcontextを使うためmountedチェック
    if (!mounted) {
      if (Directory(newMovie.movieDirPath).existsSync()) {
        Directory(newMovie.movieDirPath).deleteSync(recursive: true);
      }
      return;
    }

    await Provider.of<MovieLogProvider>(context, listen: false)
        .addMovieList(newMovie);

    _moveToHomeScreen();
  }

  void _moveToHomeScreen() {
    Navigator.pop(context);
  }

  Future<Movie> _makeNewMovie() async {
    final String uuid = const Uuid().v4();
    final directory = await getApplicationDocumentsDirectory();
    final String movieDirPath = '${directory.path}/$uuid';

    final String title = _titleController.text;
    final String comment = _commentController.text;

    final newMovie = Movie(
        title: title,
        movieDirPath: movieDirPath,
        thumbnailPath:
            _selectedImagePaths.isNotEmpty ? _selectedImagePaths[0] : '',
        comment: comment,
        isFavorite: _isFavorite,
        id: uuid);

    return newMovie;
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
                const Text('Images', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: _selectedImagePaths.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _selectedImagePaths.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              File(_selectedImagePaths[index]),
                              fit: BoxFit.cover,
                            );
                          },
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
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Comment'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _isButtonEnabled ? _saveMovieToDevice : null,
                    child: const Icon(Icons.check))
              ],
            ),
          ),
        ));
  }
}
