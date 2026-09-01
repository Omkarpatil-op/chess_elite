import 'package:flutter/services.dart';

class HapticService {
  static final HapticService instance = HapticService._();
  HapticService._();

  bool _isHapticEnabled = true;
  bool get isHapticEnabled => _isHapticEnabled;

  void setHapticEnabled(bool enabled) {
    _isHapticEnabled = enabled;
  }

  /// Subtle click on piece selection
  Future<void> onPieceSelected() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Light tap on legal move
  Future<void> onMoveMade() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap on piece capture
  Future<void> onPieceCaptured() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact on check
  Future<void> onCheck() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Dual vibration on game over (checkmate, timeout)
  Future<void> onGameOver() async {
    if (!_isHapticEnabled) return;
    await HapticFeedback.vibrate();
  }
}
