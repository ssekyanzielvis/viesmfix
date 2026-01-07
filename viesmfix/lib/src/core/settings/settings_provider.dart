import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'app_settings.dart';

/// Provider for app settings with persistence
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const _settingsKey = 'app_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> data = jsonDecode(settingsJson);
        state = _fromJson(data);
      }
    } catch (e) {
      // Use default settings if loading fails
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_toJson(state));
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      // Continue even if saving fails
    }
  }

  // Update methods for all settings

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> updateThemeVariant(AppThemeVariant variant) async {
    state = state.copyWith(themeVariant: variant);
    await _saveSettings();
  }

  Future<void> updateTextScaleFactor(double factor) async {
    state = state.copyWith(textScaleFactor: factor);
    await _saveSettings();
  }

  Future<void> updateFontFamily(FontFamily font) async {
    state = state.copyWith(fontFamily: font);
    await _saveSettings();
  }

  Future<void> updateAnimationsEnabled(bool enabled) async {
    state = state.copyWith(enableAnimations: enabled);
    await _saveSettings();
  }

  Future<void> updateAnimationSpeed(AnimationSpeed speed) async {
    state = state.copyWith(animationSpeed: speed);
    await _saveSettings();
  }

  Future<void> updateCornerRadius(double radius) async {
    state = state.copyWith(cornerRadius: radius);
    await _saveSettings();
  }

  Future<void> updateBackgroundStyle(BackgroundStyle style) async {
    state = state.copyWith(backgroundStyle: style);
    await _saveSettings();
  }

  Future<void> updateMovieCardStyle(MovieCardStyle style) async {
    state = state.copyWith(movieCardStyle: style);
    await _saveSettings();
  }

  Future<void> updateGridDensity(GridDensity density) async {
    state = state.copyWith(gridDensity: density);
    await _saveSettings();
  }

  Future<void> updateImageQuality(ImageQuality quality) async {
    state = state.copyWith(imageQuality: quality);
    await _saveSettings();
  }

  Future<void> updateAutoPlayTrailers(bool enabled) async {
    state = state.copyWith(autoPlayTrailers: enabled);
    await _saveSettings();
  }

  Future<void> updateNavigationStyle(NavigationStyle style) async {
    state = state.copyWith(navigationStyle: style);
    await _saveSettings();
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    state = state.copyWith(enableHapticFeedback: enabled);
    await _saveSettings();
  }

  Future<void> updateHapticIntensity(HapticIntensity intensity) async {
    state = state.copyWith(hapticIntensity: intensity);
    await _saveSettings();
  }

  Future<void> updateEnableSoundEffects(bool enabled) async {
    state = state.copyWith(enableSoundEffects: enabled);
    await _saveSettings();
  }

  Future<void> updateSoundEffectVolume(double volume) async {
    state = state.copyWith(soundEffectVolume: volume);
    await _saveSettings();
  }

  Future<void> updateShowAdultContent(bool show) async {
    state = state.copyWith(showAdultContent: show);
    await _saveSettings();
  }

  Future<void> updateEnableGamification(bool enabled) async {
    state = state.copyWith(enableGamification: enabled);
    await _saveSettings();
  }

  Future<void> updateHighContrastMode(bool enabled) async {
    state = state.copyWith(highContrastMode: enabled);
    await _saveSettings();
  }

  Future<void> updateReduceMotion(bool enabled) async {
    state = state.copyWith(reduceMotion: enabled);
    await _saveSettings();
  }

  Future<void> updateColorBlindMode(ColorBlindMode mode) async {
    state = state.copyWith(colorBlindMode: mode);
    await _saveSettings();
  }

  Future<void> updateNotifications(bool enabled) async {
    state = state.copyWith(enablePushNotifications: enabled);
    await _saveSettings();
  }

  Future<void> updateNotificationSound(NotificationSound sound) async {
    state = state.copyWith(notificationSound: sound);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }

  // Bulk update method
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _saveSettings();
  }

  // JSON serialization
  Map<String, dynamic> _toJson(AppSettings settings) {
    return {
      'themeMode': settings.themeMode.index,
      'themeVariant': settings.themeVariant.index,
      'textScaleFactor': settings.textScaleFactor,
      'fontFamily': settings.fontFamily.index,
      'useSystemFont': settings.useSystemFont,
      'enableAnimations': settings.enableAnimations,
      'animationSpeed': settings.animationSpeed.index,
      'enableParallax': settings.enableParallax,
      'enableBlur': settings.enableBlur,
      'cornerRadius': settings.cornerRadius,
      'enableGradients': settings.enableGradients,
      'backgroundStyle': settings.backgroundStyle.index,
      'enableGlassEffect': settings.enableGlassEffect,
      'movieCardStyle': settings.movieCardStyle.index,
      'gridDensity': settings.gridDensity.index,
      'showMovieRatings': settings.showMovieRatings,
      'showMovieYear': settings.showMovieYear,
      'showMovieDuration': settings.showMovieDuration,
      'showGenresOnCard': settings.showGenresOnCard,
      'enableImageZoom': settings.enableImageZoom,
      'imageQuality': settings.imageQuality.index,
      'enableImageCaching': settings.enableImageCaching,
      'showSpoilerWarnings': settings.showSpoilerWarnings,
      'blurSpoilers': settings.blurSpoilers,
      'maxContentRating': settings.maxContentRating.index,
      'showAdultContent': settings.showAdultContent,
      'autoPlayTrailers': settings.autoPlayTrailers,
      'muteTrailersByDefault': settings.muteTrailersByDefault,
      'trailerQuality': settings.trailerQuality.index,
      'enablePictureInPicture': settings.enablePictureInPicture,
      'rememberPlaybackPosition': settings.rememberPlaybackPosition,
      'defaultVolume': settings.defaultVolume,
      'defaultPlaybackSpeed': settings.defaultPlaybackSpeed.index,
      'enableSubtitles': settings.enableSubtitles,
      'subtitleSize': settings.subtitleSize.index,
      'subtitleColor': settings.subtitleColor.value,
      'subtitleBackgroundColor': settings.subtitleBackgroundColor.value,
      'navigationStyle': settings.navigationStyle.index,
      'enableSwipeGestures': settings.enableSwipeGestures,
      'enableDoubleTapToLike': settings.enableDoubleTapToLike,
      'enablePullToRefresh': settings.enablePullToRefresh,
      'swipeSensitivity': settings.swipeSensitivity.index,
      'enableHapticFeedback': settings.enableHapticFeedback,
      'hapticIntensity': settings.hapticIntensity.index,
      'enableSoundEffects': settings.enableSoundEffects,
      'soundEffectVolume': settings.soundEffectVolume,
      'enableSmartSearch': settings.enableSmartSearch,
      'searchIncludesCast': settings.searchIncludesCast,
      'searchIncludesDirector': settings.searchIncludesDirector,
      'searchIncludesPlot': settings.searchIncludesPlot,
      'searchResultsLimit': settings.searchResultsLimit,
      'defaultSortOrder': settings.defaultSortOrder.index,
      'saveSearchHistory': settings.saveSearchHistory,
      'maxSearchHistoryItems': settings.maxSearchHistoryItems,
      'enableVoiceSearch': settings.enableVoiceSearch,
      'enableBarcodeScanner': settings.enableBarcodeScanner,
      'enableSocialFeatures': settings.enableSocialFeatures,
      'showWatchlistPublicly': settings.showWatchlistPublicly,
      'showRatingsPublicly': settings.showRatingsPublicly,
      'showReviewsPublicly': settings.showReviewsPublicly,
      'allowFriendRequests': settings.allowFriendRequests,
      'notifyOnFriendActivity': settings.notifyOnFriendActivity,
      'defaultSharingFormat': settings.defaultSharingFormat.index,
      'includeReviewInShare': settings.includeReviewInShare,
      'watermarkSharedImages': settings.watermarkSharedImages,
      'enablePushNotifications': settings.enablePushNotifications,
      'notifyNewReleases': settings.notifyNewReleases,
      'notifyWatchlistUpdates': settings.notifyWatchlistUpdates,
      'notifyFriendReviews': settings.notifyFriendReviews,
      'notifyWatchPartyInvites': settings.notifyWatchPartyInvites,
      'notifyAchievements': settings.notifyAchievements,
      'notifyStreakReminders': settings.notifyStreakReminders,
      'reminderTime': settings.reminderTime.index,
      'enableEmailNotifications': settings.enableEmailNotifications,
      'enableInAppNotifications': settings.enableInAppNotifications,
      'notificationSound': settings.notificationSound.index,
      'vibrationOnNotification': settings.vibrationOnNotification,
      'enableDownloads': settings.enableDownloads,
      'downloadQuality': settings.downloadQuality.index,
      'downloadOnWifiOnly': settings.downloadOnWifiOnly,
      'deleteWatchedDownloads': settings.deleteWatchedDownloads,
      'maxDownloads': settings.maxDownloads,
      'downloadPath': settings.downloadPath,
      'requireBiometric': settings.requireBiometric,
      'requirePinOnLaunch': settings.requirePinOnLaunch,
      'autoLockTimeout': settings.autoLockTimeout,
      'hideContentInTaskSwitcher': settings.hideContentInTaskSwitcher,
      'enableAnalytics': settings.enableAnalytics,
      'enableCrashReporting': settings.enableCrashReporting,
      'shareUsageData': settings.shareUsageData,
      'personalizedRecommendations': settings.personalizedRecommendations,
      'enableScreenReader': settings.enableScreenReader,
      'highContrastMode': settings.highContrastMode,
      'reduceMotion': settings.reduceMotion,
      'largerTouchTargets': settings.largerTouchTargets,
      'boldText': settings.boldText,
      'monochromeMode': settings.monochromeMode,
      'colorBlindMode': settings.colorBlindMode.index,
      'enableClosedCaptions': settings.enableClosedCaptions,
      'announceUIChanges': settings.announceUIChanges,
      'enableAutoSync': settings.enableAutoSync,
      'syncFrequency': settings.syncFrequency.index,
      'syncOnWifiOnly': settings.syncOnWifiOnly,
      'enableBackup': settings.enableBackup,
      'backupFrequency': settings.backupFrequency.index,
      'clearCacheOnExit': settings.clearCacheOnExit,
      'maxCacheSize': settings.maxCacheSize,
      'enableBetaFeatures': settings.enableBetaFeatures,
      'enableAIRecommendations': settings.enableAIRecommendations,
      'enableARFeatures': settings.enableARFeatures,
      'enableVRMode': settings.enableVRMode,
      'enableGamification': settings.enableGamification,
      'enableMoodMatcher': settings.enableMoodMatcher,
      'enableWatchParties': settings.enableWatchParties,
      'enableTrivia': settings.enableTrivia,
    };
  }

  AppSettings _fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      themeVariant: AppThemeVariant.values[json['themeVariant'] ?? 0],
      textScaleFactor: json['textScaleFactor']?.toDouble() ?? 1.0,
      fontFamily: FontFamily.values[json['fontFamily'] ?? 0],
      useSystemFont: json['useSystemFont'] ?? true,
      enableAnimations: json['enableAnimations'] ?? true,
      animationSpeed: AnimationSpeed.values[json['animationSpeed'] ?? 1],
      enableParallax: json['enableParallax'] ?? true,
      enableBlur: json['enableBlur'] ?? true,
      cornerRadius: json['cornerRadius']?.toDouble() ?? 12.0,
      enableGradients: json['enableGradients'] ?? true,
      backgroundStyle: BackgroundStyle.values[json['backgroundStyle'] ?? 0],
      enableGlassEffect: json['enableGlassEffect'] ?? false,
      movieCardStyle: MovieCardStyle.values[json['movieCardStyle'] ?? 0],
      gridDensity: GridDensity.values[json['gridDensity'] ?? 1],
      showMovieRatings: json['showMovieRatings'] ?? true,
      showMovieYear: json['showMovieYear'] ?? true,
      showMovieDuration: json['showMovieDuration'] ?? true,
      showGenresOnCard: json['showGenresOnCard'] ?? false,
      enableImageZoom: json['enableImageZoom'] ?? true,
      imageQuality: ImageQuality.values[json['imageQuality'] ?? 2],
      enableImageCaching: json['enableImageCaching'] ?? true,
      showSpoilerWarnings: json['showSpoilerWarnings'] ?? true,
      blurSpoilers: json['blurSpoilers'] ?? true,
      maxContentRating: ContentRating.values[json['maxContentRating'] ?? 3],
      showAdultContent: json['showAdultContent'] ?? false,
      autoPlayTrailers: json['autoPlayTrailers'] ?? true,
      muteTrailersByDefault: json['muteTrailersByDefault'] ?? false,
      trailerQuality: VideoQuality.values[json['trailerQuality'] ?? 4],
      enablePictureInPicture: json['enablePictureInPicture'] ?? true,
      rememberPlaybackPosition: json['rememberPlaybackPosition'] ?? true,
      defaultVolume: json['defaultVolume']?.toDouble() ?? 0.7,
      defaultPlaybackSpeed:
          PlaybackSpeed.values[json['defaultPlaybackSpeed'] ?? 1],
      enableSubtitles: json['enableSubtitles'] ?? false,
      subtitleSize: SubtitleSize.values[json['subtitleSize'] ?? 1],
      subtitleColor: Color(json['subtitleColor'] ?? 0xFFFFFFFF),
      subtitleBackgroundColor: Color(
        json['subtitleBackgroundColor'] ?? 0xDE000000,
      ),
      navigationStyle: NavigationStyle.values[json['navigationStyle'] ?? 0],
      enableSwipeGestures: json['enableSwipeGestures'] ?? true,
      enableDoubleTapToLike: json['enableDoubleTapToLike'] ?? true,
      enablePullToRefresh: json['enablePullToRefresh'] ?? true,
      swipeSensitivity: SwipeSensitivity.values[json['swipeSensitivity'] ?? 1],
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      hapticIntensity: HapticIntensity.values[json['hapticIntensity'] ?? 2],
      enableSoundEffects: json['enableSoundEffects'] ?? false,
      soundEffectVolume: json['soundEffectVolume']?.toDouble() ?? 0.5,
      enableSmartSearch: json['enableSmartSearch'] ?? true,
      searchIncludesCast: json['searchIncludesCast'] ?? true,
      searchIncludesDirector: json['searchIncludesDirector'] ?? true,
      searchIncludesPlot: json['searchIncludesPlot'] ?? true,
      searchResultsLimit: json['searchResultsLimit'] ?? 20,
      defaultSortOrder: SortOrder.values[json['defaultSortOrder'] ?? 0],
      saveSearchHistory: json['saveSearchHistory'] ?? true,
      maxSearchHistoryItems: json['maxSearchHistoryItems'] ?? 50,
      enableVoiceSearch: json['enableVoiceSearch'] ?? false,
      enableBarcodeScanner: json['enableBarcodeScanner'] ?? false,
      enableSocialFeatures: json['enableSocialFeatures'] ?? true,
      showWatchlistPublicly: json['showWatchlistPublicly'] ?? false,
      showRatingsPublicly: json['showRatingsPublicly'] ?? true,
      showReviewsPublicly: json['showReviewsPublicly'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      notifyOnFriendActivity: json['notifyOnFriendActivity'] ?? true,
      defaultSharingFormat:
          SharingFormat.values[json['defaultSharingFormat'] ?? 1],
      includeReviewInShare: json['includeReviewInShare'] ?? true,
      watermarkSharedImages: json['watermarkSharedImages'] ?? false,
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      notifyNewReleases: json['notifyNewReleases'] ?? true,
      notifyWatchlistUpdates: json['notifyWatchlistUpdates'] ?? true,
      notifyFriendReviews: json['notifyFriendReviews'] ?? false,
      notifyWatchPartyInvites: json['notifyWatchPartyInvites'] ?? true,
      notifyAchievements: json['notifyAchievements'] ?? true,
      notifyStreakReminders: json['notifyStreakReminders'] ?? true,
      reminderTime: NotificationTime.values[json['reminderTime'] ?? 2],
      enableEmailNotifications: json['enableEmailNotifications'] ?? false,
      enableInAppNotifications: json['enableInAppNotifications'] ?? true,
      notificationSound:
          NotificationSound.values[json['notificationSound'] ?? 0],
      vibrationOnNotification: json['vibrationOnNotification'] ?? true,
      enableDownloads: json['enableDownloads'] ?? true,
      downloadQuality: DownloadQuality.values[json['downloadQuality'] ?? 2],
      downloadOnWifiOnly: json['downloadOnWifiOnly'] ?? true,
      deleteWatchedDownloads: json['deleteWatchedDownloads'] ?? false,
      maxDownloads: json['maxDownloads'] ?? 10,
      downloadPath: json['downloadPath'] ?? '',
      requireBiometric: json['requireBiometric'] ?? false,
      requirePinOnLaunch: json['requirePinOnLaunch'] ?? false,
      autoLockTimeout: json['autoLockTimeout'] ?? 5,
      hideContentInTaskSwitcher: json['hideContentInTaskSwitcher'] ?? false,
      enableAnalytics: json['enableAnalytics'] ?? true,
      enableCrashReporting: json['enableCrashReporting'] ?? true,
      shareUsageData: json['shareUsageData'] ?? false,
      personalizedRecommendations: json['personalizedRecommendations'] ?? true,
      enableScreenReader: json['enableScreenReader'] ?? false,
      highContrastMode: json['highContrastMode'] ?? false,
      reduceMotion: json['reduceMotion'] ?? false,
      largerTouchTargets: json['largerTouchTargets'] ?? false,
      boldText: json['boldText'] ?? false,
      monochromeMode: json['monochromeMode'] ?? false,
      colorBlindMode: ColorBlindMode.values[json['colorBlindMode'] ?? 0],
      enableClosedCaptions: json['enableClosedCaptions'] ?? false,
      announceUIChanges: json['announceUIChanges'] ?? false,
      enableAutoSync: json['enableAutoSync'] ?? true,
      syncFrequency: SyncFrequency.values[json['syncFrequency'] ?? 2],
      syncOnWifiOnly: json['syncOnWifiOnly'] ?? false,
      enableBackup: json['enableBackup'] ?? true,
      backupFrequency: BackupFrequency.values[json['backupFrequency'] ?? 1],
      clearCacheOnExit: json['clearCacheOnExit'] ?? false,
      maxCacheSize: json['maxCacheSize'] ?? 500,
      enableBetaFeatures: json['enableBetaFeatures'] ?? false,
      enableAIRecommendations: json['enableAIRecommendations'] ?? true,
      enableARFeatures: json['enableARFeatures'] ?? false,
      enableVRMode: json['enableVRMode'] ?? false,
      enableGamification: json['enableGamification'] ?? true,
      enableMoodMatcher: json['enableMoodMatcher'] ?? true,
      enableWatchParties: json['enableWatchParties'] ?? true,
      enableTrivia: json['enableTrivia'] ?? true,
    );
  }
}
