import 'package:cloud_db/src/core/controller/AttendanceController.dart';
import 'package:cloud_db/src/core/pages/attendanceList.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ctrl = AttendanceController();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AttendanceListScreen(ctrl: ctrl),
    );
  }
}
