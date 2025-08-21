// ignore_for_file: body_might_complete_normally_nullable

import 'package:cloud_db/connection/Connection.dart';
import 'package:cloud_db/src/core/models/AttendanceRecord.dart';
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';

class AttendanceController extends ChangeNotifier {
  // Appwrite clients
  late final Client _client;
  late final Databases _db;

  // Local state
  final List<AttendanceRecord> _items = [];
  List<AttendanceRecord> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AttendanceController() {
    _client = Client()
      ..setEndpoint(Connection.endpoint)
      ..setProject(Connection.projectId);
    _db = Databases(_client);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  /// CREATE
  Future<AttendanceRecord?> create({
    required String name,
    required DateTime date,
    required String status, // 'present' | 'absent'
    String? note,
  }) async {
    try {
      _setLoading(true);
      // final payload = {
      //   'name': name,
      //   'date': date.toIso8601String(),
      //   'status': status,
      //   'note': note,
      // };

      final documentId = ID.unique(); // Generate unique ID

      final doc = await _db.createDocument(
        databaseId: Connection.databaseId,
        collectionId: Connection.collectionId,
        documentId: documentId.toString(),
        data: {
          'name': name,
          'date': date.toIso8601String(),
          'status': status,
          'note': note,
        },
      );

      final record = AttendanceRecord.fromDocument(doc);
      _items.insert(0, record);
      notifyListeners();
      _setError(null);
      return record;
    } catch (e) {
      _setError(e.toString());
      if (kDebugMode) {
        print('Error creating attendance record: $e');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// READ one by id
  Future<AttendanceRecord?> getById(String id) async {
    try {
      _setLoading(true);
      final doc = await _db.getDocument(
        databaseId: Connection.databaseId,
        collectionId: Connection.collectionId,
        documentId: id,
      );
      final rec = AttendanceRecord.fromDocument(doc);
      _setError(null);
      return rec;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// LIST (with optional filters)
  ///
  /// Example filters:
  /// - Query.equal('status', 'present')
  /// - Query.search('name', 'juan')
  /// - Query.between('date', startIso, endIso) if you store date as ISO String
  Future<List<AttendanceRecord>> list({
    List<String>? queries,
    int? limit,
    int? offset,
  }) async {
    try {
      _setLoading(true);
      final res = await _db.listDocuments(
        databaseId: Connection.databaseId,
        collectionId: Connection.collectionId,
        queries: queries,
      );

      final records = res.documents
          .map((d) => AttendanceRecord.fromDocument(d))
          .toList();

      // Optionally sync local cache:
      _items
        ..clear()
        ..addAll(records);
      notifyListeners();

      _setError(null);
      return records;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  //List By Date
  Future<List<AttendanceRecord>> listByDate({
    required DateTime onDate,
    String? name,
    bool orderByNameAsc = true,
  }) async {
    final start = DateTime(
      onDate.year,
      onDate.month,
      onDate.day,
    ).toIso8601String();
    final end = DateTime(
      onDate.year,
      onDate.month,
      onDate.day,
      23,
      59,
      59,
    ).toIso8601String();

    final queries = <String>[
      Query.between('date', start, end),
      if (name != null && name.trim().isNotEmpty)
        (name.trim().length >= 3
            ? Query.search('name', name.trim())
            : Query.equal('name', name.trim())),
      if (orderByNameAsc) Query.orderAsc('name') else Query.orderDesc('name'),
    ];

    return list(queries: queries);
  }

  /// UPDATE
  Future<AttendanceRecord?> update({
    required String id,
    String? name,
    DateTime? date,
    String? status,
    String? note,
  }) async {
    try {
      _setLoading(true);

      // Build only changed fields
      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name;
      if (date != null) payload['date'] = date.toIso8601String();
      if (status != null) payload['status'] = status;
      if (note != null) payload['note'] = note;

      final doc = await _db.updateDocument(
        databaseId: Connection.databaseId,
        collectionId: Connection.collectionId,
        documentId: id,
        data: payload,
      );

      final updated = AttendanceRecord.fromDocument(doc);

      // Update local cache
      final idx = _items.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _items[idx] = updated;
      } else {
        _items.insert(0, updated);
      }
      notifyListeners();

      _setError(null);
      return updated;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// DELETE
  Future<bool> delete(String id) async {
    try {
      _setLoading(true);
      await _db.deleteDocument(
        databaseId: Connection.databaseId,
        collectionId: Connection.collectionId,
        documentId: id,
      );
      _items.removeWhere((r) => r.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
