import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// This is the main background audio handler class
class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Listen for changes in the player's state and broadcast them
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // We need to listen for when the player finds the duration of a track
    // and then update the main MediaItem with that duration.
    _listenForDurationChanges();
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final oldState = playbackState.value;
      final oldMediaItem = mediaItem.value;
      if (duration != null && oldMediaItem != null) {
        final newMediaItem = oldMediaItem.copyWith(duration: duration);
        mediaItem.add(newMediaItem);
        playbackState.add(oldState.copyWith(updatePosition: _player.position));
      }
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
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
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

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
