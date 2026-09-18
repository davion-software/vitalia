import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/copy.dart';
import 'package:vitalia/features/settings/presentation/settings_notifier.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/async_page.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';
import 'package:vitalia/theme/widgets/storage_banner.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsFeedbackProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      final notice = next.notice;
      if (notice != null && notice != previous?.notice) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(switch (notice) {
              SettingsNotice.demoRestored => 'Demo cabinet restored',
              SettingsNotice.cleared => 'All data cleared',
            }),
          ),
        );
        ref.read(settingsFeedbackProvider.notifier).clear();
      }
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        messenger.showSnackBar(
          SnackBar(content: Text(storageFailureMessage(failure))),
        );
        ref.read(settingsFeedbackProvider.notifier).clear();
      }
    });
    return AsyncPage(
      value: ref.watch(settingsNotifierProvider),
      errorMessage: 'Settings are temporarily unavailable.',
      builder: (state) => _SettingsContent(state: state),
    );
  }
}

final class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = state.settings;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Alarms ring while Vitalia is open. iOS and Android will not wake a killed app for these reminders. Keep the app nearby at dose times, or pair with a system alarm if you need a backup.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (state.failure case final failure?) ...[
          const SizedBox(height: 16),
          StorageBanner(failure: failure),
        ],
        const SizedBox(height: 24),
        PaperCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound'),
                subtitle: const Text('Play a tone when a dose alarm appears'),
                value: settings.sound,
                onChanged: notifier.setSound,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibration'),
                subtitle: const Text('Pulse the device with the alarm'),
                value: settings.vibration,
                onChanged: notifier.setVibration,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Banners'),
                subtitle: const Text(
                  'Show a due-now strip on Today when a dose is waiting',
                ),
                value: settings.banners,
                onChanged: notifier.setBanners,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Snooze length'),
        PaperCard(
          child: Row(
            children: [
              for (final minutes in const [5, 10, 15])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$minutes min'),
                      selected: settings.snoozeMinutes == minutes,
                      selectedColor: VitaliaPalette.sageMist,
                      labelStyle: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        color: settings.snoozeMinutes == minutes
                            ? VitaliaPalette.sage
                            : VitaliaPalette.ink,
                      ),
                      onSelected: (selected) {
                        if (!selected) return;
                        notifier.setSnoozeMinutes(minutes);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: notifier.startTestAlarm,
          child: const Text('Test alarm'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: notifier.restoreDemo,
          child: const Text('Restore demo cabinet'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _startConfirmClear(context, ref),
          style: TextButton.styleFrom(
            foregroundColor: VitaliaPalette.terracotta,
          ),
          child: const Text('Clear all data'),
        ),
      ],
    );
  }

  void _startConfirmClear(BuildContext context, WidgetRef ref) {
    unawaited(
      _confirmClear(context, ref).catchError(
        unexpectedLogger('vitalia.settings', 'settings.confirm_clear'),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear this device?'),
          content: const Text(
            'This removes every medication and log from this phone. It cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: VitaliaPalette.terracotta,
              ),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );
    if (ok != true || !context.mounted) return;
    ref.read(settingsNotifierProvider.notifier).clearAll();
  }
}
