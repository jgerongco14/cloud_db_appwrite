import 'package:pocketbase/pocketbase.dart';

class AttendanceRecord {
  final String id;
  final String name;
  final DateTime date;
  final String status; // 'present' | 'absent'
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.note,
  });

  factory AttendanceRecord.fromRecord(RecordModel record) => AttendanceRecord(
    id: record.id,
    name: record.data['name'] as String,
    date: DateTime.parse(record.data['date'] as String),
    status: record.data['status'] as String,
    note: record.data['note'] as String?,
  );
}
