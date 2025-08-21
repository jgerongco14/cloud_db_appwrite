// lib/src/core/controller/attendance_controller.dart
import '../pages/abstract.dart';

class AttendanceController implements IAttendanceRepo {
  final IAttendanceRepo repo;
  AttendanceController(this.repo);

  // delegate
  @override
  create({required name, required date, required status, String? note}) =>
      repo.create(name: name, date: date, status: status, note: note);
  @override
  list({String? name, DateTime? onDate, DateTime? from, DateTime? to}) =>
      repo.list(name: name, onDate: onDate, from: from, to: to);
  @override
  update(id, {String? status, String? note}) =>
      repo.update(id, status: status, note: note);
  @override
  delete(id) => repo.delete(id);
  @override
  toggleStatus(id, current) => repo.toggleStatus(id, current);
}
