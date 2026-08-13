import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../state/social_store.dart';
import '../../widgets/avatar.dart';
import '../../widgets/common.dart';
import '../../widgets/project_image.dart';

class PostEditorScreen extends StatefulWidget {
  const PostEditorScreen({super.key});

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final _controller = TextEditingController();
  String? _imagePath;
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
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

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _imagePath == null) {
      showSnack(context, 'اكتب شيئاً أو أضف صورة أولاً');
      return;
    }
    setState(() => _posting = true);
    context.read<SocialStore>().addPost(text, imagePath: _imagePath);
    if (!mounted) return;
    showSnack(context, 'تم نشر المنشور');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SocialStore>();
    final me = store.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('منشور جديد'),
        actions: [
          TextButton(
            onPressed: _posting ? null : _post,
            child: const Text(
              'نشر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              if (me != null) Avatar(architect: me, radius: 22),
              const SizedBox(width: 10),
              Text(
                me?.name ?? 'أنا',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'شارك فكرتك، مشروعك، أو تجربتك مع المجتمع...',
              alignLabelWithHint: true,
              filled: false,
            ),
          ),
          const SizedBox(height: 16),
          if (_imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProjectImage(
                      imagePath: _imagePath,
                      seed: 'editor',
                      icon: Icons.image_outlined,
                    ),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(_imagePath == null ? 'إضافة صورة' : 'تغيير الصورة'),
          ),
        ],
      ),
    );
  }
}
