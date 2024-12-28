import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  void _saveMovieToDevice() async {
    // データの追加
    await _addMovie(context);

    // ホーム画面に戻る
    _moveToHomeScreen();
  }

  void _moveToHomeScreen() {
    Navigator.pop(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  Future<void> _addMovie(BuildContext context) async {
    final String title = _titleController.text;
    final String comment = _commentController.text;

    final newMovie = Movie(
        title: title,
        imagePath: _selectedImage,
        comment: comment,
        isFavorite: _isFavorite,
        id: title.hashCode);
    await Provider.of<MovieLogProvider>(context, listen: false)
        .addMovieList(newMovie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
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
        ));
  }
}
