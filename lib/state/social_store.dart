import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_boxes.dart';
import '../models/architect.dart';
import '../models/post.dart';

const _uuid = Uuid();
const currentUserId = 'me';

class SocialStore extends ChangeNotifier {
  final List<Architect> _architects = [];
  final List<Post> _posts = [];

  Architect? get currentUser {
    for (final a in _architects) {
      if (a.isCurrent) return a;
    }
    return null;
  }

  List<Architect> get architects {
    final list = List<Architect>.of(_architects);
    list.sort((a, b) {
      if (a.isCurrent) return -1;
      if (b.isCurrent) return 1;
      return b.followers.length.compareTo(a.followers.length);
    });
    return list;
  }

  List<Post> get posts {
    final list = List<Post>.of(_posts);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void load() {
    if (!HiveBoxes.ready) return;
    for (final e in HiveBoxes.architects.values) {
      if (e is Map) {
        _architects.add(Architect.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    for (final e in HiveBoxes.posts.values) {
      if (e is Map) _posts.add(Post.fromJson(Map<String, dynamic>.from(e)));
    }
    notifyListeners();
  }

  Architect authorOf(Post post) {
    for (final a in _architects) {
      if (a.id == post.authorId) return a;
    }
    return Architect(id: post.authorId, name: 'معماري', specialty: '');
  }

  void addPost(String text, {String? imagePath}) {
    if (text.trim().isEmpty && imagePath == null) return;
    final post = Post(
      id: _uuid.v4(),
      authorId: currentUserId,
      text: text.trim(),
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
    _posts.add(post);
    _persistPost(post);
    notifyListeners();
  }

  void toggleLike(Post post) {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i == -1) return;
    final likes = List<String>.of(post.likes);
    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
    } else {
      likes.add(currentUserId);
    }
    _posts[i] = post.copyWith(likes: likes);
    _persistPost(_posts[i]);
    notifyListeners();
  }

  void addComment(Post post, String text) {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i == -1 || text.trim().isEmpty) return;
    final author = currentUser;
    final comment = Comment(
      id: _uuid.v4(),
      authorId: currentUserId,
      authorName: author?.name ?? 'أنا',
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    _posts[i] = post.copyWith(comments: [...post.comments, comment]);
    _persistPost(_posts[i]);
    notifyListeners();
  }

  bool isFollowing(Architect architect) =>
      architect.followers.contains(currentUserId);

  void toggleFollow(Architect architect) {
    final i = _architects.indexWhere((a) => a.id == architect.id);
    if (i == -1 || architect.isCurrent) return;
    final followers = List<String>.of(architect.followers);
    if (followers.contains(currentUserId)) {
      followers.remove(currentUserId);
    } else {
      followers.add(currentUserId);
    }
    _architects[i] = architect.copyWith(followers: followers);
    _persistArchitect(_architects[i]);
    notifyListeners();
  }

  void _persistPost(Post p) {
    if (HiveBoxes.ready) HiveBoxes.posts.put(p.id, p.toJson());
  }

  void _persistArchitect(Architect a) {
    if (HiveBoxes.ready) HiveBoxes.architects.put(a.id, a.toJson());
  }
}
