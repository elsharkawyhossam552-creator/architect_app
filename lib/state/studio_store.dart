import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_boxes.dart';
import '../models/sketch.dart';

const _uuid = Uuid();

class StudioStore extends ChangeNotifier {
  final List<Sketch> _sketches = [];

  List<Sketch> get sketches => List.of(_sketches)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void load() {
    if (!HiveBoxes.ready) return;
    for (final e in HiveBoxes.sketches.values) {
      if (e is Map) {
        _sketches.add(Sketch.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    notifyListeners();
  }

  void add(Sketch sketch) {
    _sketches.add(sketch);
    if (HiveBoxes.ready) HiveBoxes.sketches.put(sketch.id, sketch.toJson());
    notifyListeners();
  }

  void remove(String id) {
    _sketches.removeWhere((s) => s.id == id);
    if (HiveBoxes.ready) HiveBoxes.sketches.delete(id);
    notifyListeners();
  }

  String newId() => _uuid.v4();
}
