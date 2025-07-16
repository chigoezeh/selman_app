import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:selman/services/api_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _apiService = ApiService();
  Timer? _progressSyncTimer;
  String? _authToken;
  int? _currentContentId;

  MyAudioHandler() {
    // Listen for changes in the player's state and broadcast them
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _listenForDurationChanges();
  }

  // The UI will call this to provide the necessary auth details
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // The UI will call this to provide the content's database ID
  void setCurrentContentId(int? contentId) {
    _currentContentId = contentId;
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
      // Check for saved progress before setting the audio source
      Duration? initialPosition;
      if (_authToken != null && _currentContentId != null) {
        final savedProgress =
            await _apiService.fetchProgress(_currentContentId!, _authToken!);
        if (savedProgress != null) {
          initialPosition = Duration(seconds: savedProgress);
        }
      }

      // Set the audio source, and if we have a saved position, seek to it
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(mediaItem.id)),
        initialPosition: initialPosition,
      );

      play();
    } catch (e) {
      print("Error playing media item: $e");
    }
  }

  @override
  Future<void> play() {
    _startProgressTimer();
    return _player.play();
  }

  @override
  Future<void> pause() {
    _stopProgressTimer();
    return _player.pause();
  }

  @override
  Future<void> stop() async {
    _stopProgressTimer();
    await _player.stop();
    return await super.stop();
  }

  void _startProgressTimer() {
    _progressSyncTimer?.cancel();
    _progressSyncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _syncProgress();
    });
  }

  void _stopProgressTimer() {
    _syncProgress();
    _progressSyncTimer?.cancel();
  }

  void _syncProgress() {
    if (_authToken == null || _currentContentId == null || !_player.playing) {
      return;
    }
    _apiService.syncProgress(
      contentId: _currentContentId!,
      progressInSeconds: _player.position.inSeconds,
      token: _authToken!,
    );
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

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
