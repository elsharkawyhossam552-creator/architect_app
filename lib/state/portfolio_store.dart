import 'package:flutter/foundation.dart';

import '../data/hive_boxes.dart';
import '../models/portfolio_project.dart';

class PortfolioStore extends ChangeNotifier {
  final List<PortfolioProject> _projects = [];
  ProjectCategory? _filter;

  List<PortfolioProject> get projects {
    final list = List<PortfolioProject>.of(_projects)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_filter == null) return list;
    return list.where((p) => p.category == _filter).toList();
  }

  ProjectCategory? get filter => _filter;
  List<PortfolioProject> get favorites =>
      _projects.where((p) => p.favorite).toList();

  void load() {
    if (!HiveBoxes.ready) return;
    for (final e in HiveBoxes.portfolio.values) {
      if (e is Map) {
        _projects.add(
          PortfolioProject.fromJson(Map<String, dynamic>.from(e)),
        );
      }
    }
    notifyListeners();
  }

  void add(PortfolioProject project) {
    _projects.add(project);
    _persist(project);
    notifyListeners();
  }

  void update(PortfolioProject project) {
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) return;
    _projects[i] = project;
    _persist(project);
    notifyListeners();
  }

  void remove(String id) {
    _projects.removeWhere((p) => p.id == id);
    if (HiveBoxes.ready) HiveBoxes.portfolio.delete(id);
    notifyListeners();
  }

  void toggleFavorite(PortfolioProject project) {
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) return;
    final updated = project.copyWith(favorite: !project.favorite);
    _projects[i] = updated;
    _persist(updated);
    notifyListeners();
  }

  void setFilter(ProjectCategory? category) {
    _filter = category;
    notifyListeners();
  }

  void _persist(PortfolioProject p) {
    if (HiveBoxes.ready) HiveBoxes.portfolio.put(p.id, p.toJson());
  }
}
