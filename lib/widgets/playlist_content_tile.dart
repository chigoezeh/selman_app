import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/screens/player_screen.dart';

class PlaylistContentTile extends StatelessWidget {
  final Content content;

  const PlaylistContentTile({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
        ),
        // We'll add a real thumbnail image here later
        child: const Icon(Icons.music_note, color: Colors.white70),
      ),
      title: Text(
        content.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        content.minister?.name ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // Logic for the "more options" menu will go here
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(content: content),
          ),
        );
      },
    );
  }
}
