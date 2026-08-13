import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/client_project.dart';
import '../../state/client_project_store.dart';
import '../../widgets/common.dart';

const _uuid = Uuid();

class ProjectEditScreen extends StatefulWidget {
  const ProjectEditScreen({super.key, this.project});

  final ClientProject? project;

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _clientName;
  late final TextEditingController _phone;
  late final TextEditingController _description;
  late final TextEditingController _address;
  late final TextEditingController _budget;
  late final TextEditingController _startDate;
  late final TextEditingController _deadline;
  late ProjectStatus _status;
  bool _saving = false;

  bool get _isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = TextEditingController(text: p?.title ?? '');
    _clientName = TextEditingController(text: p?.clientName ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _budget = TextEditingController(
      text: p != null && p.budget > 0 ? '${p.budget.round()}' : '',
    );
    final startDate = p?.startDate;
    _startDate = TextEditingController(
      text: startDate != null ? _dateText(startDate) : '',
    );
    final deadline = p?.deadline;
    _deadline = TextEditingController(
      text: deadline != null ? _dateText(deadline) : '',
    );
    _status = p?.status ?? ProjectStatus.inquiry;
  }

  static String _dateText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _title.dispose();
    _clientName.dispose();
    _phone.dispose();
    _description.dispose();
    _address.dispose();
    _budget.dispose();
    _startDate.dispose();
    _deadline.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) controller.text = _dateText(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final store = context.read<ClientProjectStore>();
    final p = widget.project;
    final project = ClientProject(
      id: p?.id ?? _uuid.v4(),
      title: _title.text.trim(),
      clientName: _clientName.text.trim(),
      phone: _phone.text.trim(),
      description: _description.text.trim(),
      address: _address.text.trim(),
      budget: double.tryParse(_budget.text.replaceAll(',', '')) ?? 0,
      status: _status,
      progress: p?.progress ?? 0,
      createdAt: p?.createdAt ?? DateTime.now(),
      startDate: DateTime.tryParse(_startDate.text),
      deadline: DateTime.tryParse(_deadline.text),
      notes: p?.notes ?? const [],
      tasks: p?.tasks ?? const [],
    );
    if (_isEdit) {
      store.update(project);
    } else {
      store.add(project);
    }
    if (!mounted) return;
    showSnack(context, _isEdit ? 'تم تحديث المشروع' : 'تم إضافة المشروع');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل المشروع' : 'مشروع جديد'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _isEdit ? 'حفظ' : 'إضافة',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'عنوان المشروع *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل عنوان المشروع' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _clientName,
                    decoration: const InputDecoration(
                      labelText: 'اسم العميل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'المرحلة الحالية',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ProjectStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الميزانية (ج.م)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startDate,
                    readOnly: true,
                    onTap: () => _pickDate(_startDate),
                    decoration: const InputDecoration(
                      labelText: 'تاريخ البداية',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _deadline,
                    readOnly: true,
                    onTap: () => _pickDate(_deadline),
                    decoration: const InputDecoration(
                      labelText: 'الموعد النهائي',
                      prefixIcon: Icon(Icons.event_available_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المشروع',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
