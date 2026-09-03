import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../logging/app_logger.dart';

enum ChessSound {
  move,
  capture,
  check,
  castle,
  gameStart,
  gameEnd,
  lowTime,
  notification,
  buttonClick,
}

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  double _volume = 1.0;

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
  }

  /// Play a chess sound effect
  Future<void> play(ChessSound sound) async {
    if (!_isSoundEnabled || _volume <= 0.0) return;

    try {
      // Primary: System Sound clicks & alerts for low-latency feedback
      switch (sound) {
        case ChessSound.move:
        case ChessSound.castle:
        case ChessSound.buttonClick:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.capture:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.check:
        case ChessSound.gameStart:
        case ChessSound.gameEnd:
        case ChessSound.notification:
          await SystemSound.play(SystemSoundType.alert);
          break;
        case ChessSound.lowTime:
          await SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (e) {
      AppLogger.debug('Sound playback note: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
