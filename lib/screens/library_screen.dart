import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/models/playlist.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/screens/playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Playlist>>? _playlistsFuture;

  @override
  void initState() {
    super.initState();
    // We need the token to fetch playlists, so we get it from our AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.token != null) {
      _playlistsFuture = _apiService.fetchPlaylists(authProvider.token!);
    }
  }

  // This function will show the dialog for creating a new playlist.
  void _showCreatePlaylistDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Capture context-dependent variables BEFORE the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('New Playlist'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Playlist Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description (Optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // This is the beginning of the async gap
                  try {
                    await authProvider.createPlaylist(
                      name: nameController.text,
                      description: descriptionController.text,
                    );

                    // Check if the widget is still mounted AFTER the async gap.
                    if (!mounted) return;

                    navigator
                        .pop(); // Close the dialog using the captured navigator

                    scaffoldMessenger.showSnackBar(
                      // Use the captured scaffoldMessenger
                      const SnackBar(
                        content: Text('Playlist created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (error) {
                    if (!mounted) return;

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error: ${error.toString().replaceFirst('Exception: ', '')}'),
                        backgroundColor:
                            theme.colorScheme.error, // Use the captured theme
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: FutureBuilder<List<Playlist>>(
        future: _playlistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final playlists = snapshot.data!;
            return ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.name),
                  subtitle: Text(playlist.description ?? 'No description'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(
                child: Text('You haven\'t created any playlists yet.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context),
        tooltip: 'Create Playlist',
        child: const Icon(Icons.add),
      ),
    );
  }
}
