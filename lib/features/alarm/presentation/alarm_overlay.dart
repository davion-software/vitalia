import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/features/alarm/presentation/alarm_notifier.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/pill_glyph.dart';

final class AlarmOverlay extends ConsumerStatefulWidget {
  const AlarmOverlay({super.key});

  @override
  ConsumerState<AlarmOverlay> createState() => _AlarmOverlayState();
}

final class _AlarmOverlayState extends ConsumerState<AlarmOverlay> {
  Timer? _pulse;
  String? _activeAlarmId;
  late final ProviderSubscription<AsyncValue<AlarmState?>> _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _alarmSubscription = ref.listenManual(
      alarmNotifierProvider,
      (previous, next) => _syncFeedback(next.value),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _alarmSubscription.close();
    _stopFeedback();
    super.dispose();
  }

  void _syncFeedback(AlarmState? alarm) {
    final alarmId = alarm?.slot.id;
    if (alarmId == _activeAlarmId) return;
    _stopFeedback();
    if (alarmId == null) return;
    _activeAlarmId = alarmId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeAlarmId != alarmId) return;
      _pingAndSchedule(alarmId);
    });
  }

  void _pingAndSchedule(String alarmId) {
    if (!mounted || _activeAlarmId != alarmId) return;
    final alarm = ref.read(alarmNotifierProvider).value;
    if (alarm == null || alarm.slot.id != alarmId) {
      _stopFeedback();
      return;
    }
    if (alarm.settings.sound) {
      unawaited(
        SystemSound.play(SystemSoundType.alert).catchError(_reportUnexpected),
      );
    }
    if (alarm.settings.vibration) {
      unawaited(HapticFeedback.heavyImpact().catchError(_reportUnexpected));
    }
    _pulse = Timer(const Duration(seconds: 2), () => _pingAndSchedule(alarmId));
  }

  void _stopFeedback() {
    _pulse?.cancel();
    _pulse = null;
    _activeAlarmId = null;
  }

  @override
  Widget build(BuildContext context) {
    final alarm = ref.watch(alarmNotifierProvider).value;
    if (alarm == null) return const SizedBox.shrink();
    final slot = alarm.slot;
    final med = slot.medication;
    final snooze = alarm.settings.snoozeMinutes;
    final notifier = ref.read(alarmNotifierProvider.notifier);
    return Material(
      color: VitaliaPalette.sage,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            children: [
              const Text(
                'Dose due',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                  color: Color(0xFFD5DFD4),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alarm.clockLabel,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontWeight: FontWeight.w600,
                            fontSize: 72,
                            height: 1,
                            color: VitaliaPalette.paper,
                          ),
                        ),
                        const SizedBox(height: 36),
                        PillGlyph(shape: med.shape, color: med.color, size: 88),
                        const SizedBox(height: 28),
                        Text(
                          med.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Fraunces',
                            fontWeight: FontWeight.w600,
                            fontSize: 34,
                            color: VitaliaPalette.paper,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          med.dosage,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            color: Color(0xFFD5DFD4),
                          ),
                        ),
                        if (med.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            med.notes,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 15,
                              color: Color(0xFFD5DFD4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => notifier.take(slot.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: VitaliaPalette.paper,
                    foregroundColor: VitaliaPalette.sage,
                  ),
                  child: const Text('Take now'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => notifier.snooze(slot.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VitaliaPalette.paper,
                    side: const BorderSide(color: VitaliaPalette.paper),
                  ),
                  child: Text('Snooze $snooze min'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => notifier.skip(slot.id),
                style: TextButton.styleFrom(
                  foregroundColor: VitaliaPalette.paper,
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'alarm.feedback',
      name: 'vitalia.alarm',
      error: error,
      stackTrace: stack,
    );
  }
}
