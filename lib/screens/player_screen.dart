import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selman/models/content.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/services/audio_handler.dart';
import 'package:selman/widgets/seek_bar.dart';

class PlayerScreen extends StatefulWidget {
  final Content content;
  const PlayerScreen({super.key, required this.content});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late MyAudioHandler _audioHandler;

  @override
  void initState() {
    super.initState();
    // Get the single audio handler instance from our provider
    _audioHandler = context.read<AuthProvider>().audioHandler;
    // Start playing the new track
    _playSelectedItem();
  }

  // Tell the handler to play the content passed to this screen
  void _playSelectedItem() {
    final mediaItem = MediaItem(
      id: widget.content.mediaUrl,
      title: widget.content.title,
      artist: widget.content.minister?.name ?? 'Unknown Artist',
      artUri: Uri.parse(widget.content.thumbnailUrl ??
          'https://i.imgur.com/4k3a2Y2.png'), // Using a placeholder
    );
    _audioHandler.playMediaItem(mediaItem);
  }

  // Combine the multiple streams from the handler for our SeekBar
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioHandler.playbackState
            .map((state) => state.updatePosition)
            .distinct(),
        _audioHandler.playbackState
            .map((state) => state.bufferedPosition)
            .distinct(),
        _audioHandler.mediaItem.map((item) => item?.duration).distinct(),
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Color(0xFF121212)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // We can now use the real album art URI
            StreamBuilder<MediaItem?>(
                stream: _audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final artUri = snapshot.data?.artUri;
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12.0),
                      image: artUri != null
                          ? DecorationImage(
                              image: NetworkImage(artUri.toString()),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        )
                      ],
                    ),
                    child: artUri == null
                        ? const Icon(Icons.music_note,
                            size: 100, color: Colors.white54)
                        : null,
                  );
                }),
            const SizedBox(height: 32),
            // Track Title and Artist
            StreamBuilder<MediaItem?>(
                stream: _audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  return Column(
                    children: [
                      Text(
                        mediaItem?.title ?? widget.content.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mediaItem?.artist ?? 'Unknown Artist',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  );
                }),
            const Spacer(),
            // Functional Seek Bar
            SeekBar(
              positionDataStream: _positionDataStream,
              onChangeEnd: _audioHandler.seek,
            ),
            const SizedBox(height: 16),
            // Functional Player Controls
            StreamBuilder<PlaybackState>(
              stream: _audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final processingState = playbackState?.processingState;
                final playing = playbackState?.playing;

                if (processingState == AudioProcessingState.loading ||
                    processingState == AudioProcessingState.buffering) {
                  return const SizedBox(
                      width: 70.0,
                      height: 70.0,
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (playing != true) {
                  return IconButton(
                      icon: const Icon(Icons.play_circle,
                          color: Colors.white, size: 70),
                      onPressed: _audioHandler.play);
                } else if (processingState != AudioProcessingState.completed) {
                  return IconButton(
                      icon: const Icon(Icons.pause_circle,
                          color: Colors.white, size: 70),
                      onPressed: _audioHandler.pause);
                } else {
                  return IconButton(
                      icon: const Icon(Icons.replay_circle_filled,
                          color: Colors.white, size: 70),
                      onPressed: () => _audioHandler.seek(Duration.zero));
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
