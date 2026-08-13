import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/architect.dart';
import '../../models/post.dart';
import '../../state/social_store.dart';
import '../../utils/formats.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/project_image.dart';
import 'post_detail.dart';
import 'post_editor.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المجتمع'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المنشورات'),
              Tab(text: 'المعماريون'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostEditorScreen()),
          ),
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('منشور جديد'),
        ),
        body: const TabBarView(
          children: [
            _FeedTab(),
            _ArchitectsTab(),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    final posts = store.posts;
    if (posts.isEmpty) {
      return const EmptyState(
        icon: Icons.forum_outlined,
        title: 'لا توجد منشورات بعد',
        subtitle: 'شارك أول تحديث مع المجتمع',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: posts.length,
      itemBuilder: (context, i) => PostCard(post: posts[i]),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    final author = store.authorOf(post);
    final liked = post.likes.contains(currentUserId);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _authorRow(author, post.createdAt),
              const SizedBox(height: 10),
              if (post.text.isNotEmpty)
                Text(
                  post.text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.6,
                    color: Color(0xFF1B2B31),
                  ),
                ),
              if (post.imagePath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    tooltip: liked ? 'إزالة الإعجاب' : 'إعجاب',
                    onPressed: () => store.toggleLike(post),
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${post.likes.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.mode_comment_outlined,
                    color: Color(0xFF64748B),
                    size: 21,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'تعليق',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: const Color(0xFF0F766E).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authorRow(Architect author, DateTime createdAt) {
    return Row(
      children: [
        Avatar(architect: author, radius: 20),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2B31),
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
                timeAgo(createdAt),
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchitectsTab extends StatelessWidget {
  const _ArchitectsTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: store.architects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final architect = store.architects[i];
        final isFollowing = store.isFollowing(architect);
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: Avatar(architect: architect, radius: 24),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    architect.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                if (architect.verified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    size: 15,
                    color: Color(0xFF0F766E),
                  ),
                ],
                if (architect.isCurrent) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'أنت',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  architect.specialty,
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${architect.followers.length} متابع',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            trailing: architect.isCurrent
                ? null
                : FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: isFollowing
                          ? const Color(0xFFF2F4F5)
                          : const Color(0xFF0F766E),
                      foregroundColor: isFollowing
                          ? const Color(0xFF374151)
                          : Colors.white,
                    ),
                    onPressed: () => store.toggleFollow(architect),
                    child: Text(isFollowing ? 'متابعة' : 'تابع'),
                  ),
            onTap: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (_) => _ArchitectSheet(architect: architect),
            ),
          ),
        );
      },
    );
  }
}

class _ArchitectSheet extends StatelessWidget {
  const _ArchitectSheet({required this.architect});

  final Architect architect;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(architect: architect, radius: 34),
          const SizedBox(height: 10),
          Text(
            architect.name,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            architect.specialty,
            style: const TextStyle(color: Color(0xFF0F766E)),
          ),
          const SizedBox(height: 6),
          Text(
            '${architect.location} - ${architect.followers.length} متابع',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Text(
            architect.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: architect.isCurrent
                ? const OutlinedButton(onPressed: null, child: Text('هذا أنت'))
                : FilledButton(
                    onPressed: () => store.toggleFollow(architect),
                    child: Text(
                      store.isFollowing(architect) ? 'إلغاء المتابعة' : 'متابعة',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
