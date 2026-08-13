import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sketch.dart';
import '../../state/studio_store.dart';
import '../../widgets/common.dart';
import 'sketch_painter.dart';
import 'sketches_screen.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  static const _tools = [
    (label: 'تحديد', icon: Icons.pan_tool_alt_outlined),
    (label: 'جدار', icon: Icons.straighten),
    (label: 'غرفة', icon: Icons.crop_square_outlined),
    (label: 'قياس', icon: Icons.square_foot),
  ];

  int _toolIndex = 0;
  bool _showGrid = true;
  double _pixelsPerMeter = 40;
  int _changes = 0;

  final List<SketchShape> _shapes = [];
  final List<SketchShape> _undo = [];
  int? _selectedIndex;
  Offset? _drawStart;
  Offset? _livePoint;
  Offset? _measureStart;
  Offset? _grabOffset;
  Offset? _moveOriginA;
  Offset? _moveOriginB;

  String get _hint => switch (_toolIndex) {
        0 => 'اسحب لنقل العنصر المحدد، واضغط لتحديده',
        1 => 'اسحب على اللوحة لرسم جدار',
        2 => 'اسحب على اللوحة لرسم غرفة',
        _ => 'اضغط على نقطة البداية ثم على نقطة النهاية للقياس',
      };

  void _commit(SketchShape shape) {
    if (shape.length < 4) return;
    _undo.add(shape);
    _shapes.add(shape);
    _changes++;
  }

  void _onPanStart(DragStartDetails details) {
    final p = details.localPosition;
    switch (_toolIndex) {
      case 0:
        _grabOffset = null;
        for (var i = _shapes.length - 1; i >= 0; i--) {
          if (_shapes[i].contains(p)) {
            setState(() {
              _selectedIndex = i;
              _grabOffset = p - _shapes[i].a;
              _moveOriginA = _shapes[i].a;
              _moveOriginB = _shapes[i].b;
            });
            return;
          }
        }
        setState(() => _selectedIndex = null);
        break;
      case 1:
      case 2:
        setState(() {
          _drawStart = p;
          _livePoint = p;
        });
        break;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final p = details.localPosition;
    if (_toolIndex == 0 &&
        _selectedIndex != null &&
        _grabOffset != null &&
        _moveOriginA != null &&
        _moveOriginB != null) {
      final s = _shapes[_selectedIndex!];
      final vector = _moveOriginB! - _moveOriginA!;
      final newA = p - _grabOffset!;
      setState(() {
        _shapes[_selectedIndex!] = SketchShape(
          type: s.type,
          a: newA,
          b: newA + vector,
          thickness: s.thickness,
        );
        _changes++;
      });
    } else if ((_toolIndex == 1 || _toolIndex == 2) && _drawStart != null) {
      setState(() => _livePoint = p);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if ((_toolIndex == 1 || _toolIndex == 2) &&
        _drawStart != null &&
        _livePoint != null) {
      final shape = SketchShape(
        type: _toolIndex == 1 ? 'wall' : 'room',
        a: _drawStart!,
        b: _livePoint!,
        thickness: _toolIndex == 1 ? 12 : 4,
      );
      setState(() {
        _commit(shape);
        _drawStart = null;
        _livePoint = null;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    final p = details.localPosition;
    if (_toolIndex == 3) {
      if (_measureStart == null) {
        setState(() {
          _measureStart = p;
          _changes++;
        });
      } else {
        setState(() {
          _commit(SketchShape(
            type: 'measure',
            a: _measureStart!,
            b: p,
            thickness: 2,
          ));
          _measureStart = null;
        });
      }
    } else if (_toolIndex == 0) {
      setState(() => _selectedIndex = null);
      for (var i = _shapes.length - 1; i >= 0; i--) {
        if (_shapes[i].contains(p)) {
          setState(() => _selectedIndex = i);
          break;
        }
      }
    }
  }

  void _undoLast() {
    if (_undo.isEmpty) return;
    setState(() {
      _shapes.remove(_undo.removeLast());
      _changes++;
    });
  }

  void _deleteSelected() {
    if (_selectedIndex == null) return;
    setState(() {
      final removed = _shapes.removeAt(_selectedIndex!);
      _undo.add(removed);
      _selectedIndex = null;
      _changes++;
    });
  }

  void _clearAll() async {
    final ok = await confirmDialog(
      context,
      title: 'مسح اللوحة',
      message: 'هل تريد مسح كل ما رسمته من اللوحة؟',
    );
    if (ok && mounted) {
      setState(() {
        _undo.addAll(_shapes);
        _shapes.clear();
        _selectedIndex = null;
        _drawStart = null;
        _livePoint = null;
        _measureStart = null;
        _changes++;
      });
    }
  }

  void _loadSketch(Sketch sketch) {
    setState(() {
      _shapes
        ..clear()
        ..addAll(sketch.shapes);
      _pixelsPerMeter = sketch.pixelsPerMeter;
      _undo.clear();
      _selectedIndex = null;
      _drawStart = null;
      _livePoint = null;
      _measureStart = null;
      _changes++;
    });
  }

  Future<void> _saveSketch() async {
    if (_shapes.isEmpty) {
      showSnack(context, 'لا يوجد شيء لرسمه بعد');
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ الاسكتش'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم الاسكتش',
            hintText: 'مثال: مخطط الدور الأول',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final store = context.read<StudioStore>();
    store.add(Sketch(
      id: store.newId(),
      name: name,
      shapes: List.of(_shapes),
      pixelsPerMeter: _pixelsPerMeter,
      createdAt: DateTime.now(),
    ));
    showSnack(context, 'تم حفظ الاسكتش');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستوديو'),
        actions: [
          IconButton(
            tooltip: 'تراجع',
            onPressed: _undo.isEmpty ? null : _undoLast,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'الاسكتشات المحفوظة',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SketchesScreen(onLoad: _loadSketch),
              ),
            ),
            icon: const Icon(Icons.folder_open_outlined),
          ),
          IconButton(
            tooltip: 'حفظ',
            onPressed: _saveSketch,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _toolbar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 15, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _hint,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD1D5DB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTapUp: _onTapUp,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: SketchPainter(
                    shapes: _shapes,
                    showGrid: _showGrid,
                    pixelsPerMeter: _pixelsPerMeter,
                    changes: _changes,
                    selectedIndex: _selectedIndex,
                    drawStart: _drawStart,
                    livePoint: _livePoint,
                    measureStart: _measureStart,
                  ),
                ),
              ),
            ),
          ),
          _bottomBar(context),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<int>(
              segments: _tools
                  .map((t) => ButtonSegment(
                        value: _tools.indexOf(t),
                        icon: Icon(t.icon, size: 19),
                        label: Text(t.label),
                      ))
                  .toList(),
              selected: {_toolIndex},
              onSelectionChanged: (selection) => setState(() {
                _toolIndex = selection.first;
                _measureStart = null;
              }),
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'حذف المحدد',
            onPressed: _selectedIndex == null ? null : _deleteSelected,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            tooltip: 'مسح الكل',
            onPressed: _shapes.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الشبكة',
            onPressed: () => setState(() => _showGrid = !_showGrid),
            icon: Icon(
              _showGrid ? Icons.grid_on : Icons.grid_off,
              color: _showGrid
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المقياس: ${_pixelsPerMeter.round()}px = 1م',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                Slider(
                  value: _pixelsPerMeter,
                  min: 10,
                  max: 120,
                  divisions: 55,
                  onChanged: (v) => setState(() => _pixelsPerMeter = v),
                ),
              ],
            ),
          ),
          Text(
            '${_shapes.length} عنصر',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
