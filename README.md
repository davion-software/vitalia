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
dart run build_runner build
flutter run
```

First launch seeds a demo cabinet (Vitamin D3, Omega-3, Lisinopril,
Magnesium). Existing `SharedPreferences` snapshots are migrated once to the
Drift database and removed only after a successful transaction.

## Checks

```bash
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test --test-randomize-ordering-seed random
flutter build apk --release
```

## Layout

```text
lib/main.dart                 Thin entrypoint
lib/bootstrap.dart            Composition root and provider overrides
lib/app.dart                  MaterialApp.router and lifecycle handling
lib/core/                     Pure values, typed results, scheduling rules
lib/data/                     Drift schema, repository, migration boundary
lib/services/                 Injectable clock and ID providers
lib/routing/                  Single GoRouter and typed route locations
lib/theme/                    Theme tokens and reusable visual components
lib/features/*/presentation/  Consumer views and Riverpod Notifiers
test/                         Tests mirroring the production structure
.cursor/skills/               Project-local engineering skills
android/ ios/                 Native hosts
```

Internal Davion Software project. Do not distribute the code without authorization.
