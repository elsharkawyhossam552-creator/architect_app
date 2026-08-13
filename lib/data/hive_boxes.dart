import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  HiveBoxes._();

  static const _prefix = 'arch_';
  static bool ready = false;

  static Box get portfolio => Hive.box('${_prefix}portfolio');
  static Box get clientProjects => Hive.box('${_prefix}projects');
  static Box get posts => Hive.box('${_prefix}posts');
  static Box get architects => Hive.box('${_prefix}architects');
  static Box get sketches => Hive.box('${_prefix}sketches');
  static Box get meta => Hive.box('${_prefix}meta');

  static Future<void> open() async {
    await Hive.openBox('${_prefix}portfolio');
    await Hive.openBox('${_prefix}projects');
    await Hive.openBox('${_prefix}posts');
    await Hive.openBox('${_prefix}architects');
    await Hive.openBox('${_prefix}sketches');
    await Hive.openBox('${_prefix}meta');
    ready = true;
  }

  static Future<void> clearAll() async {
    for (final name in [
      '${_prefix}portfolio',
      '${_prefix}projects',
      '${_prefix}posts',
      '${_prefix}architects',
      '${_prefix}sketches',
      '${_prefix}meta',
    ]) {
      await Hive.box(name).clear();
    }
  }
}
