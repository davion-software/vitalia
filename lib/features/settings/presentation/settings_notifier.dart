import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

@immutable
final class SettingsState {
  const SettingsState({required this.settings, this.failure});

  final AppSettings settings;
  final StorageFailure? failure;
}

final class SettingsNotifier extends Notifier<AsyncValue<SettingsState>> {
  @override
  AsyncValue<SettingsState> build() {
    return ref.watch(vitaliaSnapshotProvider).whenData((result) {
      return switch (result) {
        Ok(:final value) => SettingsState(settings: value.settings),
        Err(:final failure) => SettingsState(
          settings: AppSettings.defaults,
          failure: failure,
        ),
      };
    });
  }

  void setSound(bool value) =>
      _update((settings) => settings.copyWith(sound: value));

  void setVibration(bool value) =>
      _update((settings) => settings.copyWith(vibration: value));

  void setBanners(bool value) =>
      _update((settings) => settings.copyWith(banners: value));

  void setSnoozeMinutes(int value) =>
      _update((settings) => settings.copyWith(snoozeMinutes: value));

  void startTestAlarm() => ref.read(testAlarmProvider.notifier).start();

  void restoreDemo(void Function() onRestored) {
    unawaited(_restoreDemo(onRestored).catchError(_reportUnexpected));
  }

  void clearAll(void Function() onCleared) {
    unawaited(_clearAll(onCleared).catchError(_reportUnexpected));
  }

  void _update(AppSettings Function(AppSettings) change) {
    final current = state.value?.settings;
    if (current == null) return;
    unawaited(_persistSettings(change(current)).catchError(_reportUnexpected));
  }

  Future<void> _persistSettings(AppSettings settings) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .updateSettings(settings);
    _logFailure(result);
  }

  Future<void> _restoreDemo(void Function() onRestored) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .restoreDemo(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        onRestored();
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.settings');
    }
  }

  Future<void> _clearAll(void Function() onCleared) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .clearAll(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        onCleared();
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.settings');
    }
  }

  void _logFailure(Result<void, StorageFailure> result) {
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.settings');
    }
  }

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'settings.intent',
      name: 'vitalia.settings',
      error: error,
      stackTrace: stack,
    );
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>(
      SettingsNotifier.new,
    );
