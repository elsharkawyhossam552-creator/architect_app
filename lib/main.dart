import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/hive_boxes.dart';
import 'data/seed_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveBoxes.open();
  await SeedData.ensureSeeded();
  runApp(const ArchApp());
}
