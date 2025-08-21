import 'package:cloud_db/src/core/models/AttendanceRecord.dart';
import 'package:cloud_db/src/core/pages/abstract.dart';
import 'package:cloud_db/src/core/pages/attendanceForm.dart';
import 'package:flutter/material.dart';

class AttendanceListScreen extends StatefulWidget {
  final IAttendanceRepo repo;
  final DateTime? initialDate;
  const AttendanceListScreen({super.key, required this.repo, this.initialDate});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late DateTime _selectedDate;
  String? _searchName;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(widget.initialDate ?? DateTime.now());
  }

  Future<void> _refresh() async {
    // just rebuild -> FutureBuilder below will refetch
    setState(() {});
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // wider range, avoids edge cases
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked == null) return;

    final d = DateUtils.dateOnly(picked);
    if (!mounted) return;
    setState(() => _selectedDate = d); // FutureBuilder will refetch
  }

  void _openCreate() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AttendanceForm(
          date: _selectedDate,
          onSave: (name, status, note) async {
            await widget.repo.create(
              name: name,
              date: _selectedDate,
              status: status,
              note: note,
            );
          },
        ),
      ),
    );
    if (saved == true) _refresh();
  }

  Future<bool> _confirmAndDelete(AttendanceRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Remove ${r.name} on ${_fmtDate(r.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.repo.delete(r.id);
      await _refresh();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final future = widget.repo.list(
      onDate: _selectedDate,
      name: _searchName,
    ); // <-- generated here

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search by name',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(
                  () => _searchName = v.trim().isEmpty ? null : v.trim(),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<AttendanceRecord>>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: ${snap.error}'),
                      ),
                    );
                  }
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_busy, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No records for ${_fmtDate(_selectedDate)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = items[i];
                      return Dismissible(
                        key: ValueKey(r.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmAndDelete(r),
                        child: Card(
                          child: ListTile(
                            onLongPress: () => _confirmAndDelete(r),
                            leading: CircleAvatar(
                              child: Text(
                                r.name.isNotEmpty
                                    ? r.name[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(r.name),
                            // Segmented toggle + delete icon
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: 'present',
                                      label: Text('Present'),
                                      icon: Icon(Icons.check_circle_outline),
                                    ),
                                    ButtonSegment(
                                      value: 'absent',
                                      label: Text('Absent'),
                                      icon: Icon(Icons.cancel_outlined),
                                    ),
                                  ],
                                  selected: {r.status},
                                  onSelectionChanged: (sel) async {
                                    await widget.repo.update(
                                      r.id,
                                      status: sel.first,
                                    );
                                    _refresh();
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              final updated = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: AttendanceForm(
                                    date: r.date,
                                    existing: r,
                                    onSave: (name, status, note) async {
                                      await widget.repo.update(
                                        r.id,
                                        status: status,
                                        note: note,
                                      );
                                    },
                                  ),
                                ),
                              );
                              if (updated == true) _refresh();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
