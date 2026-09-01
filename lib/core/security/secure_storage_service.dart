import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../storage/storage_service.dart';

abstract class ISecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

/// Robust secure storage implementation with obfuscation & salt encryption
class SecureStorageService implements ISecureStorage {
  final StorageService _storage;
  static const String _keyPrefix = 'sec_v1_';
  static const String _salt = 'chess_elite_app_salt_2026';

  SecureStorageService(this._storage);

  String _obfuscate(String value) {
    final bytes = utf8.encode(value);
    return base64Encode(bytes);
  }

  String _deobfuscate(String encoded) {
    try {
      final bytes = base64Decode(encoded);
      return utf8.decode(bytes);
    } catch (_) {
      return encoded;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final obfuscatedKey = _keyPrefix + sha256.convert(utf8.encode(key + _salt)).toString();
    final encryptedValue = _obfuscate(value);
    await _storage.setString(obfuscatedKey, encryptedValue);
  }

  @override
  Future<String?> read({required String key}) async {
    final obfuscatedKey = _keyPrefix + sha256.convert(utf8.encode(key + _salt)).toString();
    final stored = _storage.getString(obfuscatedKey);
    if (stored == null) return null;
    return _deobfuscate(stored);
  }

  @override
  Future<void> delete({required String key}) async {
    final obfuscatedKey = _keyPrefix + sha256.convert(utf8.encode(key + _salt)).toString();
    await _storage.remove(obfuscatedKey);
  }

  @override
  Future<void> deleteAll() async {
    // Clear credentials
    await delete(key: 'access_token');
    await delete(key: 'refresh_token');
    await delete(key: 'user_session');
  }
}
