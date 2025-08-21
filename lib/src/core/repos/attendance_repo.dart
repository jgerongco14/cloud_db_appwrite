// lib/src/core/repos/attendance_repo.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cloud_db/src/core/models/AttendanceRecord.dart';
import 'package:cloud_db/src/core/pages/abstract.dart';

class AttendanceRepo implements IAttendanceRepo {
  final PocketBase pb;
  AttendanceRepo(this.pb);

  @override
  Future<AttendanceRecord> create({
    required String name,
    required DateTime date,
    required String status,
    String? note,
  }) async {
    final utcMidnight = DateTime.utc(date.year, date.month, date.day);
    final rec = await pb
        .collection('attendance_records')
        .create(
          body: {
            'name': name,
            'date': utcMidnight.toIso8601String(),
            'status': status,
            if (note != null) 'note': note,
          },
        );
    return AttendanceRecord.fromRecord(rec);
  }

  @override
  Future<List<AttendanceRecord>> list({
    String? name,
    DateTime? onDate,
    DateTime? from,
    DateTime? to,
  }) async {
    final f = <String>[];
    if (name != null && name.isNotEmpty) f.add('name ~ "$name"');

    if (onDate != null) {
      final startLocal = DateTime(
        onDate.year,
        onDate.month,
        onDate.day,
      ); // local midnight
      final start = startLocal.toUtc(); // -> UTC
      final end = startLocal.add(const Duration(days: 1)).toUtc();
      f.add(
        'date >= "${start.toIso8601String()}" && date < "${end.toIso8601String()}"',
      );
    } else if (from != null && to != null) {
      f.add(
        'date >= "${from.toUtc().toIso8601String()}" && date <= "${to.toUtc().toIso8601String()}"',
      );
    }

    final filter = f.isEmpty ? null : f.join(' && ');
    debugPrint('[AttendanceRepo] filter => $filter');

    final res = await pb
        .collection('attendance_records')
        .getList(page: 1, perPage: 200, filter: filter, sort: '-date');
    debugPrint('[AttendanceRepo] items => ${res.items.length}');
    return res.items.map(AttendanceRecord.fromRecord).toList();
  }

  @override
  Future<AttendanceRecord> update(
    String id, {
    String? status,
    String? note,
  }) async {
    final rec = await pb
        .collection('attendance_records')
        .update(
          id,
          body: {
            if (status != null) 'status': status,
            if (note != null) 'note': note,
          },
        );
    return AttendanceRecord.fromRecord(rec);
  }

  @override
  Future<void> delete(String id) =>
      pb.collection('attendance_records').delete(id);

  @override
  Future<AttendanceRecord> toggleStatus(String id, String current) =>
      update(id, status: current == 'present' ? 'absent' : 'present');
}
