enum ProjectStatus { inquiry, initial, approved, execution, review, delivered }

extension ProjectStatusX on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.inquiry => 'استفسار',
        ProjectStatus.initial => 'تصميم مبدئي',
        ProjectStatus.approved => 'اعتماد التصميم',
        ProjectStatus.execution => 'تنفيذ',
        ProjectStatus.review => 'مراجعة وتسليم',
        ProjectStatus.delivered => 'تم التسليم',
      };
}

class ProjectTask {
  final String id;
  final String title;
  final bool done;
  final String priority;

  const ProjectTask({
    required this.id,
    required this.title,
    this.done = false,
    this.priority = 'متوسطة',
  });

  ProjectTask copyWith({bool? done}) => ProjectTask(
        id: id,
        title: title,
        done: done ?? this.done,
        priority: priority,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'done': done, 'priority': priority};

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
        priority: json['priority'] as String? ?? 'متوسطة',
      );
}

class ClientProject {
  final String id;
  final String title;
  final String clientName;
  final String phone;
  final String description;
  final String address;
  final double budget;
  final ProjectStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? deadline;
  final List<String> notes;
  final List<ProjectTask> tasks;

  const ClientProject({
    required this.id,
    required this.title,
    this.clientName = '',
    this.phone = '',
    this.description = '',
    this.address = '',
    this.budget = 0,
    this.status = ProjectStatus.inquiry,
    this.progress = 0,
    required this.createdAt,
    this.startDate,
    this.deadline,
    this.notes = const [],
    this.tasks = const [],
  });

  double get doneTasksRatio {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.done).length / tasks.length;
  }

  ClientProject copyWith({
    String? title,
    String? clientName,
    String? phone,
    String? description,
    String? address,
    double? budget,
    ProjectStatus? status,
    double? progress,
    DateTime? startDate,
    DateTime? deadline,
    List<String>? notes,
    List<ProjectTask>? tasks,
  }) =>
      ClientProject(
        id: id,
        title: title ?? this.title,
        clientName: clientName ?? this.clientName,
        phone: phone ?? this.phone,
        description: description ?? this.description,
        address: address ?? this.address,
        budget: budget ?? this.budget,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        createdAt: createdAt,
        startDate: startDate ?? this.startDate,
        deadline: deadline ?? this.deadline,
        notes: notes ?? this.notes,
        tasks: tasks ?? this.tasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'clientName': clientName,
        'phone': phone,
        'description': description,
        'address': address,
        'budget': budget,
        'status': status.name,
        'progress': progress,
        'createdAt': createdAt.toIso8601String(),
        'startDate': startDate?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'notes': notes,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory ClientProject.fromJson(Map<String, dynamic> json) => ClientProject(
        id: json['id'] as String,
        title: json['title'] as String,
        clientName: json['clientName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        description: json['description'] as String? ?? '',
        address: json['address'] as String? ?? '',
        budget: (json['budget'] as num?)?.toDouble() ?? 0,
        status: ProjectStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ProjectStatus.inquiry,
        ),
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'] as String)
            : null,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'] as String)
            : null,
        notes: (json['notes'] as List?)?.cast<String>() ?? const [],
        tasks: (json['tasks'] as List? ?? const [])
            .map((t) => ProjectTask.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList(),
      );
}
