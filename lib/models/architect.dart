class Architect {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String location;
  final int avatarColor;
  final bool verified;
  final List<String> followers;

  const Architect({
    required this.id,
    required this.name,
    required this.specialty,
    this.bio = '',
    this.location = '',
    this.avatarColor = 0xFF0F766E,
    this.verified = false,
    this.followers = const [],
  });

  bool get isCurrent => id == 'me';

  Architect copyWith({List<String>? followers}) => Architect(
        id: id,
        name: name,
        specialty: specialty,
        bio: bio,
        location: location,
        avatarColor: avatarColor,
        verified: verified,
        followers: followers ?? this.followers,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'bio': bio,
        'location': location,
        'avatarColor': avatarColor,
        'verified': verified,
        'followers': followers,
      };

  factory Architect.fromJson(Map<String, dynamic> json) => Architect(
        id: json['id'] as String,
        name: json['name'] as String,
        specialty: json['specialty'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        location: json['location'] as String? ?? '',
        avatarColor: json['avatarColor'] as int? ?? 0xFF0F766E,
        verified: json['verified'] as bool? ?? false,
        followers: (json['followers'] as List?)?.cast<String>() ?? const [],
      );
}
