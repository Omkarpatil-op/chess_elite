import '../logging/app_logger.dart';

abstract class IAnalyticsService {
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty(String name, String value);
  void setAnalyticsCollectionEnabled(bool enabled);
}

class AnalyticsService implements IAnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  bool _isEnabled = true;
  String? _userId;

  @override
  void setAnalyticsCollectionEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    AppLogger.debug('Analytics: setUserId($_userId)');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!_isEnabled) return;
    AppLogger.debug('Analytics: setUserProperty($name, $value)');
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_isEnabled) return;
    AppLogger.debug('Analytics Event: $name params: $parameters');
  }

  // Predefined Standard Events
  Future<void> logAppOpen() => logEvent('app_open');
  Future<void> logGameStarted(String mode, String timeControl) => logEvent('game_started', {'mode': mode, 'time_control': timeControl});
  Future<void> logGameEnded(String result, String termination) => logEvent('game_ended', {'result': result, 'termination': termination});
  Future<void> logMatchmakingStarted(String timeControl) => logEvent('matchmaking_started', {'time_control': timeControl});
  Future<void> logMoveMade(int moveNumber, String san) => logEvent('move_made', {'move_number': moveNumber, 'san': san});
}
