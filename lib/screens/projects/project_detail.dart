import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/client_project.dart';
import '../../state/client_project_store.dart';
import '../../utils/formats.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import 'project_edit.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final ClientProject project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _taskController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ClientProjectStore>();
    final project = store.projects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
        actions: [
          IconButton(
            tooltip: 'تعديل',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectEditScreen(project: project),
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
                message: 'هل أنت متأكد من حذف هذا المشروع؟',
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
        padding: const EdgeInsets.all(16),
        children: [
          _Header(project: project),
          const SizedBox(height: 16),
          _ClientCard(project: project),
          const SizedBox(height: 16),
          _StatusCard(project: project),
          const SizedBox(height: 16),
          _ProgressCard(project: project),
          const SizedBox(height: 16),
          _TasksCard(project: project, controller: _taskController),
          const SizedBox(height: 16),
          _NotesCard(project: project, controller: _noteController),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final ClientProject project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2B31),
          ),
        ),
        const SizedBox(height: 8),
        StatusBadge(status: project.status),
        const SizedBox(height: 10),
        if (project.description.isNotEmpty)
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF4B5563),
            ),
          ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.project});

  final ClientProject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بيانات العميل',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _row(context, Icons.person_outline,
                project.clientName.isEmpty ? 'بدون اسم' : project.clientName),
            if (project.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _row(context, Icons.phone_outlined, project.phone,
                  trailing: IconButton(
                    tooltip: 'اتصال',
                    onPressed: () => launchUrl(
                      Uri(scheme: 'tel', path: project.phone),
                    ),
                    icon: const Icon(Icons.call, color: Color(0xFF0F766E)),
                  )),
            ],
            if (project.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              _row(context, Icons.location_on_outlined, project.address),
            ],
            if (project.budget > 0) ...[
              const SizedBox(height: 8),
              _row(context, Icons.payments_outlined, formatMoney(project.budget)),
            ],
            if (project.deadline != null) ...[
              const SizedBox(height: 8),
              _row(
                context,
                Icons.event_outlined,
                'الموعد النهائي: ${project.deadline!.year}/${project.deadline!.month}/${project.deadline!.day}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text,
      {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.project});

  final ClientProject project;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ClientProjectStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مراحل المشروع',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProjectStatus.values.map((status) {
                final selected = project.status == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: StatusBadge.colorOf(status).withValues(alpha: 0.15),
                  side: BorderSide(
                    color: selected
                        ? StatusBadge.colorOf(status)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? StatusBadge.colorOf(status)
                        : const Color(0xFF4B5563),
                  ),
                  onSelected: (_) => store.setStatus(project.id, status),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.project});

  final ClientProject project;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ClientProjectStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'نسبة الإنجاز',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '${project.progress.round()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: project.progress.clamp(0, 100),
              max: 100,
              divisions: 20,
              activeColor: const Color(0xFF0F766E),
              label: '${project.progress.round()}%',
              onChanged: (v) => store.setProgress(project.id, v),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.project, required this.controller});

  final ClientProject project;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ClientProjectStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'قائمة المهام',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (project.tasks.isNotEmpty)
                  Text(
                    '${project.tasks.where((t) => t.done).length}/${project.tasks.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (project.tasks.isEmpty)
              const Text(
                'لا توجد مهام بعد. أضف أول مهمة:',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ...project.tasks.map((task) => _taskTile(store, task)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) {
                      store.addTask(project.id, v);
                      controller.clear();
                    },
                    decoration: const InputDecoration(
                      hintText: 'مهمة جديدة...',
                      isDense: true,
                      prefixIcon: Icon(Icons.add_task, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'إضافة مهمة',
                  onPressed: () {
                    store.addTask(project.id, controller.text);
                    controller.clear();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskTile(ClientProjectStore store, ProjectTask task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => store.removeTask(project.id, task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: CheckboxListTile(
        value: task.done,
        onChanged: (_) => store.toggleTask(project.id, task.id),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14.5,
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? const Color(0xFF9CA3AF) : const Color(0xFF1B2B31),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task.priority,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.project, required this.controller});

  final ClientProject project;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ClientProjectStore>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الملاحظات',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (project.notes.isEmpty)
              const Text(
                'لا توجد ملاحظات.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ...project.notes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(fontSize: 13.5, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) {
                      store.addNote(project.id, v);
                      controller.clear();
                    },
                    decoration: const InputDecoration(
                      hintText: 'أضف ملاحظة...',
                      isDense: true,
                      prefixIcon: Icon(Icons.edit_note, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'إضافة ملاحظة',
                  onPressed: () {
                    store.addNote(project.id, controller.text);
                    controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
