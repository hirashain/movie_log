class Movie {
  final String title;
  final String imagePath;
  final String? comment;
  final bool isFavorite;

  Movie(
      {required this.title,
      required this.imagePath,
      this.comment,
      required this.isFavorite});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imagePath': imagePath,
      'comment': comment,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'],
      imagePath: map['imagePath'],
      comment: map['comment'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
