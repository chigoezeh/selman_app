import 'package:flutter/material.dart';
import 'package:selman/models/playlist.dart';

class PlaylistDetailScreen extends StatelessWidget {
  // This screen will receive the Playlist object that was tapped.
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display the name of the playlist in the AppBar
        title: Text(playlist.name),
      ),
      body: Center(
        child: Text(
            'Songs and content for "${playlist.name}" will be listed here.'),
      ),
    );
  }
}
