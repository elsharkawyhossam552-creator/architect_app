import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/portfolio_project.dart';
import '../../state/portfolio_store.dart';
import '../../utils/formats.dart';
import '../../widgets/common.dart';
import '../../widgets/project_image.dart';
import 'portfolio_edit.dart';

class PortfolioDetailScreen extends StatelessWidget {
  const PortfolioDetailScreen({super.key, required this.project});

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PortfolioStore>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'تعديل',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioEditScreen(project: project),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'حذف المشروع',
                message: 'هل أنت متأكد من حذف هذا المشروع من البورتفوليو؟',
              );
              if (ok && context.mounted) {
                store.remove(project.id);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SizedBox(
            height: 240,
            child: Hero(
              tag: 'portfolio-${project.id}',
              child: ProjectImage(
                imagePath: project.imagePath,
                seed: project.id,
                icon: _categoryIcon(project.category),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2B31),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => store.toggleFavorite(project),
                      icon: Icon(
                        project.favorite ? Icons.favorite : Icons.favorite_border,
                        color: project.favorite
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: project.category.label,
                    ),
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: project.location.isEmpty ? 'غير محدد' : project.location,
                    ),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${project.year}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'وصف المشروع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2B31),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description.isEmpty
                      ? 'لا يوجد وصف لهذا المشروع.'
                      : project.description,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'أُضيف ${timeAgo(project.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(ProjectCategory category) => switch (category) {
        ProjectCategory.villa => Icons.home_work_outlined,
        ProjectCategory.apartment => Icons.apartment_outlined,
        ProjectCategory.office => Icons.business_outlined,
        ProjectCategory.commercial => Icons.storefront_outlined,
        ProjectCategory.other => Icons.dashboard_customize_outlined,
      };
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF0F766E)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
