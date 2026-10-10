import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/incident_record.dart';

class IncidentHistoryService {
  IncidentHistoryService._();
  static final IncidentHistoryService instance = IncidentHistoryService._();

  static const _key = 'proofpath_incident_history_v2';

  Future<List<IncidentRecord>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? <String>[];
      final records = raw
          .map((value) => IncidentRecord.fromJson(
                Map<String, dynamic>.from(jsonDecode(value) as Map),
              ))
          .toList();
      records.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return records;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(IncidentRecord record) async {
    final records = await getAll();
    records.removeWhere((item) => item.id == record.id);
    records.insert(0, record);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      records.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
