import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/portfolio_project.dart';
import '../../state/portfolio_store.dart';
import '../../widgets/common.dart';
import '../../widgets/project_image.dart';
import 'portfolio_detail.dart';
import 'portfolio_edit.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البورتفوليو'),
        actions: [
          Consumer<PortfolioStore>(
            builder: (context, store, _) => IconButton(
              tooltip: 'المفضلة',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              ),
              icon: const Icon(Icons.favorite_border),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PortfolioEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
      body: Column(
        children: [
          const _CategoryFilter(),
          const SizedBox(height: 4),
          Expanded(child: _ProjectsGrid()),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: Consumer<PortfolioStore>(
        builder: (context, store, _) {
          final favorites = store.favorites;
          if (favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'لا توجد مشاريع مفضلة',
              subtitle: 'اضغط على القلب في أي مشروع لإضافته للمفضلة',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, i) => _ProjectCard(project: favorites[i]),
          );
        },
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PortfolioStore>();
    final categories = <ProjectCategory?>[null, ...ProjectCategory.values];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = categories[i];
          final selected = store.filter == category;
          return ChoiceChip(
            label: Text(category?.label ?? 'الكل'),
            selected: selected,
            onSelected: (_) => store.setFilter(category),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF4B5563),
            ),
            selectedColor: const Color(0xFF0F766E),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF0F766E)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<PortfolioStore>();
    final projects = store.projects;
    if (projects.isEmpty) {
      return const EmptyState(
        icon: Icons.dashboard_customize_outlined,
        title: 'لا توجد مشاريع بعد',
        subtitle: 'ابدأ بإضافة أول مشروع لبورتفوليوك',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.74,
      ),
      itemCount: projects.length,
      itemBuilder: (context, i) => _ProjectCard(project: projects[i]),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PortfolioStore>();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PortfolioDetailScreen(project: project),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProjectImage(
                    imagePath: project.imagePath,
                    seed: project.id,
                    icon: _categoryIcon(project.category),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => store.toggleFavorite(project),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          project.favorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: project.favorite
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.category.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2B31),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${project.location} - ${project.year}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
