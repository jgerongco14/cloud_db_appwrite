import 'package:appwrite/models.dart' as models;

/// Data model mapped to an Appwrite Document
class AttendanceRecord {
  final String id; // Appwrite document $id
  final String name;
  final DateTime date; // Stored as ISO8601 string in Appwrite
  final String status; // 'present' | 'absent'
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.note,
  });

  /// Create from Appwrite Document
  factory AttendanceRecord.fromDocument(models.Document doc) {
    final data = doc.data; // Map<String, dynamic>
    return AttendanceRecord(
      id: doc.$id,
      name: (data['name'] ?? '') as String,
      date: DateTime.parse(
        (data['date'] ?? DateTime.now().toIso8601String()) as String,
      ),
      status: (data['status'] ?? '') as String,
      note: data['note'] as String?,
    );
  }

  /// Convert to a map suitable for Appwrite create/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'status': status,
      'note': note,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? status,
    String? note,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
