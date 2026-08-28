import 'package:flutter/material.dart';

import 'package:vitalia/data/store.dart';

class VitaliaScope extends InheritedNotifier<VitaliaStore> {
  const VitaliaScope({
    super.key,
    required VitaliaStore store,
    required super.child,
  }) : super(notifier: store);

  static VitaliaStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VitaliaScope>();
    assert(scope != null, 'VitaliaScope not found');
    return scope!.notifier!;
  }
}
