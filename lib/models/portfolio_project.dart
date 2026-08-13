enum ProjectCategory { villa, apartment, office, commercial, other }

extension ProjectCategoryX on ProjectCategory {
  String get label => switch (this) {
        ProjectCategory.villa => 'فيلا',
        ProjectCategory.apartment => 'شقة',
        ProjectCategory.office => 'مكتب',
        ProjectCategory.commercial => 'تجاري',
        ProjectCategory.other => 'أخرى',
      };

  static ProjectCategory fromLabel(String label) => ProjectCategory.values
      .firstWhere((c) => c.label == label, orElse: () => ProjectCategory.other);
}

class PortfolioProject {
  final String id;
  final String title;
  final String description;
  final ProjectCategory category;
  final String location;
  final int year;
  final String? imagePath;
  final bool favorite;
  final DateTime createdAt;

  PortfolioProject({
    required this.id,
    required this.title,
    this.description = '',
    this.category = ProjectCategory.other,
    this.location = '',
    int? year,
    this.imagePath,
    this.favorite = false,
    required this.createdAt,
  }) : year = year ?? DateTime.now().year;

  PortfolioProject copyWith({
    String? title,
    String? description,
    ProjectCategory? category,
    String? location,
    int? year,
    String? imagePath,
    bool? favorite,
  }) =>
      PortfolioProject(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        location: location ?? this.location,
        year: year ?? this.year,
        imagePath: imagePath ?? this.imagePath,
        favorite: favorite ?? this.favorite,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'year': year,
        'imagePath': imagePath,
        'favorite': favorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PortfolioProject.fromJson(Map<String, dynamic> json) => PortfolioProject(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: ProjectCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ProjectCategory.other,
        ),
        location: json['location'] as String? ?? '',
        year: json['year'] as int? ?? DateTime.now().year,
        imagePath: json['imagePath'] as String?,
        favorite: json['favorite'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
