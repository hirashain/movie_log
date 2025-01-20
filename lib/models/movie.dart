class Movie {
  String title;
  final String movieDirPath;
  String thumbnailPath;
  String? comment;
  bool isFavorite;
  final String id;

  Movie(
      {required this.title,
      required this.movieDirPath,
      required this.thumbnailPath,
      this.comment,
      required this.isFavorite,
      required this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'movieDirPath': movieDirPath,
      'thumbnailPath': thumbnailPath,
      'comment': comment,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'],
      movieDirPath: map['movieDirPath'],
      thumbnailPath: map['thumbnailPath'],
      comment: map['comment'],
      isFavorite: map['isFavorite'] == 1,
      id: map['id'],
    );
  }
}
