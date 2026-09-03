import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/board_themes.dart';
import '../../core/theme/piece_themes.dart';
import '../../data/repositories/settings_repository.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ServiceLocator.settingsRepository.getSettings();
  }

  void _updateSettings(UserSettings newSettings) async {
    setState(() => _settings = newSettings);
    await ServiceLocator.settingsRepository.saveSettings(newSettings);
    SoundService.instance.setSoundEnabled(newSettings.soundEnabled);
    HapticService.instance.setHapticEnabled(newSettings.hapticsEnabled);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your rating history, game archives, and credentials. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyError),
            onPressed: () async {
              final nav = Navigator.of(context);
              Navigator.of(ctx).pop();
              await ServiceLocator.authRepository.deleteAccount();
              if (!mounted) return;
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings & Aesthetics'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Board & Piece Themes Section
          _buildSectionHeader('CHESSBOARD & PIECES'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Board Theme'),
                  subtitle: Text(_settings.boardTheme.label),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedDark),
                  onTap: _showBoardThemePicker,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Piece Vector Style'),
                  subtitle: Text(_settings.pieceStyle.label),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedDark),
                  onTap: _showPieceStylePicker,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 2. Audio & Haptics Section
          _buildSectionHeader('SOUND & HAPTICS'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Acoustic Sound Effects'),
                  subtitle: const Text('Tactile moves, captures, check cues & clocks'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.soundEnabled,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(soundEnabled: val)),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Haptic Vibration Feedback'),
                  subtitle: const Text('Subtle haptic pulses on piece contact and checkmate'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.hapticsEnabled,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(hapticsEnabled: val)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 3. Gameplay Preferences Section
          _buildSectionHeader('GAMEPLAY & ASSISTS'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Legal Destination Highlights'),
                  subtitle: const Text('Show target dots and capture rings on selection'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.showLegalMoves,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(showLegalMoves: val)),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Board Coordinates (a-h / 1-8)'),
                  subtitle: const Text('Show algebraic rank and file markings'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.showCoordinates,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(showCoordinates: val)),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Auto-Queen Promotion'),
                  subtitle: const Text('Instantly promote pawns to Queen without picker'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.autoQueenPromotion,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(autoQueenPromotion: val)),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Confirm Match Resignation'),
                  subtitle: const Text('Show safety confirmation before forfeit'),
                  activeThumbColor: AppColors.goldAccent,
                  value: _settings.confirmResign,
                  onChanged: (val) =>
                      _updateSettings(_settings.copyWith(confirmResign: val)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 4. Account & Privacy
          _buildSectionHeader('ACCOUNT & SESSION'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.textSecondaryDark),
                  title: const Text('Log Out'),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await ServiceLocator.authRepository.logout();
                    if (!mounted) return;
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (route) => false,
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.rubyError),
                  title: const Text('Delete Account', style: TextStyle(color: AppColors.rubyError)),
                  subtitle: const Text('Permanently erase account data and rating record'),
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              'Chess Elite v1.0.0 (Grandmaster Edition) • Production Ready',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textMutedDark),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.goldAccent,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showBoardThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Tournament Board Theme', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            ...BoardThemeType.values.map((theme) {
              final isSelected = theme == _settings.boardTheme;
              final colors = BoardThemeColors.get(theme);
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkBorder, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(child: Container(color: colors.lightSquare)),
                      Expanded(child: Container(color: colors.darkSquare)),
                    ],
                  ),
                ),
                title: Text(theme.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(theme.description, style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.goldAccent) : null,
                onTap: () {
                  _updateSettings(_settings.copyWith(boardTheme: theme));
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPieceStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Piece Silhouette Style', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            ...PieceStyle.values.map((style) {
              final isSelected = style == _settings.pieceStyle;
              return ListTile(
                title: Text(style.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(style.description, style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.goldAccent) : null,
                onTap: () {
                  _updateSettings(_settings.copyWith(pieceStyle: style));
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
