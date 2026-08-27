# Vitalia

A calm pill cabinet and alarm clock from Davion Software. Never miss a dose.

Private rhythm keeper for iOS and Android. No accounts. No backend. Data stays on the device.

## What it does

Tell Vitalia what you take, when, and on which days. Today's slots sit in Later until the clock catches them. At dose time a full-screen alarm holds until you Take, Snooze, or Skip. Missed doses stay on Today for two hours past the scheduled time, then remain so you can still Take or Skip.

Alarms work while the app is open. The OS will not wake a killed Vitalia process.

## Tabs

- **Today** — due now, later, and already done, with a taken/total ring and a refill-soon strip
- **Meds** — the cabinet: add, edit, delete
- **History** — this week's adherence, clean-day streak, last 7 days, recent log
- **Settings** — sound, vibration, banners, snooze length, test alarm, restore demo cabinet, clear data

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47.1 (Dart 3.13.1)
- Android Studio / Android SDK for Android
- macOS, Xcode, and CocoaPods for iOS

```bash
flutter doctor
```

## Run

```bash
git clone git@github.com:davion-software/vitalia.git
cd vitalia
flutter pub get
flutter run
```

First launch seeds a demo cabinet (Vitamin D3, Omega-3, Lisinopril, Magnesium). Restore it anytime from Settings.

## Checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Layout

```text
lib/main.dart          Entry
lib/data/              Local store, schedule, persistence
lib/screens/           Today, Meds, History, Settings, editor
lib/widgets/           Pill glyphs, dose tiles, alarm overlay
android/ ios/          Native hosts
```

Internal Davion Software project. Do not distribute the code without authorization.
