import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Comprehensive app settings with extensive customization options
class AppSettings extends Equatable {
  // Appearance Settings
  final ThemeMode themeMode;
  final AppThemeVariant themeVariant;
  final ColorScheme? customColorScheme;
  final double textScaleFactor;
  final FontFamily fontFamily;
  final bool useSystemFont;
  final bool enableAnimations;
  final AnimationSpeed animationSpeed;
  final bool enableParallax;
  final bool enableBlur;
  final double cornerRadius;
  final bool enableGradients;
  final BackgroundStyle backgroundStyle;
  final bool enableGlassEffect;

  // Content Display Settings
  final MovieCardStyle movieCardStyle;
  final GridDensity gridDensity;
  final bool showMovieRatings;
  final bool showMovieYear;
  final bool showMovieDuration;
  final bool showGenresOnCard;
  final bool enableImageZoom;
  final ImageQuality imageQuality;
  final bool enableImageCaching;
  final bool showSpoilerWarnings;
  final bool blurSpoilers;
  final ContentRating maxContentRating;
  final bool showAdultContent;

  // Playback & Media Settings
  final bool autoPlayTrailers;
  final bool muteTrailersByDefault;
  final VideoQuality trailerQuality;
  final bool enablePictureInPicture;
  final bool rememberPlaybackPosition;
  final double defaultVolume;
  final PlaybackSpeed defaultPlaybackSpeed;
  final bool enableSubtitles;
  final SubtitleSize subtitleSize;
  final Color subtitleColor;
  final Color subtitleBackgroundColor;

  // Navigation & Interaction Settings
  final NavigationStyle navigationStyle;
  final bool enableSwipeGestures;
  final bool enableDoubleTapToLike;
  final bool enablePullToRefresh;
  final SwipeSensitivity swipeSensitivity;
  final bool enableHapticFeedback;
  final HapticIntensity hapticIntensity;
  final bool enableSoundEffects;
  final double soundEffectVolume;

  // Search & Discovery Settings
  final bool enableSmartSearch;
  final bool searchIncludesCast;
  final bool searchIncludesDirector;
  final bool searchIncludesPlot;
  final int searchResultsLimit;
  final SortOrder defaultSortOrder;
  final bool saveSearchHistory;
  final int maxSearchHistoryItems;
  final bool enableVoiceSearch;
  final bool enableBarcodeScanner;

  // Social & Sharing Settings
  final bool enableSocialFeatures;
  final bool showWatchlistPublicly;
  final bool showRatingsPublicly;
  final bool showReviewsPublicly;
  final bool allowFriendRequests;
  final bool notifyOnFriendActivity;
  final SharingFormat defaultSharingFormat;
  final bool includeReviewInShare;
  final bool watermarkSharedImages;

  // Notification Settings
  final bool enablePushNotifications;
  final bool notifyNewReleases;
  final bool notifyWatchlistUpdates;
  final bool notifyFriendReviews;
  final bool notifyWatchPartyInvites;
  final bool notifyAchievements;
  final bool notifyStreakReminders;
  final NotificationTime reminderTime;
  final bool enableEmailNotifications;
  final bool enableInAppNotifications;
  final NotificationSound notificationSound;
  final bool vibrationOnNotification;

  // Download Settings
  final bool enableDownloads;
  final DownloadQuality downloadQuality;
  final bool downloadOnWifiOnly;
  final bool deleteWatchedDownloads;
  final int maxDownloads;
  final String downloadPath;

  // Privacy & Security Settings
  final bool requireBiometric;
  final bool requirePinOnLaunch;
  final int autoLockTimeout;
  final bool hideContentInTaskSwitcher;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool shareUsageData;
  final bool personalizedRecommendations;

  // Accessibility Settings
  final bool enableScreenReader;
  final bool highContrastMode;
  final bool reduceMotion;
  final bool largerTouchTargets;
  final bool boldText;
  final bool monochromeMode;
  final ColorBlindMode colorBlindMode;
  final bool enableClosedCaptions;
  final bool announceUIChanges;

  // Data & Storage Settings
  final bool enableAutoSync;
  final SyncFrequency syncFrequency;
  final bool syncOnWifiOnly;
  final bool enableBackup;
  final BackupFrequency backupFrequency;
  final bool clearCacheOnExit;
  final int maxCacheSize;

