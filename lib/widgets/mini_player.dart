import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:selman/screens/player_screen.dart';
import 'package:selman/services/audio_handler.dart';
import 'package:selman/models/content.dart';

class MiniPlayer extends StatelessWidget {
  final MyAudioHandler audioHandler;

  const MiniPlayer({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        // If there's no media item, show nothing
        if (mediaItem == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // This is a bit of a trick. The full content object isn't in the MediaItem.
            // We need to pass a dummy Content object for now.
            // A better solution would involve a global state for the current track.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  content: Content(
                    id: 0, // Dummy data
                    title: mediaItem.title,
                    mediaUrl: mediaItem.id,
                    minister: Minister(
                        id: 0, name: mediaItem.artist ?? '...'), // Dummy data
                  ),
                ),
              ),
            );
          },
          child: Container(
            height: 70,
            color: const Color(0xFF282828),
            child: Row(
              children: [
                // Album Art
                Container(
                  width: 70,
                  height: 70,
                  color: Colors.deepPurple,
                  child: mediaItem.artUri != null
                      ? Image.network(mediaItem.artUri.toString(),
                          fit: BoxFit.cover)
                      : const Icon(Icons.music_note, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                // Title and Artist
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mediaItem.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        mediaItem.artist ?? 'Unknown Artist',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Play/Pause Button
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow,
                          size: 32),
                      onPressed:
                          playing ? audioHandler.pause : audioHandler.play,
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
