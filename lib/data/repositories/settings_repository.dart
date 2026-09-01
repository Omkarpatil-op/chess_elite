import 'package:flutter/material.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/board_themes.dart';
import '../../core/theme/piece_themes.dart';

class UserSettings {
  final ThemeMode themeMode;
  final BoardThemeType boardTheme;
  final PieceStyle pieceStyle;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool showCoordinates;
  final bool showLegalMoves;
  final bool autoQueenPromotion;
  final bool confirmResign;
  final bool confirmDraw;

  const UserSettings({
    this.themeMode = ThemeMode.dark,
    this.boardTheme = BoardThemeType.classicWood,
    this.pieceStyle = PieceStyle.stauntonClassic,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.showCoordinates = true,
    this.showLegalMoves = true,
    this.autoQueenPromotion = false,
    this.confirmResign = true,
    this.confirmDraw = true,
  });

  UserSettings copyWith({
    ThemeMode? themeMode,
    BoardThemeType? boardTheme,
    PieceStyle? pieceStyle,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? showCoordinates,
    bool? showLegalMoves,
    bool? autoQueenPromotion,
    bool? confirmResign,
    bool? confirmDraw,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      boardTheme: boardTheme ?? this.boardTheme,
      pieceStyle: pieceStyle ?? this.pieceStyle,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showLegalMoves: showLegalMoves ?? this.showLegalMoves,
      autoQueenPromotion: autoQueenPromotion ?? this.autoQueenPromotion,
      confirmResign: confirmResign ?? this.confirmResign,
      confirmDraw: confirmDraw ?? this.confirmDraw,
    );
  }
}

abstract class ISettingsRepository {
  UserSettings getSettings();
  Future<void> saveSettings(UserSettings settings);
}

class SettingsRepository implements ISettingsRepository {
  final StorageService _storage;

  SettingsRepository(this._storage);

  @override
  UserSettings getSettings() {
    final themeModeIndex = _storage.getInt('settings_theme_mode', defaultValue: 0); // 0=dark, 1=light, 2=system
    final boardThemeIndex = _storage.getInt('settings_board_theme', defaultValue: 0);
    final pieceStyleIndex = _storage.getInt('settings_piece_style', defaultValue: 0);

    return UserSettings(
      themeMode: switch (themeModeIndex) {
        1 => ThemeMode.light,
        2 => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      boardTheme: BoardThemeType.values[boardThemeIndex.clamp(0, BoardThemeType.values.length - 1)],
      pieceStyle: PieceStyle.values[pieceStyleIndex.clamp(0, PieceStyle.values.length - 1)],
      soundEnabled: _storage.getBool('settings_sound', defaultValue: true),
      hapticsEnabled: _storage.getBool('settings_haptics', defaultValue: true),
      showCoordinates: _storage.getBool('settings_coords', defaultValue: true),
      showLegalMoves: _storage.getBool('settings_legal_hints', defaultValue: true),
      autoQueenPromotion: _storage.getBool('settings_auto_queen', defaultValue: false),
      confirmResign: _storage.getBool('settings_confirm_resign', defaultValue: true),
      confirmDraw: _storage.getBool('settings_confirm_draw', defaultValue: true),
    );
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final themeIndex = switch (settings.themeMode) {
      ThemeMode.light => 1,
      ThemeMode.system => 2,
      _ => 0,
    };
    await _storage.setInt('settings_theme_mode', themeIndex);
    await _storage.setInt('settings_board_theme', settings.boardTheme.index);
    await _storage.setInt('settings_piece_style', settings.pieceStyle.index);
    await _storage.setBool('settings_sound', settings.soundEnabled);
    await _storage.setBool('settings_haptics', settings.hapticsEnabled);
    await _storage.setBool('settings_coords', settings.showCoordinates);
    await _storage.setBool('settings_legal_hints', settings.showLegalMoves);
    await _storage.setBool('settings_auto_queen', settings.autoQueenPromotion);
    await _storage.setBool('settings_confirm_resign', settings.confirmResign);
    await _storage.setBool('settings_confirm_draw', settings.confirmDraw);
  }
}
