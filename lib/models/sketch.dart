import 'dart:ui';

class SketchShape {
  final String type;
  final Offset a;
  final Offset b;
  final double thickness;

  const SketchShape({
    required this.type,
    required this.a,
    required this.b,
    this.thickness = 12,
  });

  Rect get rect => Rect.fromPoints(a, b);

  double get length => (b - a).distance;

  Offset get direction {
    final d = b - a;
    return d.distance == 0 ? const Offset(1, 0) : d / d.distance;
  }

  Offset get midPoint => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  SketchShape moveBy(Offset delta) =>
      SketchShape(type: type, a: a + delta, b: b + delta, thickness: thickness);

  Map<String, dynamic> toJson() => {
        'type': type,
        'ax': a.dx,
        'ay': a.dy,
        'bx': b.dx,
        'by': b.dy,
        'thickness': thickness,
      };

  factory SketchShape.fromJson(Map<String, dynamic> j) => SketchShape(
        type: j['type'] as String,
        a: Offset((j['ax'] as num).toDouble(), (j['ay'] as num).toDouble()),
        b: Offset((j['bx'] as num).toDouble(), (j['by'] as num).toDouble()),
        thickness: (j['thickness'] as num?)?.toDouble() ?? 12,
      );

  bool contains(Offset p, {double tolerance = 10}) {
    if (type == 'room') {
      return rect.inflate(6).contains(p);
    }
    final t = _projectFactor(p, a, b);
    final proj = a + (b - a) * t;
    return (proj - p).distance <= thickness / 2 + tolerance;
  }

  static double _projectFactor(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return 0;
    return ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2;
  }
}

class Sketch {
  final String id;
  final String name;
  final List<SketchShape> shapes;
  final double pixelsPerMeter;
  final DateTime createdAt;

  const Sketch({
    required this.id,
    required this.name,
    required this.shapes,
    required this.pixelsPerMeter,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pixelsPerMeter': pixelsPerMeter,
        'createdAt': createdAt.toIso8601String(),
        'shapes': shapes.map((s) => s.toJson()).toList(),
      };

  factory Sketch.fromJson(Map<String, dynamic> json) => Sketch(
        id: json['id'] as String,
        name: json['name'] as String,
        pixelsPerMeter: (json['pixelsPerMeter'] as num?)?.toDouble() ?? 40,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        shapes: (json['shapes'] as List? ?? const [])
            .map((s) => SketchShape.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );
}
