import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // We will fetch and display playlists here later

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
      body: const Center(
        child: Text('Your playlists will appear here.'),
        // Later, we will replace this with a ListView of playlists
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context),
        tooltip: 'Create Playlist',
        child: const Icon(Icons.add),
      ),
    );
  }
}