  // Experimental Features
  final bool enableBetaFeatures;
  final bool enableAIRecommendations;
  final bool enableARFeatures;
  final bool enableVRMode;
  final bool enableGamification;
  final bool enableMoodMatcher;
  final bool enableWatchParties;
  final bool enableTrivia;

  const AppSettings({
    // Appearance
    this.themeMode = ThemeMode.system,
    this.themeVariant = AppThemeVariant.netflix,
    this.customColorScheme,
    this.textScaleFactor = 1.0,
    this.fontFamily = FontFamily.system,
    this.useSystemFont = true,
    this.enableAnimations = true,
    this.animationSpeed = AnimationSpeed.normal,
    this.enableParallax = true,
    this.enableBlur = true,
    this.cornerRadius = 12.0,
    this.enableGradients = true,
    this.backgroundStyle = BackgroundStyle.solid,
    this.enableGlassEffect = false,

    // Content Display
    this.movieCardStyle = MovieCardStyle.poster,
    this.gridDensity = GridDensity.normal,
    this.showMovieRatings = true,
    this.showMovieYear = true,
    this.showMovieDuration = true,
    this.showGenresOnCard = false,
    this.enableImageZoom = true,
    this.imageQuality = ImageQuality.high,
    this.enableImageCaching = true,
    this.showSpoilerWarnings = true,
    this.blurSpoilers = true,
    this.maxContentRating = ContentRating.r,
    this.showAdultContent = false,

    // Playback & Media
    this.autoPlayTrailers = true,
    this.muteTrailersByDefault = false,
    this.trailerQuality = VideoQuality.auto,
    this.enablePictureInPicture = true,
    this.rememberPlaybackPosition = true,
    this.defaultVolume = 0.7,
    this.defaultPlaybackSpeed = PlaybackSpeed.normal,
    this.enableSubtitles = false,
    this.subtitleSize = SubtitleSize.medium,
    this.subtitleColor = Colors.white,
    this.subtitleBackgroundColor = Colors.black87,

    // Navigation & Interaction
    this.navigationStyle = NavigationStyle.bottomBar,
    this.enableSwipeGestures = true,
    this.enableDoubleTapToLike = true,
    this.enablePullToRefresh = true,
    this.swipeSensitivity = SwipeSensitivity.medium,
    this.enableHapticFeedback = true,
    this.hapticIntensity = HapticIntensity.medium,
    this.enableSoundEffects = false,
    this.soundEffectVolume = 0.5,

    // Search & Discovery
    this.enableSmartSearch = true,
    this.searchIncludesCast = true,
    this.searchIncludesDirector = true,
    this.searchIncludesPlot = true,
    this.searchResultsLimit = 20,
    this.defaultSortOrder = SortOrder.relevance,
    this.saveSearchHistory = true,
    this.maxSearchHistoryItems = 50,
    this.enableVoiceSearch = false,
    this.enableBarcodeScanner = false,

    // Social & Sharing
    this.enableSocialFeatures = true,
    this.showWatchlistPublicly = false,
    this.showRatingsPublicly = true,
    this.showReviewsPublicly = true,
    this.allowFriendRequests = true,
    this.notifyOnFriendActivity = true,
    this.defaultSharingFormat = SharingFormat.card,
    this.includeReviewInShare = true,
    this.watermarkSharedImages = false,

    // Notifications
    this.enablePushNotifications = true,
    this.notifyNewReleases = true,
    this.notifyWatchlistUpdates = true,
    this.notifyFriendReviews = false,
    this.notifyWatchPartyInvites = true,
    this.notifyAchievements = true,
    this.notifyStreakReminders = true,
    this.reminderTime = NotificationTime.evening,
    this.enableEmailNotifications = false,
    this.enableInAppNotifications = true,
    this.notificationSound = NotificationSound.default_,
    this.vibrationOnNotification = true,

    // Downloads
    this.enableDownloads = true,
    this.downloadQuality = DownloadQuality.high,
    this.downloadOnWifiOnly = true,
    this.deleteWatchedDownloads = false,
    this.maxDownloads = 10,
    this.downloadPath = '',

    // Privacy & Security
    this.requireBiometric = false,
    this.requirePinOnLaunch = false,
    this.autoLockTimeout = 5,
    this.hideContentInTaskSwitcher = false,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.shareUsageData = false,
    this.personalizedRecommendations = true,

    // Accessibility
    this.enableScreenReader = false,
    this.highContrastMode = false,
    this.reduceMotion = false,
    this.largerTouchTargets = false,
    this.boldText = false,
    this.monochromeMode = false,
    this.colorBlindMode = ColorBlindMode.none,
    this.enableClosedCaptions = false,
    this.announceUIChanges = false,

    // Data & Storage
    this.enableAutoSync = true,
    this.syncFrequency = SyncFrequency.hourly,
    this.syncOnWifiOnly = false,
    this.enableBackup = true,
    this.backupFrequency = BackupFrequency.weekly,
    this.clearCacheOnExit = false,
    this.maxCacheSize = 500,

    // Experimental
    this.enableBetaFeatures = false,
    this.enableAIRecommendations = true,
    this.enableARFeatures = false,
    this.enableVRMode = false,
    this.enableGamification = true,
    this.enableMoodMatcher = true,
    this.enableWatchParties = true,
    this.enableTrivia = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppThemeVariant? themeVariant,
    ColorScheme? customColorScheme,
    double? textScaleFactor,
    FontFamily? fontFamily,
    bool? useSystemFont,
    bool? enableAnimations,
    AnimationSpeed? animationSpeed,
    bool? enableParallax,
    bool? enableBlur,
    double? cornerRadius,
    bool? enableGradients,
    BackgroundStyle? backgroundStyle,
    bool? enableGlassEffect,
    MovieCardStyle? movieCardStyle,
    GridDensity? gridDensity,
    bool? showMovieRatings,
    bool? showMovieYear,
    bool? showMovieDuration,
    bool? showGenresOnCard,
    bool? enableImageZoom,
    ImageQuality? imageQuality,
    bool? enableImageCaching,
    bool? showSpoilerWarnings,
    bool? blurSpoilers,
    ContentRating? maxContentRating,
    bool? showAdultContent,
    bool? autoPlayTrailers,
    bool? muteTrailersByDefault,
    VideoQuality? trailerQuality,
    bool? enablePictureInPicture,
    bool? rememberPlaybackPosition,
    double? defaultVolume,
    PlaybackSpeed? defaultPlaybackSpeed,
    bool? enableSubtitles,
    SubtitleSize? subtitleSize,
    Color? subtitleColor,
    Color? subtitleBackgroundColor,
    NavigationStyle? navigationStyle,
    bool? enableSwipeGestures,
    bool? enableDoubleTapToLike,
    bool? enablePullToRefresh,
    SwipeSensitivity? swipeSensitivity,
    bool? enableHapticFeedback,
    HapticIntensity? hapticIntensity,
    bool? enableSoundEffects,
    double? soundEffectVolume,
    bool? enableSmartSearch,
    bool? searchIncludesCast,
    bool? searchIncludesDirector,
    bool? searchIncludesPlot,
    int? searchResultsLimit,
    SortOrder? defaultSortOrder,
    bool? saveSearchHistory,
    int? maxSearchHistoryItems,
    bool? enableVoiceSearch,
    bool? enableBarcodeScanner,
    bool? enableSocialFeatures,
    bool? showWatchlistPublicly,
    bool? showRatingsPublicly,
    bool? showReviewsPublicly,
    bool? allowFriendRequests,
    bool? notifyOnFriendActivity,
    SharingFormat? defaultSharingFormat,
    bool? includeReviewInShare,
    bool? watermarkSharedImages,
    bool? enablePushNotifications,
    bool? notifyNewReleases,
    bool? notifyWatchlistUpdates,
    bool? notifyFriendReviews,
    bool? notifyWatchPartyInvites,
    bool? notifyAchievements,
    bool? notifyStreakReminders,
    NotificationTime? reminderTime,
    bool? enableEmailNotifications,
    bool? enableInAppNotifications,
    NotificationSound? notificationSound,
    bool? vibrationOnNotification,
    bool? enableDownloads,
    DownloadQuality? downloadQuality,
    bool? downloadOnWifiOnly,
    bool? deleteWatchedDownloads,
    int? maxDownloads,
    String? downloadPath,
    bool? requireBiometric,
    bool? requirePinOnLaunch,
    int? autoLockTimeout,
    bool? hideContentInTaskSwitcher,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? shareUsageData,
    bool? personalizedRecommendations,
    bool? enableScreenReader,
    bool? highContrastMode,
    bool? reduceMotion,
    bool? largerTouchTargets,
    bool? boldText,
    bool? monochromeMode,
    ColorBlindMode? colorBlindMode,
    bool? enableClosedCaptions,
    bool? announceUIChanges,
    bool? enableAutoSync,
    SyncFrequency? syncFrequency,
    bool? syncOnWifiOnly,
    bool? enableBackup,
    BackupFrequency? backupFrequency,
    bool? clearCacheOnExit,
    int? maxCacheSize,
    bool? enableBetaFeatures,
    bool? enableAIRecommendations,
    bool? enableARFeatures,
    bool? enableVRMode,
    bool? enableGamification,
    bool? enableMoodMatcher,
    bool? enableWatchParties,
    bool? enableTrivia,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      themeVariant: themeVariant ?? this.themeVariant,
      customColorScheme: customColorScheme ?? this.customColorScheme,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      fontFamily: fontFamily ?? this.fontFamily,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      enableParallax: enableParallax ?? this.enableParallax,
      enableBlur: enableBlur ?? this.enableBlur,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      enableGradients: enableGradients ?? this.enableGradients,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      enableGlassEffect: enableGlassEffect ?? this.enableGlassEffect,
      movieCardStyle: movieCardStyle ?? this.movieCardStyle,
      gridDensity: gridDensity ?? this.gridDensity,
      showMovieRatings: showMovieRatings ?? this.showMovieRatings,
      showMovieYear: showMovieYear ?? this.showMovieYear,
      showMovieDuration: showMovieDuration ?? this.showMovieDuration,
      showGenresOnCard: showGenresOnCard ?? this.showGenresOnCard,
      enableImageZoom: enableImageZoom ?? this.enableImageZoom,
      imageQuality: imageQuality ?? this.imageQuality,
      enableImageCaching: enableImageCaching ?? this.enableImageCaching,
      showSpoilerWarnings: showSpoilerWarnings ?? this.showSpoilerWarnings,
      blurSpoilers: blurSpoilers ?? this.blurSpoilers,
      maxContentRating: maxContentRating ?? this.maxContentRating,
      showAdultContent: showAdultContent ?? this.showAdultContent,
      autoPlayTrailers: autoPlayTrailers ?? this.autoPlayTrailers,
      muteTrailersByDefault:
          muteTrailersByDefault ?? this.muteTrailersByDefault,
      trailerQuality: trailerQuality ?? this.trailerQuality,
      enablePictureInPicture:
          enablePictureInPicture ?? this.enablePictureInPicture,
      rememberPlaybackPosition:
          rememberPlaybackPosition ?? this.rememberPlaybackPosition,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      enableSubtitles: enableSubtitles ?? this.enableSubtitles,
      subtitleSize: subtitleSize ?? this.subtitleSize,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitleBackgroundColor:
          subtitleBackgroundColor ?? this.subtitleBackgroundColor,
      navigationStyle: navigationStyle ?? this.navigationStyle,
      enableSwipeGestures: enableSwipeGestures ?? this.enableSwipeGestures,
      enableDoubleTapToLike:
          enableDoubleTapToLike ?? this.enableDoubleTapToLike,
      enablePullToRefresh: enablePullToRefresh ?? this.enablePullToRefresh,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      soundEffectVolume: soundEffectVolume ?? this.soundEffectVolume,
      enableSmartSearch: enableSmartSearch ?? this.enableSmartSearch,
      searchIncludesCast: searchIncludesCast ?? this.searchIncludesCast,
      searchIncludesDirector:
          searchIncludesDirector ?? this.searchIncludesDirector,
      searchIncludesPlot: searchIncludesPlot ?? this.searchIncludesPlot,
      searchResultsLimit: searchResultsLimit ?? this.searchResultsLimit,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      saveSearchHistory: saveSearchHistory ?? this.saveSearchHistory,
      maxSearchHistoryItems:
          maxSearchHistoryItems ?? this.maxSearchHistoryItems,
      enableVoiceSearch: enableVoiceSearch ?? this.enableVoiceSearch,
      enableBarcodeScanner: enableBarcodeScanner ?? this.enableBarcodeScanner,
      enableSocialFeatures: enableSocialFeatures ?? this.enableSocialFeatures,
      showWatchlistPublicly:
          showWatchlistPublicly ?? this.showWatchlistPublicly,
      showRatingsPublicly: showRatingsPublicly ?? this.showRatingsPublicly,
      showReviewsPublicly: showReviewsPublicly ?? this.showReviewsPublicly,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      notifyOnFriendActivity:
          notifyOnFriendActivity ?? this.notifyOnFriendActivity,
      defaultSharingFormat: defaultSharingFormat ?? this.defaultSharingFormat,
      includeReviewInShare: includeReviewInShare ?? this.includeReviewInShare,
      watermarkSharedImages:
          watermarkSharedImages ?? this.watermarkSharedImages,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      notifyNewReleases: notifyNewReleases ?? this.notifyNewReleases,
      notifyWatchlistUpdates:
          notifyWatchlistUpdates ?? this.notifyWatchlistUpdates,
      notifyFriendReviews: notifyFriendReviews ?? this.notifyFriendReviews,
      notifyWatchPartyInvites:
          notifyWatchPartyInvites ?? this.notifyWatchPartyInvites,
      notifyAchievements: notifyAchievements ?? this.notifyAchievements,
      notifyStreakReminders:
          notifyStreakReminders ?? this.notifyStreakReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enableInAppNotifications:
          enableInAppNotifications ?? this.enableInAppNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationOnNotification:
          vibrationOnNotification ?? this.vibrationOnNotification,
      enableDownloads: enableDownloads ?? this.enableDownloads,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
      deleteWatchedDownloads:
          deleteWatchedDownloads ?? this.deleteWatchedDownloads,
      maxDownloads: maxDownloads ?? this.maxDownloads,
      downloadPath: downloadPath ?? this.downloadPath,
      requireBiometric: requireBiometric ?? this.requireBiometric,
      requirePinOnLaunch: requirePinOnLaunch ?? this.requirePinOnLaunch,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      hideContentInTaskSwitcher:
          hideContentInTaskSwitcher ?? this.hideContentInTaskSwitcher,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      boldText: boldText ?? this.boldText,
      monochromeMode: monochromeMode ?? this.monochromeMode,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      enableClosedCaptions: enableClosedCaptions ?? this.enableClosedCaptions,
      announceUIChanges: announceUIChanges ?? this.announceUIChanges,
      enableAutoSync: enableAutoSync ?? this.enableAutoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      enableBackup: enableBackup ?? this.enableBackup,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      clearCacheOnExit: clearCacheOnExit ?? this.clearCacheOnExit,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      enableBetaFeatures: enableBetaFeatures ?? this.enableBetaFeatures,
      enableAIRecommendations:
          enableAIRecommendations ?? this.enableAIRecommendations,
      enableARFeatures: enableARFeatures ?? this.enableARFeatures,
      enableVRMode: enableVRMode ?? this.enableVRMode,
      enableGamification: enableGamification ?? this.enableGamification,
      enableMoodMatcher: enableMoodMatcher ?? this.enableMoodMatcher,
      enableWatchParties: enableWatchParties ?? this.enableWatchParties,
      enableTrivia: enableTrivia ?? this.enableTrivia,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    themeVariant,
    customColorScheme,
    textScaleFactor,
    fontFamily,
    useSystemFont,
    enableAnimations,
    animationSpeed,
    enableParallax,
    enableBlur,
    cornerRadius,
    enableGradients,
    backgroundStyle,
    enableGlassEffect,
    movieCardStyle,
    gridDensity,
    showMovieRatings,
    showMovieYear,
    showMovieDuration,
    showGenresOnCard,
    enableImageZoom,
    imageQuality,
    enableImageCaching,
    showSpoilerWarnings,
    blurSpoilers,
    maxContentRating,
    showAdultContent,
    autoPlayTrailers,
    muteTrailersByDefault,
    trailerQuality,
    enablePictureInPicture,
    rememberPlaybackPosition,
    defaultVolume,
    defaultPlaybackSpeed,
    enableSubtitles,
    subtitleSize,
    subtitleColor,
    subtitleBackgroundColor,
    navigationStyle,
    enableSwipeGestures,
    enableDoubleTapToLike,
    enablePullToRefresh,
    swipeSensitivity,
    enableHapticFeedback,
    hapticIntensity,
    enableSoundEffects,
    soundEffectVolume,
    enableSmartSearch,
    searchIncludesCast,
    searchIncludesDirector,
    searchIncludesPlot,
    searchResultsLimit,
    defaultSortOrder,
    saveSearchHistory,
    maxSearchHistoryItems,
    enableVoiceSearch,
    enableBarcodeScanner,
    enableSocialFeatures,
    showWatchlistPublicly,
    showRatingsPublicly,
    showReviewsPublicly,
    allowFriendRequests,
    notifyOnFriendActivity,
    defaultSharingFormat,
    includeReviewInShare,
    watermarkSharedImages,
    enablePushNotifications,
    notifyNewReleases,
    notifyWatchlistUpdates,
    notifyFriendReviews,
    notifyWatchPartyInvites,
    notifyAchievements,
    notifyStreakReminders,
    reminderTime,
    enableEmailNotifications,
    enableInAppNotifications,
    notificationSound,
    vibrationOnNotification,
    enableDownloads,
    downloadQuality,
    downloadOnWifiOnly,
    deleteWatchedDownloads,
    maxDownloads,
    downloadPath,
    requireBiometric,
    requirePinOnLaunch,
    autoLockTimeout,
    hideContentInTaskSwitcher,
    enableAnalytics,
    enableCrashReporting,
    shareUsageData,
    personalizedRecommendations,
    enableScreenReader,
    highContrastMode,
    reduceMotion,
    largerTouchTargets,
    boldText,
    monochromeMode,
    colorBlindMode,
    enableClosedCaptions,
    announceUIChanges,
    enableAutoSync,
    syncFrequency,
    syncOnWifiOnly,
    enableBackup,
    backupFrequency,
    clearCacheOnExit,
    maxCacheSize,
    enableBetaFeatures,
    enableAIRecommendations,
    enableARFeatures,
    enableVRMode,
    enableGamification,
    enableMoodMatcher,
    enableWatchParties,
    enableTrivia,
  ];
}

// Enums for all customization options

enum AppThemeVariant { netflix, hulu, disney, hbo, prime, custom }

enum FontFamily {
  system,
  roboto,
  openSans,
  lato,
  montserrat,
  poppins,
  raleway,
  nunito,
}

enum AnimationSpeed { slow, normal, fast, instant }

enum BackgroundStyle { solid, gradient, image, animated }

enum MovieCardStyle { poster, backdrop, compact, detailed, minimal }

enum GridDensity { comfortable, normal, compact, dense }

enum ImageQuality { low, medium, high, original, auto }

enum ContentRating { g, pg, pg13, r, nc17, unrated }

enum VideoQuality { low, medium, high, ultra, auto }

enum PlaybackSpeed { slow, normal, fast, veryFast }

enum SubtitleSize { small, medium, large, extraLarge }

enum NavigationStyle { bottomBar, drawer, rail, tabs }

enum SwipeSensitivity { low, medium, high }

enum HapticIntensity { off, light, medium, strong }

enum SortOrder { relevance, rating, releaseDate, popularity, alphabetical }

enum SharingFormat { text, card, story, video }

enum NotificationTime { morning, afternoon, evening, night }

enum NotificationSound { default_, chime, bell, pop, subtle, none }

enum DownloadQuality { low, medium, high, ultra }

enum ColorBlindMode {
  none,
  protanopia,
  deuteranopia,
  tritanopia,
  achromatopsia,
}

enum SyncFrequency { realTime, fifteenMinutes, hourly, daily, manual }

enum BackupFrequency { daily, weekly, monthly, manual }
