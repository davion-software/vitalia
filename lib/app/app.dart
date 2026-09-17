import 'dart:async';

import 'package:flutter/material.dart';

import 'package:vitalia/core/theme/vitalia_theme.dart';
import 'package:vitalia/data/store.dart';
import 'package:vitalia/features/alarm/alarm.dart';

import 'shell.dart';
import 'vitalia_scope.dart';

class VitaliaApp extends StatefulWidget {
  const VitaliaApp({super.key, required this.store, this.liveTick = true});

  final VitaliaStore store;
  final bool liveTick;

  @override
  State<VitaliaApp> createState() => _VitaliaAppState();
}

class _VitaliaAppState extends State<VitaliaApp> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.liveTick) {
      widget.store.tick();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        widget.store.tick();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VitaliaScope(
      store: widget.store,
      child: MaterialApp(
        title: 'Vitalia',
        debugShowCheckedModeBanner: false,
        theme: vitaliaTheme(),
        home: const AppShell(),
        builder: (context, child) {
          return AnimatedBuilder(
            animation: widget.store,
            builder: (context, _) {
              final ringing = widget.store.ringingSlot;
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  if (ringing != null) AlarmOverlay(slot: ringing),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
