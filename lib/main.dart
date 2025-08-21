import 'package:cloud_db/src/core/pages/attendanceList.dart';
import 'package:cloud_db/src/core/repos/attendance_repo.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'connection/pocketbaseConn.dart';

void main() {
  final pb = PocketBase(Connection.pbBaseUrl());
  runApp(MyApp(pb: pb));
}

class MyApp extends StatelessWidget {
  final PocketBase pb;
  const MyApp({super.key, required this.pb});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final repo = AttendanceRepo(pb);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AttendanceListScreen(repo: repo, initialDate: DateTime.now()),
    );
  }
}
