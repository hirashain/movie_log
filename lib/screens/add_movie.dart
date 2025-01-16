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
    // 映画インスタンスを作成
    Movie newMovie = await _makeNewMovie();

    // 画像を保存
    await _saveImageToInternalStorage(_selectedImage, newMovie.thumbnailPath);

    // マウントが解除されている場合、作成したディレクトリを削除してから処理を終了
    if (!mounted) {
      if (Directory(newMovie.movieDirPath).existsSync()) {
        Directory(newMovie.movieDirPath).deleteSync(recursive: true);
      }
      return;
    }

    // 映画情報を追加
    await Provider.of<MovieLogProvider>(context, listen: false)
        .addMovieList(newMovie);

    // ホーム画面に遷移
    _moveToHomeScreen();
  }

  Future<void> _saveImageToInternalStorage(
      String orgImagePath, String newImagePath) async {
    // 元画像パスの値が空(==画像が選択されていない)場合は何もしない
    if (orgImagePath == '') return;

    // 画像の保存先ディレクトリが存在しない場合は作成
    final Directory movieDir = Directory(newImagePath).parent;
    if (!movieDir.existsSync()) {
      movieDir.createSync();
    }

    // 画像をコピーして保存
    await File(orgImagePath).copy(newImagePath);

    return;
  }

  void _moveToHomeScreen() {
    Navigator.pop(context);
  }

  Future<Movie> _makeNewMovie() async {
    // 映画を一意に識別するためのID
    final String uuid = const Uuid().v4();

    // 映画に紐づく画像を保存するディレクトリ
    final directory = await getApplicationDocumentsDirectory();
    final String movieDirPath = '${directory.path}/$uuid';

    String thumbnailPath = '';
    if (_selectedImage != '') {
      final String imageUuid = const Uuid().v4();
      final String imageExtension = File(_selectedImage).path.split('.').last;
      thumbnailPath = '$movieDirPath/$imageUuid.$imageExtension';
    }

    final String title = _titleController.text;
    final String comment = _commentController.text;

    final newMovie = Movie(
        title: title,
        movieDirPath: movieDirPath,
        thumbnailPath: thumbnailPath,
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
                    // 映画タイトル入力フィールド
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                    ),
                    // お気に入りボタン
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

                // サムネ画像
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
