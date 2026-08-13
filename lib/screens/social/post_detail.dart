import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';
import '../../state/social_store.dart';
import '../../utils/formats.dart';
import '../../widgets/avatar.dart';
import '../../widgets/project_image.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    final post = store.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final author = store.authorOf(post);
    final liked = post.likes.contains(currentUserId);

    return Scaffold(
      appBar: AppBar(title: const Text('المنشور')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Avatar(architect: author, radius: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  author.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (author.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 15,
                                  color: Color(0xFF0F766E),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            timeAgo(post.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post.text.isNotEmpty)
                  Text(
                    post.text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Color(0xFF1B2B31),
                    ),
                  ),
                if (post.imagePath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ProjectImage(
                        imagePath: post.imagePath,
                        seed: 'post-${post.id}',
                        icon: Icons.image_outlined,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => store.toggleLike(post),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? const Color(0xFFE11D48) : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.likes.length} إعجاب',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${post.comments.length} تعليق',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                const Text(
                  'التعليقات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (post.comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'لا توجد تعليقات بعد. كن أول من يعلق.',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ...post.comments.map((c) => _commentTile(c)),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _submit,
                      decoration: const InputDecoration(
                        hintText: 'أضف تعليقاً...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _submit(_commentController.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    context.read<SocialStore>().addComment(widget.post, text);
    _commentController.clear();
  }

  Widget _commentTile(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFE8ECEE),
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName.characters.first
                  : '؟',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    comment.text,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
