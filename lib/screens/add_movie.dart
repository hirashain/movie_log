import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:movie_log/main.dart';
import 'package:movie_log/models/movie.dart';

class MovieAddition extends StatefulWidget {
  const MovieAddition({super.key});

  @override
  MovieAdditionState createState() => MovieAdditionState();
}

class MovieAdditionState extends State<MovieAddition> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  File? _selectedImage;
  bool _isButtonEnabled = false;

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
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addMovie() {
    final String title = _titleController.text;
    final String comment = _commentController.text;
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Input title!")));
      return;
    }

    final newMovie =
        Movie(title: title, image: _selectedImage, comment: comment);
    context.read<MovieProvider>().addMovieList(newMovie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),

            // 画像
            const Text('Images', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
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
                onPressed: _isButtonEnabled
                    ? () {
                        _addMovie();
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    : null,
                child: const Icon(Icons.check))
          ],
        ));
  }
}
