import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitalia/domain/entities.dart';

abstract class VitaliaRepository {
  Future<Snapshot?> load();

  Future<void> save(Snapshot snapshot);
}

class MemoryRepository implements VitaliaRepository {
  MemoryRepository([this.snapshot]);

  Snapshot? snapshot;

  @override
  Future<Snapshot?> load() async => snapshot;

  @override
  Future<void> save(Snapshot next) async {
    snapshot = next;
  }
}

class PrefsRepository implements VitaliaRepository {
  PrefsRepository({this._prefs});

  static const key = 'vitalia.snapshot.v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<Snapshot?> load() async {
    final prefs = await _instance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return Snapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return Snapshot.empty;
    }
  }

  @override
  Future<void> save(Snapshot snapshot) async {
    final prefs = await _instance();
    await prefs.setString(key, jsonEncode(snapshot.toJson()));
  }
}
