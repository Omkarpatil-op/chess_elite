import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/matchmaking_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/social_repository.dart';
import '../security/secure_storage_service.dart';
import '../storage/storage_service.dart';

class ServiceLocator {
  static late final StorageService storage;
  static late final SecureStorageService secureStorage;
  static late final AuthRepository authRepository;
  static late final GameRepository gameRepository;
  static late final MatchmakingRepository matchmakingRepository;
  static late final SocialRepository socialRepository;
  static late final SettingsRepository settingsRepository;

  static Future<void> init() async {
    storage = await StorageService.init();
    secureStorage = SecureStorageService(storage);
    authRepository = AuthRepository(
      storage: storage,
      secureStorage: secureStorage,
    );
    gameRepository = GameRepository(storage);
    matchmakingRepository = MatchmakingRepository();
    socialRepository = SocialRepository();
    settingsRepository = SettingsRepository(storage);
  }
}
