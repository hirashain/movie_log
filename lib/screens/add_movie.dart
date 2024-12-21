import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:minio_new/minio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'package:movie_log/main.dart';
import 'package:movie_log/models/movie.dart';

class MovieAddition extends StatefulWidget {
  final String awsAccessKey;
  final String awsSecretKey;
  const MovieAddition(
      {super.key, required this.awsAccessKey, required this.awsSecretKey});

  @override
  MovieAdditionState createState() => MovieAdditionState();
}

class MovieAdditionState extends State<MovieAddition> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  File? _selectedImage;
  bool _isButtonEnabled = false;
  bool _isFavorite = false;
  late Minio minio;

  // ウィジェットが作成されたときに一回だけ呼び出される
  @override
  void initState() {
    super.initState();
    // 入力内容の監視
    _titleController.addListener(_updateButtonState);

    // AWS S3操作用オブジェクト
    minio = Minio(
        endPoint: 's3-ap-northeast-1.amazonaws.com',
        region: 'ap-northeast-1',
        accessKey: widget.awsAccessKey,
        secretKey: widget.awsSecretKey);
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

  void uploadMovieToAWS(Movie movie) async {
    uploadImageToS3(movie);
    saveMovieToDynamoDB(movie);
  }

  void uploadImageToS3(Movie movie) async {
    final byteData = await rootBundle.load(movie.image!.path);
    Stream<Uint8List> imageBytes = Stream.value(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    const String bucketName = "movielog-dev-images";
    const String uuid = "uuid";
    String imageObjectKey = '$uuid/${basename(movie.image!.path)}';
    await minio.putObject(
      bucketName,
      imageObjectKey,
      imageBytes,
    );
  }

  void saveMovieToDynamoDB(Movie movie) async {
    AwsClientCredentials credentials = AwsClientCredentials(
        accessKey: widget.awsAccessKey, secretKey: widget.awsSecretKey);

    final dynamoDb = DynamoDB(
      region: 'ap-northeast-1',
      credentials: credentials,
    );

    const tableName = 'movielog-dev-movies';
    final item = {
      'title': AttributeValue(s: movie.title),
      'comment': AttributeValue(s: movie.comment ?? ''),
      'imageObjectKey':
          AttributeValue(s: 'uuid/${basename(movie.image!.path)}'),
    };

    await dynamoDb.putItem(
      tableName: tableName,
      item: item,
    );
  }

  void _addMovie(BuildContext context) {
    final String title = _titleController.text;
    final String comment = _commentController.text;

    final newMovie = Movie(
      title: title,
      image: _selectedImage,
      comment: comment,
      isFavorite: _isFavorite,
    );
    context.read<MovieLogProvider>().addMovieList(newMovie);
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
                        _addMovie(context);
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
