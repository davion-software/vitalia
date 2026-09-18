import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/features/alarm/presentation/alarm_overlay.dart';
import 'package:vitalia/features/alarm/presentation/alarm_notifier.dart';
import 'package:vitalia/routing/app_router.dart';
import 'package:vitalia/services/app_providers.dart';
import 'package:vitalia/theme/vitalia_theme.dart';

final class VitaliaApp extends ConsumerStatefulWidget {
  const VitaliaApp({super.key});

  @override
  ConsumerState<VitaliaApp> createState() => _VitaliaAppState();
}

final class _VitaliaAppState extends ConsumerState<VitaliaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Vitalia',
      debugShowCheckedModeBanner: false,
      theme: vitaliaTheme(),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [child ?? const SizedBox.shrink(), const AlarmOverlay()],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.invalidate(currentMinuteProvider);
        ref.invalidate(alarmNotifierProvider);
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        unawaited(
          _flush().catchError(
            unexpectedLogger('vitalia.lifecycle', 'lifecycle.flush'),
          ),
        );
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _flush() async {
    final result = await ref.read(vitaliaRepositoryProvider).flush();
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('vitalia.lifecycle', failure);
    }
  }
}
