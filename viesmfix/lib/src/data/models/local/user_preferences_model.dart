import 'dart:convert';

/// User preferences model for local storage
class UserPreferencesModel {
  final String userId;
  final String themeMode; // 'dark', 'light', 'system'
  final String language;
  final bool notificationsEnabled;
  final Map<String, dynamic>? preferences;

  UserPreferencesModel({
    required this.userId,
    this.themeMode = 'dark',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.preferences,
  });

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'theme_mode': themeMode,
      'language': language,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
    };
  }

  /// Create from database map
  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      userId: map['user_id'] as String,
      themeMode: map['theme_mode'] as String? ?? 'dark',
      language: map['language'] as String? ?? 'en',
      notificationsEnabled: (map['notifications_enabled'] as int?) == 1,
      preferences: map['preferences'] != null
          ? jsonDecode(map['preferences'] as String) as Map<String, dynamic>
          : null,
    );
  }

  /// Copy with method
  UserPreferencesModel copyWith({
    String? userId,
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    Map<String, dynamic>? preferences,
  }) {
    return UserPreferencesModel(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'themeMode': themeMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'preferences': preferences,
    };
  }

  /// Create from JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'] as String,
      themeMode: json['themeMode'] as String? ?? 'dark',
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
}
