abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => '[$code] $message';
}

class ChessRuleException extends AppException {
  const ChessRuleException(super.message, {super.code = 'CHESS_RULE_ERROR', super.details});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code = 'NETWORK_ERROR', super.details});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code = 'AUTH_ERROR', super.details});
}

class MatchmakingException extends AppException {
  const MatchmakingException(super.message, {super.code = 'MATCHMAKING_ERROR', super.details});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code = 'SERVER_ERROR', super.details});
}
