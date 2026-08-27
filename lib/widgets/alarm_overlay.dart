import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import 'pill_glyph.dart';
import 'vitalia_scope.dart';

class AlarmOverlay extends StatefulWidget {
  const AlarmOverlay({super.key, required this.slot});

  final DoseSlot slot;

  @override
  State<AlarmOverlay> createState() => _AlarmOverlayState();
}

class _AlarmOverlayState extends State<AlarmOverlay> {
  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ping());
    _pulse = Timer.periodic(const Duration(seconds: 2), (_) => _ping());
  }

  @override
  void dispose() {
    _pulse?.cancel();
    super.dispose();
  }

  void _ping() {
    if (!mounted) return;
    final settings = VitaliaScope.of(context).settings;
    if (settings.sound) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (settings.vibration) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = VitaliaScope.of(context);
    final slot = widget.slot;
    final med = slot.medication;
    final snooze = store.settings.snoozeMinutes;
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
                          formatClock(store.now),
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
                  onPressed: () => store.take(slot),
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
                  onPressed: () => store.snooze(slot),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VitaliaPalette.paper,
                    side: const BorderSide(color: VitaliaPalette.paper),
                  ),
                  child: Text('Snooze $snooze min'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => store.skip(slot),
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
}
