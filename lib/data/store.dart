import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'demo_cabinet.dart';
import 'repository.dart';
import 'schedule.dart';

class VitaliaStore extends ChangeNotifier {
  VitaliaStore({required this._repository, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final VitaliaRepository _repository;
  final DateTime Function() _clock;
  final _random = Random();

  Snapshot _snapshot = Snapshot.empty;
  bool _loaded = false;
  String? _ringingId;
  bool _testAlarm = false;
  DateTime _now = DateTime.now();

  bool get isLoaded => _loaded;

  DateTime get now => _now;

  List<Medication> get medications => List.unmodifiable(_snapshot.medications);

  List<DoseEvent> get events => List.unmodifiable(_snapshot.events);

  AppSettings get settings => _snapshot.settings;

  List<DoseSlot> get todaySlots => slotsForDay(
    medications: _snapshot.medications,
    events: _snapshot.events,
    day: _now,
    now: _now,
  );

  List<Medication> get refillSoon =>
      _snapshot.medications.where((med) => med.needsRefill).toList();

  DoseSlot? get ringingSlot {
    if (_testAlarm) {
      final med = _snapshot.medications.isEmpty
          ? sampleMedication()
          : _snapshot.medications.first;
      return DoseSlot(
        medication: med,
        scheduledAt: _now,
        status: SlotStatus.due,
        isTest: true,
      );
    }
    if (_ringingId == null) return null;
    for (final slot in todaySlots) {
      if (slot.id == _ringingId) return slot;
    }
    return null;
  }

  Adherence get weekAdherence {
    return adherenceForRange(
      medications: _snapshot.medications,
      events: _snapshot.events,
      from: mondayOf(_now),
      to: dateOnly(_now),
      now: _now,
    );
  }

  int get streak => cleanStreak(
    medications: _snapshot.medications,
    events: _snapshot.events,
    now: _now,
  );

  List<DaySummary> get lastSeven => lastSevenDays(
    medications: _snapshot.medications,
    events: _snapshot.events,
    now: _now,
  );

  List<DoseEvent> get recentEvents {
    final items = [..._snapshot.events]..sort((a, b) => b.at.compareTo(a.at));
    if (items.length <= 30) return List.unmodifiable(items);
    return List.unmodifiable(items.take(30));
  }

  List<DoseSlot> slotsOn(DateTime day) {
    return slotsForDay(
      medications: _snapshot.medications,
      events: _snapshot.events,
      day: day,
      now: _now,
    );
  }

  Future<void> load() async {
    _now = _clock();
    final existing = await _repository.load();
    if (existing == null || !existing.initialized) {
      _snapshot = Snapshot(
        initialized: true,
        medications: demoCabinet(),
        events: const [],
        settings: AppSettings.defaults,
      );
      await _repository.save(_snapshot);
    } else {
      _snapshot = existing;
    }
    _loaded = true;
    _refreshRinging();
    notifyListeners();
  }

  void tick() {
    final next = _clock();
    final minuteChanged =
        next.minute != _now.minute ||
        next.hour != _now.hour ||
        next.day != _now.day;
    _now = next;
    final previous = _ringingId;
    final wasTest = _testAlarm;
    _refreshRinging();
    if (minuteChanged ||
        previous != _ringingId ||
        wasTest != _testAlarm ||
        _ringingId != null ||
        _testAlarm) {
      notifyListeners();
    }
  }

  Future<void> take(DoseSlot slot) async {
    if (slot.isTest) {
      _testAlarm = false;
      notifyListeners();
      return;
    }
    if (_alreadyResolved(slot)) return;
    _append(
      DoseEvent(
        id: _newId(),
        medicationId: slot.medication.id,
        medicationName: slot.medication.name,
        scheduledAt: slot.scheduledAt,
        at: _clock(),
        action: DoseAction.taken,
      ),
    );
    _decrementQuantity(slot.medication.id);
    _clearRingingIf(slot.id);
    await _commit();
  }

  Future<void> skip(DoseSlot slot) async {
    if (slot.isTest) {
      _testAlarm = false;
      notifyListeners();
      return;
    }
    if (_alreadyResolved(slot)) return;
    _append(
      DoseEvent(
        id: _newId(),
        medicationId: slot.medication.id,
        medicationName: slot.medication.name,
        scheduledAt: slot.scheduledAt,
        at: _clock(),
        action: DoseAction.skipped,
      ),
    );
    _clearRingingIf(slot.id);
    await _commit();
  }

  Future<void> snooze(DoseSlot slot) async {
    if (slot.isTest) {
      _testAlarm = false;
      notifyListeners();
      return;
    }
    if (_alreadyResolved(slot)) return;
    final until = _clock().add(Duration(minutes: settings.snoozeMinutes));
    _append(
      DoseEvent(
        id: _newId(),
        medicationId: slot.medication.id,
        medicationName: slot.medication.name,
        scheduledAt: slot.scheduledAt,
        at: _clock(),
        action: DoseAction.snoozed,
        snoozeUntil: until,
      ),
    );
    _clearRingingIf(slot.id);
    await _commit();
  }

  Future<void> upsertMedication(Medication medication) async {
    final next = [..._snapshot.medications];
    final index = next.indexWhere((item) => item.id == medication.id);
    if (index == -1) {
      next.add(medication);
    } else {
      next[index] = medication;
    }
    _snapshot = _snapshot.copyWith(medications: next);
    await _commit();
  }

  Future<void> deleteMedication(String id) async {
    _snapshot = _snapshot.copyWith(
      medications: _snapshot.medications
          .where((item) => item.id != id)
          .toList(),
    );
    if (_ringingId != null && _ringingId!.startsWith('$id@')) {
      _ringingId = null;
    }
    await _commit();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _snapshot = _snapshot.copyWith(settings: settings);
    await _commit();
  }

  Future<void> restoreDemo() async {
    _testAlarm = false;
    _ringingId = null;
    _snapshot = Snapshot(
      initialized: true,
      medications: demoCabinet(),
      events: const [],
      settings: _snapshot.settings,
    );
    await _commit();
  }

  Future<void> clearAll() async {
    _testAlarm = false;
    _ringingId = null;
    _snapshot = Snapshot.empty.copyWith(settings: AppSettings.defaults);
    await _commit();
  }

  void startTestAlarm() {
    _testAlarm = true;
    notifyListeners();
  }

  String newMedicationId() => _newId();

  bool _alreadyResolved(DoseSlot slot) {
    for (final current in todaySlots) {
      if (current.id == slot.id) {
        return current.status == SlotStatus.taken ||
            current.status == SlotStatus.skipped;
      }
    }
    return false;
  }

  void _append(DoseEvent event) {
    _snapshot = _snapshot.copyWith(events: [..._snapshot.events, event]);
  }

  void _decrementQuantity(String medicationId) {
    final next = <Medication>[];
    for (final medication in _snapshot.medications) {
      if (medication.id != medicationId || medication.quantity == null) {
        next.add(medication);
        continue;
      }
      final remaining = medication.quantity! - 1;
      next.add(medication.copyWith(quantity: remaining < 0 ? 0 : remaining));
    }
    _snapshot = _snapshot.copyWith(medications: next);
  }

  void _clearRingingIf(String slotId) {
    if (_ringingId == slotId) _ringingId = null;
  }

  void _refreshRinging() {
    if (_testAlarm) return;
    if (_ringingId != null) {
      DoseSlot? current;
      for (final slot in todaySlots) {
        if (slot.id == _ringingId) current = slot;
      }
      if (current != null && current.status == SlotStatus.due) return;
      _ringingId = null;
    }
    final due = todaySlots
        .where((slot) => slot.status == SlotStatus.due)
        .toList();
    if (due.isEmpty) return;
    _ringingId = due.first.id;
  }

  Future<void> _commit() async {
    _now = _clock();
    _refreshRinging();
    notifyListeners();
    await _repository.save(_snapshot);
  }

  String _newId() {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = _random.nextInt(0x7fffffff).toRadixString(36);
    return '$stamp$noise';
  }
}
