import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:selman/screens/player_screen.dart';
import 'package:selman/services/audio_handler.dart';
import 'package:selman/models/content.dart';
import 'package:selman/models/minister.dart';

class MiniPlayer extends StatelessWidget {
  final MyAudioHandler audioHandler;

  const MiniPlayer({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        // Only show the mini-player if there is a track loaded
        if (mediaItem == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // This creates a temporary Content object to pass to the PlayerScreen.
            // It's needed because the MediaItem doesn't hold all our custom fields.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  content: Content(
                    id: 0, // Dummy data, not used by the player screen itself
                    title: mediaItem.title,
                    mediaUrl: mediaItem.id,
                    mediaType: 'audio',
                    durationInSeconds: mediaItem.duration?.inSeconds ?? 0,
                    minister: Minister(id: 0, name: mediaItem.artist ?? '...'),
                    // We can provide dummy data or null for other optional fields
                    thumbnailUrl: mediaItem.artUri?.toString(),
                  ),
                  // Tell the player screen NOT to restart the track.
                  playNow: false,
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
                    final processingState = snapshot.data?.processingState;
                    if (processingState == AudioProcessingState.loading ||
                        processingState == AudioProcessingState.buffering) {
                      return const SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.0)));
                    }
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
