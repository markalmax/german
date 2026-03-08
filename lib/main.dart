import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('units');
  await Hive.openBox<String>('sessions');
  await Hive.openBox<String>('stats');

  runApp(const VocabApp());
}
