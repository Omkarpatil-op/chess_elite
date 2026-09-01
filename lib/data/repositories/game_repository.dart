import 'dart:convert';
import '../../core/storage/storage_service.dart';
import '../../domain/models/chess_match.dart';

abstract class IGameRepository {
  Future<List<ChessMatch>> getMatchHistory();
  Future<void> saveMatch(ChessMatch match);
  Future<ChessMatch?> getMatchById(String id);
  Future<void> clearHistory();
}

class GameRepository implements IGameRepository {
  final StorageService _storage;
  static const _historyKey = 'chess_match_history_v1';

  GameRepository(this._storage);

  @override
  Future<List<ChessMatch>> getMatchHistory() async {
    final list = _storage.getStringList(_historyKey);
    final matches = <ChessMatch>[];
    for (final jsonStr in list) {
      try {
        matches.add(ChessMatch.fromJson(jsonDecode(jsonStr)));
      } catch (_) {}
    }
    // Sort descending by start time
    matches.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return matches;
  }

  @override
  Future<void> saveMatch(ChessMatch match) async {
    final matches = await getMatchHistory();
    matches.removeWhere((m) => m.id == match.id);
    matches.insert(0, match);

    // Limit cached matches to latest 50
    final trimmed = matches.take(50).toList();
    final jsonList = trimmed.map((m) => jsonEncode(m.toJson())).toList();
    await _storage.setStringList(_historyKey, jsonList);
  }

  @override
  Future<ChessMatch?> getMatchById(String id) async {
    final matches = await getMatchHistory();
    for (final m in matches) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Future<void> clearHistory() async {
    await _storage.remove(_historyKey);
  }
}
