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
}

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  bool _isSoundEnabled = true;
  double _volume = 1.0;

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
  }

  /// Play a chess sound effect
  Future<void> play(ChessSound sound) async {
    if (!_isSoundEnabled || _volume <= 0.0) return;

    try {
      // Use platform system feedback sound tones
      switch (sound) {
        case ChessSound.move:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.capture:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.check:
          await SystemSound.play(SystemSoundType.alert);
          break;
        case ChessSound.castle:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.gameStart:
          await SystemSound.play(SystemSoundType.alert);
          break;
        case ChessSound.gameEnd:
          await SystemSound.play(SystemSoundType.alert);
          break;
        case ChessSound.lowTime:
          await SystemSound.play(SystemSoundType.click);
          break;
        case ChessSound.notification:
          await SystemSound.play(SystemSoundType.alert);
          break;
      }
    } catch (e) {
      AppLogger.debug('Sound playback error: $e');
    }
  }
}
