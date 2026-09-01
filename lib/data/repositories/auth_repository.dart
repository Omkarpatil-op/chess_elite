import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/models/user_profile.dart';

abstract class IAuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> loginWithEmail(String email, String password);
  Future<UserProfile> registerWithEmail(String username, String email, String password);
  Future<UserProfile> loginAsGuest();
  Future<void> logout();
  Future<void> deleteAccount();
}

class AuthRepository implements IAuthRepository {
  final StorageService _storage;
  final SecureStorageService _secureStorage;
  static const _userKey = 'cached_user_profile';
  static const _uuid = Uuid();

  UserProfile? _currentUser;

  AuthRepository({
    required this._storage,
    required this._secureStorage,
  });

  @override
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final jsonStr = _storage.getString(_userKey);
    if (jsonStr != null) {
      try {
        _currentUser = UserProfile.fromJson(jsonDecode(jsonStr));
        return _currentUser;
      } catch (_) {}
    }

    // Default: create initial local guest profile if none exists
    return loginAsGuest();
  }

  @override
  Future<UserProfile> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final profile = UserProfile(
      id: _uuid.v4(),
      username: email.split('@').first,
      email: email,
      ratingRapid: 1200,
      ratingBlitz: 1200,
      ratingBullet: 1200,
      ratingClassical: 1200,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    await _persistUser(profile, token: 'mock_jwt_${_uuid.v4()}');
    return profile;
  }

  @override
  Future<UserProfile> registerWithEmail(
    String username,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final profile = UserProfile(
      id: _uuid.v4(),
      username: username,
      email: email,
      ratingRapid: 1200,
      ratingBlitz: 1200,
      ratingBullet: 1200,
      ratingClassical: 1200,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    await _persistUser(profile, token: 'mock_jwt_${_uuid.v4()}');
    return profile;
  }

  @override
  Future<UserProfile> loginAsGuest() async {
    final guestId = _uuid.v4().substring(0, 6);
    final profile = UserProfile(
      id: 'guest_$guestId',
      username: 'Grandmaster_$guestId',
      ratingRapid: 1200,
      ratingBlitz: 1200,
      ratingBullet: 1200,
      ratingClassical: 1200,
      isGuest: true,
      createdAt: DateTime.now(),
    );

    await _persistUser(profile, token: 'guest_token_$guestId');
    return profile;
  }

  Future<void> _persistUser(UserProfile profile, {required String token}) async {
    _currentUser = profile;
    await _storage.setString(_userKey, jsonEncode(profile.toJson()));
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<void> updateProfile(UserProfile updated) async {
    _currentUser = updated;
    await _storage.setString(_userKey, jsonEncode(updated.toJson()));
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _storage.remove(_userKey);
    await _secureStorage.deleteAll();
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
    await _storage.clear();
    await _secureStorage.deleteAll();
  }
}
