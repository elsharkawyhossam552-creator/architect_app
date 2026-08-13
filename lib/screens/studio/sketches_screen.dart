import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sketch.dart';
import '../../state/studio_store.dart';
import '../../utils/formats.dart';
import '../../widgets/common.dart';

class SketchesScreen extends StatelessWidget {
  const SketchesScreen({super.key, required this.onLoad});

  final void Function(Sketch sketch) onLoad;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StudioStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('الاسكتشات المحفوظة')),
      body: store.sketches.isEmpty
          ? const EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'لا توجد اسكتشات محفوظة',
              subtitle: 'ارسم مخططاً في الاستوديو ثم احفظه',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: store.sketches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final sketch = store.sketches[i];
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0x140F766E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.architecture,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    title: Text(
                      sketch.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${sketch.shapes.length} عنصر - ${timeAgo(sketch.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'فتح',
                          onPressed: () {
                            onLoad(sketch);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                  content: Text('تم فتح "${sketch.name}"'),
                                ));
                          },
                          icon: const Icon(
                            Icons.open_in_new,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () async {
                            final ok = await confirmDialog(
                              context,
                              title: 'حذف الاسكتش',
                              message: 'حذف "${sketch.name}" نهائياً؟',
                            );
                            if (ok && context.mounted) {
                              store.remove(sketch.id);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
