import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

enum SettingsNotice { demoRestored, cleared }

@immutable
final class SettingsFeedback {
  const SettingsFeedback({this.notice, this.failure});

  final SettingsNotice? notice;
  final StorageFailure? failure;
}

final class SettingsFeedbackNotifier extends Notifier<SettingsFeedback> {
  @override
  SettingsFeedback build() => const SettingsFeedback();

  void succeed(SettingsNotice notice) =>
      state = SettingsFeedback(notice: notice);

  void fail(StorageFailure failure) =>
      state = SettingsFeedback(failure: failure);

  void clear() => state = const SettingsFeedback();
}

final settingsFeedbackProvider =
    NotifierProvider<SettingsFeedbackNotifier, SettingsFeedback>(
      SettingsFeedbackNotifier.new,
    );

@immutable
final class SettingsState {
  const SettingsState({required this.settings, this.failure});

  final AppSettings settings;
  final StorageFailure? failure;
}

final class SettingsNotifier extends Notifier<AsyncValue<SettingsState>> {
  @override
  AsyncValue<SettingsState> build() {
    return ref.watch(settingsProvider).whenData((result) {
      return switch (result) {
        Ok(:final value) => SettingsState(settings: value),
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

  void restoreDemo() {
    unawaited(
      _restoreDemo().catchError(
        unexpectedLogger('vitalia.settings', 'settings.intent'),
      ),
    );
  }

  void clearAll() {
    unawaited(
      _clearAll().catchError(
        unexpectedLogger('vitalia.settings', 'settings.intent'),
      ),
    );
  }

  void _update(AppSettings Function(AppSettings) change) {
    final current = state.value?.settings;
    if (current == null) return;
    unawaited(
      _persistSettings(change(current))
          .catchError(unexpectedLogger('vitalia.settings', 'settings.intent')),
    );
  }

  Future<void> _persistSettings(AppSettings settings) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .updateSettings(settings);
    if (!ref.mounted) return;
    _applyWrite(result);
  }

  Future<void> _restoreDemo() async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .restoreDemo(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result, notice: SettingsNotice.demoRestored);
  }

  Future<void> _clearAll() async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .clearAll(ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result, notice: SettingsNotice.cleared);
  }

  void _applyWrite(
    Result<void, StorageFailure> result, {
    SettingsNotice? notice,
  }) {
    switch (result) {
      case Ok():
        if (notice != null) {
          ref.read(settingsFeedbackProvider.notifier).succeed(notice);
        }
      case Err(:final failure):
        logFailure('vitalia.settings', failure);
        ref.read(settingsFeedbackProvider.notifier).fail(failure);
    }
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>(
      SettingsNotifier.new,
    );
