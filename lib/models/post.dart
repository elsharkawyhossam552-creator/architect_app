class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        text: json['text'] as String,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class Post {
  final String id;
  final String authorId;
  final String text;
  final String? imagePath;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.text,
    this.imagePath,
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
  });

  Post copyWith({
    List<String>? likes,
    List<Comment>? comments,
  }) =>
      Post(
        id: id,
        authorId: authorId,
        text: text,
        imagePath: imagePath,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'text': text,
        'imagePath': imagePath,
        'likes': likes,
        'comments': comments.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        text: json['text'] as String,
        imagePath: json['imagePath'] as String?,
        likes: (json['likes'] as List?)?.cast<String>() ?? const [],
        comments: (json['comments'] as List? ?? const [])
            .map((c) => Comment.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
