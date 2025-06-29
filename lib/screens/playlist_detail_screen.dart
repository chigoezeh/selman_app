import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/models/playlist.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/widgets/content_card.dart';
import 'package:selman/widgets/playlist_content_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final ApiService _apiService = ApiService();
  Future<Playlist>? _playlistDetailsFuture;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.token != null) {
      setState(() {
        _playlistDetailsFuture = _apiService.fetchPlaylistDetails(
            widget.playlist.id, authProvider.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: FutureBuilder<Playlist>(
        future: _playlistDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.contents!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "It's lonely here.",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add songs to this playlist to see them here.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final playlist = snapshot.data!;
          return ListView.builder(
            itemCount: playlist.contents!.length,
            itemBuilder: (context, index) {
              return ListView.builder(
                itemCount: playlist.contents!.length,
                itemBuilder: (context, index) {
                  final contentItem = playlist.contents![index];
                  // Use our new, compact tile instead of the big card
                  return PlaylistContentTile(content: contentItem);
                },
              );
            },
          );
        },
      ),
    );
  }
}
