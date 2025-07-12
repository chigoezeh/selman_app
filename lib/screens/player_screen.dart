import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:selman/models/content.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selman/widgets/seek_bar.dart';

class PlayerScreen extends StatefulWidget {
  final Content content;
  const PlayerScreen({super.key, required this.content});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // We'd make sure the URL is accessible from your emulator/device.
      // Standard http might be blocked. Ensure usesCleartextTraffic="true" is in AndroidManifest.xml
      await _player.setUrl(widget.content.mediaUrl);
      _player.play();
    } catch (e) {
      print("Error loading audio source: $e");
      // Optionally, show a SnackBar or dialog to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        height: screenHeight,
        width: screenWidth,
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
            // Placeholder for Album Art
            Container(
              width: screenWidth * 0.75,
              height: screenWidth * 0.75,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  )
                ],
              ),
              child: const Icon(Icons.music_note,
                  size: 100, color: Colors.white54),
            ),
            const SizedBox(height: 32),
            // Track Title and Artist
            Text(
              widget.content.title,
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
              widget.content.minister?.name ?? 'Unknown Artist',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[400]),
            ),
            const Spacer(),
            // Placeholder for Progress Bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0:00'), Text('0:00')],
            ),
            const SizedBox(height: 16),
            // Player Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: const Icon(Icons.skip_previous,
                        size: 40, color: Colors.white),
                    onPressed: () {}),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const SizedBox(
                        width: 70.0,
                        height: 70.0,
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_circle,
                            color: Colors.white, size: 70),
                        onPressed: _player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause_circle,
                            color: Colors.white, size: 70),
                        onPressed: _player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay_circle_filled,
                            color: Colors.white, size: 70),
                        onPressed: () => _player.seek(Duration.zero),
                      );
                    }
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.skip_next,
                        size: 40, color: Colors.white),
                    onPressed: () {}),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
