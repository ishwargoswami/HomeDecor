class UserSettingsModel {
  final String userId;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final Map<String, dynamic> additionalSettings;
  
  UserSettingsModel({
    required this.userId,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'en',
    this.additionalSettings = const {},
  });
  
  factory UserSettingsModel.fromMap(Map<String, dynamic> data) {
    return UserSettingsModel(
      userId: data['userId'] ?? '',
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
      darkModeEnabled: data['darkModeEnabled'] ?? false,
      language: data['language'] ?? 'en',
      additionalSettings: data['additionalSettings'] ?? {},
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'additionalSettings': additionalSettings,
    };
  }
  
  UserSettingsModel copyWith({
    String? userId,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    Map<String, dynamic>? additionalSettings,
  }) {
    return UserSettingsModel(
      userId: userId ?? this.userId,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }
} 