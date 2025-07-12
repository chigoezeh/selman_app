import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// This is the main background audio handler class
class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Listen for changes in the player's state and broadcast them
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // This method will be called by our UI to start a new track
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    // Tell the UI and the system what we're playing
    this.mediaItem.add(mediaItem);
    try {
      await _player.setUrl(mediaItem.id); // The mediaItem.id will be our URL
      play();
    } catch (e) {
      print("Error playing media item: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  // Helper method to transform just_audio events into audio_service states
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
