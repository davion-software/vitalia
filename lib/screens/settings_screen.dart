import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../widgets/paper.dart';
import '../widgets/vitalia_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VitaliaScope.of(context);
    final settings = store.settings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Alarms ring while Vitalia is open. iOS and Android will not wake a killed app for these reminders. Keep the app nearby at dose times, or pair with a system alarm if you need a backup.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        PaperCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound'),
                subtitle: const Text('Play a tone when a dose alarm appears'),
                value: settings.sound,
                onChanged: (value) {
                  store.updateSettings(settings.copyWith(sound: value));
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vibration'),
                subtitle: const Text('Pulse the device with the alarm'),
                value: settings.vibration,
                onChanged: (value) {
                  store.updateSettings(settings.copyWith(vibration: value));
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Banners'),
                subtitle: const Text(
                  'Show a due-now strip on Today when a dose is waiting',
                ),
                value: settings.banners,
                onChanged: (value) {
                  store.updateSettings(settings.copyWith(banners: value));
                },
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
                        store.updateSettings(
                          settings.copyWith(snoozeMinutes: minutes),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: store.startTestAlarm,
          child: const Text('Test alarm'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await store.restoreDemo();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo cabinet restored')),
            );
          },
          child: const Text('Restore demo cabinet'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _confirmClear(context),
          style: TextButton.styleFrom(
            foregroundColor: VitaliaPalette.terracotta,
          ),
          child: const Text('Clear all data'),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final store = VitaliaScope.of(context);
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
    if (ok == true) {
      await store.clearAll();
    }
  }
}
