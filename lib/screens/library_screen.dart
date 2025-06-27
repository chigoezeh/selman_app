import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('My Library')),
      body: Center(
        child: Text('Playlists, Favorites, and Downloads will appear here.'),
      ),
    );
  }
}
