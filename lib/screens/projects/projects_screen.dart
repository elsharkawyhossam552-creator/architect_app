import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/client_project.dart';
import '../../state/client_project_store.dart';
import '../../utils/formats.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import 'project_detail.dart';
import 'project_edit.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مشاريع العملاء')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد'),
      ),
      body: Consumer<ClientProjectStore>(
        builder: (context, store, _) {
          final projects = store.projects;
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'لا توجد مشاريع عملاء',
              subtitle: 'ابدأ بإضافة أول مشروع لمتابعته',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _ProjectTile(project: projects[i]),
          );
        },
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});

  final ClientProject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(project: project),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2B31),
                      ),
                    ),
                  ),
                  StatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.clientName.isEmpty ? 'بدون اسم' : project.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  if (project.budget > 0)
                    Text(
                      formatMoney(project.budget),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress / 100,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF0F766E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${project.progress.round()}%',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563),
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
}
