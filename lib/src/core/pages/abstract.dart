import 'package:cloud_db/src/core/models/AttendanceRecord.dart';

abstract class IAttendanceRepo {
  Future<AttendanceRecord> create({
    required String name,
    required DateTime date,
    required String status,
    String? note,
  });
  Future<List<AttendanceRecord>> list({
    String? name,
    DateTime? onDate,
    DateTime? from,
    DateTime? to,
  });
  Future<AttendanceRecord> update(String id, {String? status, String? note});
  Future<void> delete(String id);
  Future<AttendanceRecord> toggleStatus(String id, String current);
}
