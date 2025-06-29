import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/models/playlist.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/widgets/content_card.dart';

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
              child: Text('This playlist is empty. Add some content!'),
            );
          }

          final playlist = snapshot.data!;
          return ListView.builder(
            itemCount: playlist.contents!.length,
            itemBuilder: (context, index) {
              final contentItem = playlist.contents![index];
              // We can reuse the same ContentCard we made for the home screen!
              return ContentCard(content: contentItem);
            },
          );
        },
      ),
    );
  }
}
