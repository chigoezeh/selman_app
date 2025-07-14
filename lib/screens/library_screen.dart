import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/screens/playlist_detail_screen.dart';
import 'package:selman/widgets/playlist_content_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch both playlists and favorites when the screen is first loaded
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchMyPlaylists();
    authProvider.fetchMyFavorites();
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger =
        ScaffoldMessenger.of(context); // Capture ScaffoldMessenger

    showDialog(
        context: context,
        builder: (dialogContext) {
          // Capture the navigator from the dialog's context before the async gap
          final dialogNavigator = Navigator.of(dialogContext);

          return AlertDialog(
            title: const Text('New Playlist'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Playlist Name'),
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
                onPressed: () => dialogNavigator.pop(),
              ),
              ElevatedButton(
                child: const Text('Create'),
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      await authProvider.createPlaylist(
                        name: nameController.text,
                        description: descriptionController.text,
                      );

                      // Use the captured navigator after the await
                      dialogNavigator.pop();
                    } catch (error) {
                      // Handle error
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('Error: ${error.toString()}')));
                      }
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the latest data from our provider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('My Library'),
              bottom: const TabBar(
                indicatorColor: Colors.deepPurple,
                tabs: [
                  Tab(text: 'Playlists'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // --- Playlists Tab View ---
                _buildPlaylistsView(authProvider),
                // --- Favorites Tab View ---
                _buildFavoritesView(authProvider),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreatePlaylistDialog(context),
              tooltip: 'Create Playlist',
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for the Playlists tab
  Widget _buildPlaylistsView(AuthProvider authProvider) {
    if (authProvider.playlists.isEmpty) {
      return const Center(
          child: Text('You haven\'t created any playlists yet.'));
    }
    return ListView.builder(
      itemCount: authProvider.playlists.length,
      itemBuilder: (context, index) {
        final playlist = authProvider.playlists[index];
        return ListTile(
          leading: const Icon(Icons.queue_music),
          title: Text(playlist.name),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailScreen(playlist: playlist),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for the Favorites tab
  Widget _buildFavoritesView(AuthProvider authProvider) {
    if (authProvider.favorites.isEmpty) {
      return const Center(
          child: Text('You haven\'t favorited any content yet.'));
    }
    // We can reuse the compact tile we made for playlist contents!
    return ListView.builder(
      itemCount: authProvider.favorites.length,
      itemBuilder: (context, index) {
        final contentItem = authProvider.favorites[index];
        return PlaylistContentTile(content: contentItem);
      },
    );
  }
}
