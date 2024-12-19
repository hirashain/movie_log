// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/movie.dart';

// class MovieDetailScreen extends StatelessWidget {
//   final Movie movie;

//   const MovieDetailScreen({super.key, required this.movie});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(movie.title)),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 画像表示
//           movie.image != null,
//               ? Image(image: movie.image)
//               : const Icon(Icons.image, size: 100),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text('Review: ${movie.review ?? "No review"}'),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text('Rating: ${movie.rating ?? "No rating"}'),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 Provider.of<MovieProvider>(context, listen: false)
//                     .toggleFavorite(movie);
//               },
//               child: Text(movie.isFavorite ? 'Unfavorite' : 'Favorite'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
