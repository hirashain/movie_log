import 'package:flutter/material.dart';
import '../models/movie.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _commentController = TextEditingController(text: widget.movie.comment);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      widget.movie.title = _titleController.text;
      widget.movie.comment = _commentController.text;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 32.0),
                  ),
                ),
                Icon(
                  widget.movie.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.movie.isFavorite ? Colors.red : Colors.grey,
                  size: 40.0,
                ),
                const SizedBox(width: 30),
              ],
            ),
            // 画像表示
            widget.movie.imagePath != ''
                ? Image.file(
                    File(widget.movie.imagePath),
                    height: 300,
                    width: 225,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(fontSize: 16.0),
                maxLines: null,
              ),
            ),
          ],
        ));
  }
}
