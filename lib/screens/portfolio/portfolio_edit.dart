import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/portfolio_project.dart';
import '../../state/portfolio_store.dart';
import '../../widgets/common.dart';
import '../../widgets/project_image.dart';

const _uuid = Uuid();

class PortfolioEditScreen extends StatefulWidget {
  const PortfolioEditScreen({super.key, this.project});

  final PortfolioProject? project;

  @override
  State<PortfolioEditScreen> createState() => _PortfolioEditScreenState();
}

class _PortfolioEditScreenState extends State<PortfolioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _year;
  late ProjectCategory _category;
  String? _imagePath;
  bool _saving = false;

  bool get _isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _location = TextEditingController(text: p?.location ?? '');
    _year = TextEditingController(text: p != null ? '${p.year}' : '${DateTime.now().year}');
    _category = p?.category ?? ProjectCategory.other;
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final store = context.read<PortfolioStore>();
    final year = int.tryParse(_year.text.trim()) ?? DateTime.now().year;
    final base = PortfolioProject(
      id: widget.project?.id ?? _uuid.v4(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      location: _location.text.trim(),
      year: year,
      imagePath: _imagePath,
      favorite: widget.project?.favorite ?? false,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
    );
    if (_isEdit) {
      store.update(base);
    } else {
      store.add(base);
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
            _imagePicker(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'اسم المشروع *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل اسم المشروع' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProjectCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ProjectCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _location,
                    decoration: const InputDecoration(
                      labelText: 'الموقع',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السنة',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'مطلوب';
                      if (int.tryParse(v.trim()) == null) return 'رقم فقط';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف المشروع',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.notes),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProjectImage(
                imagePath: _imagePath,
                seed: 'edit-${_imagePath ?? _title.hashCode}',
                icon: Icons.add_a_photo_outlined,
              ),
              if (_imagePath != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _imagePath = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              if (_imagePath == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'إضافة صورة من المعرض',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
