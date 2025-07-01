import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/widgets/favorite_button.dart';

class ContentDetailScreen extends StatelessWidget {
  // This screen will receive a Content object.
  final Content content;

  const ContentDetailScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar will show the title of the content.
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // We extend the body behind the AppBar for a modern, seamless look.
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thumbnail and Play Button ---
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 80),
            ),

            // --- Details Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FavoriteButton(content: content),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.minister?.name ?? 'Unknown Artist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // --- Action Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(context,
                          icon: Icons.playlist_add, label: 'Add to Playlist'),
                      _buildActionButton(context,
                          icon: Icons.download_for_offline, label: 'Download'),
                      _buildActionButton(context,
                          icon: Icons.share, label: 'Share'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Description ---
                  Text(
                    content.description ?? 'No description available.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the action buttons consistently.
  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
