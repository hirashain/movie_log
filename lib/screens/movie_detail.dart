import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../models/movie_log_provider.dart';
import 'dart:io';

class MovieDetail extends StatefulWidget {
  final Movie movie;

  const MovieDetail({super.key, required this.movie});

  @override
  MovieDetailState createState() => MovieDetailState();
}

class MovieDetailState extends State<MovieDetail> {
  late TextEditingController _titleController;
  late TextEditingController _commentController;
  late bool _isFavorite = false;
  late MovieLogProvider _movieLogProvider;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _commentController = TextEditingController(text: widget.movie.comment);
    _isFavorite = widget.movie.isFavorite;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _movieLogProvider = Provider.of<MovieLogProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // Movieプロパティを更新
    widget.movie.title = _titleController.text;
    widget.movie.comment = _commentController.text;
    widget.movie.isFavorite = _isFavorite;
    _movieLogProvider.updateMovie(widget.movie);

    // メモリ解放
    _titleController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  // 削除ボタン押下時に呼ばれる関数
  void _deleteMovie() {
    // 画像ファイルが存在する場合は削除
    if (widget.movie.imagePath.isNotEmpty) {
      final File imageFile = File(widget.movie.imagePath);
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
      }
    }

    // データベースから削除
    _movieLogProvider.deleteMovie(widget.movie.id);

    // 画面を閉じる
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteMovie,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 映画タイトル
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 32.0),
                    ),
                  ),
                  // お気に入りボタン
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              // サムネ画像
              widget.movie.imagePath != ''
                  ? Image.file(
                      File(widget.movie.imagePath),
                      height: 300,
                      width: 225,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 100),
              // コメント
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(fontSize: 16.0),
                  maxLines: null,
                ),
              ),
            ],
          ),
        ));
  }
}
