import 'package:flutter/material.dart';
import 'package:movie_log/models/movie.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<MovieLogProvider>(
        builder: (context, movieLogProvider, child) {
          return ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text('Number of Columns'),
                subtitle: Slider(
                  value: movieLogProvider.numColumns.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: movieLogProvider.numColumns.toString(),
                  onChanged: (double value) {
                    movieLogProvider.changeNumColumns(value.toInt());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
