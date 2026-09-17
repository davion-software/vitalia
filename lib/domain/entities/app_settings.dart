class AppSettings {
  const AppSettings({
    required this.sound,
    required this.vibration,
    required this.banners,
    required this.snoozeMinutes,
  });

  final bool sound;
  final bool vibration;
  final bool banners;
  final int snoozeMinutes;

  static const defaults = AppSettings(
    sound: true,
    vibration: true,
    banners: true,
    snoozeMinutes: 10,
  );

  AppSettings copyWith({
    bool? sound,
    bool? vibration,
    bool? banners,
    int? snoozeMinutes,
  }) {
    return AppSettings(
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      banners: banners ?? this.banners,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'sound': sound,
    'vibration': vibration,
    'banners': banners,
    'snoozeMinutes': snoozeMinutes,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      banners: json['banners'] as bool? ?? true,
      snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 10,
    );
  }
}
