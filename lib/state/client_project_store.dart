import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_boxes.dart';
import '../models/client_project.dart';

const _uuid = Uuid();

class ClientProjectStore extends ChangeNotifier {
  final List<ClientProject> _projects = [];

  List<ClientProject> get projects => List.of(_projects)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get activeCount => _projects
      .where((p) => p.status != ProjectStatus.delivered)
      .length;

  void load() {
    if (!HiveBoxes.ready) return;
    for (final e in HiveBoxes.clientProjects.values) {
      if (e is Map) {
        _projects.add(
          ClientProject.fromJson(Map<String, dynamic>.from(e)),
        );
      }
    }
    notifyListeners();
  }

  void add(ClientProject project) {
    _projects.add(project);
    _persist(project);
    notifyListeners();
  }

  void update(ClientProject project) {
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) return;
    _projects[i] = project;
    _persist(project);
    notifyListeners();
  }

  void remove(String id) {
    _projects.removeWhere((p) => p.id == id);
    if (HiveBoxes.ready) HiveBoxes.clientProjects.delete(id);
    notifyListeners();
  }

  void setStatus(String id, ProjectStatus status) {
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _projects[i] = _projects[i].copyWith(status: status);
    _persist(_projects[i]);
    notifyListeners();
  }

  void setProgress(String id, double progress) {
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _projects[i] = _projects[i].copyWith(progress: progress.clamp(0, 100));
    _persist(_projects[i]);
    notifyListeners();
  }

  void addTask(String id, String title, {String priority = 'متوسطة'}) {
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1 || title.trim().isEmpty) return;
    final project = _projects[i];
    _projects[i] = project.copyWith(
      tasks: [
        ...project.tasks,
        ProjectTask(id: _uuid.v4(), title: title.trim(), priority: priority),
      ],
    );
    _persist(_projects[i]);
    notifyListeners();
  }

  void toggleTask(String projectId, String taskId) {
    final i = _projects.indexWhere((p) => p.id == projectId);
    if (i == -1) return;
    final project = _projects[i];
    _projects[i] = project.copyWith(
      tasks: project.tasks
          .map((t) => t.id == taskId ? t.copyWith(done: !t.done) : t)
          .toList(),
    );
    _persist(_projects[i]);
    notifyListeners();
  }

  void removeTask(String projectId, String taskId) {
    final i = _projects.indexWhere((p) => p.id == projectId);
    if (i == -1) return;
    final project = _projects[i];
    _projects[i] = project.copyWith(
      tasks: project.tasks.where((t) => t.id != taskId).toList(),
    );
    _persist(_projects[i]);
    notifyListeners();
  }

  void addNote(String id, String note) {
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1 || note.trim().isEmpty) return;
    final project = _projects[i];
    _projects[i] = project.copyWith(notes: [note.trim(), ...project.notes]);
    _persist(_projects[i]);
    notifyListeners();
  }

  void _persist(ClientProject p) {
    if (HiveBoxes.ready) HiveBoxes.clientProjects.put(p.id, p.toJson());
  }
}
