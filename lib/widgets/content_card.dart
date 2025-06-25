import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/screens/content_detail_screen.dart';

class ContentCard extends StatelessWidget {
  final Content content;

  const ContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // This is the navigation logic
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(content: content),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        clipBehavior: Clip.antiAlias, // Ensures the image corners are rounded
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for the content thumbnail image
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 60),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.minister?.name ?? 'Various Artists',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
