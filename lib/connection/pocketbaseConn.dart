// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/foundation.dart';

class Connection {
  // static final pb = PocketBase('https://clouds.pockethost.io/');

  static String pbBaseUrl() {
    if (kIsWeb) return 'http://localhost:8090'; // same machine in browser
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090'; // AVD -> host loopback
    }
    return 'http://127.0.0.1:8090'; // iOS sim / desktop
  }
}
