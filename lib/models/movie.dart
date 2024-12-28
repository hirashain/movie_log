class Movie {
  String title;
  final String imagePath;
  String? comment;
  bool isFavorite;
  final int id;

  Movie(
      {required this.title,
      required this.imagePath,
      this.comment,
      required this.isFavorite,
      required this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      id: map['id'],
    );
  }
}
