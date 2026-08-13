import 'package:flutter_test/flutter_test.dart';

import 'package:architect_app/models/architect.dart';
import 'package:architect_app/models/client_project.dart';
import 'package:architect_app/models/portfolio_project.dart';
import 'package:architect_app/models/post.dart';
import 'package:architect_app/models/sketch.dart';
import 'package:architect_app/utils/formats.dart';

void main() {
  group('PortfolioProject', () {
    test('toJson/fromJson roundtrip', () {
      final p = PortfolioProject(
        id: 'p1',
        title: 'فيلا',
        description: 'وصف',
        category: ProjectCategory.villa,
        location: 'القاهرة',
        year: 2025,
        favorite: true,
        createdAt: DateTime(2025, 1, 1),
      );
      final restored = PortfolioProject.fromJson(p.toJson());
      expect(restored.id, 'p1');
      expect(restored.title, 'فيلا');
      expect(restored.category, ProjectCategory.villa);
      expect(restored.favorite, true);
      expect(restored.year, 2025);
      expect(restored.createdAt, DateTime(2025, 1, 1));
    });

    test('category labels are Arabic', () {
      expect(ProjectCategory.villa.label, 'فيلا');
      expect(ProjectCategory.commercial.label, 'تجاري');
    });
  });

  group('ClientProject', () {
    test('toJson/fromJson roundtrip with tasks', () {
      final p = ClientProject(
        id: 'c1',
        title: 'مشروع',
        status: ProjectStatus.execution,
        progress: 50,
        createdAt: DateTime(2025, 2, 2),
        notes: const ['ملاحظة'],
        tasks: const [
          ProjectTask(id: 't1', title: 'مهمة', done: true, priority: 'عالية'),
        ],
      );
      final restored = ClientProject.fromJson(p.toJson());
      expect(restored.status, ProjectStatus.execution);
      expect(restored.tasks, hasLength(1));
      expect(restored.tasks.first.title, 'مهمة');
      expect(restored.tasks.first.done, true);
      expect(restored.doneTasksRatio, 1.0);
    });

    test('status labels', () {
      expect(ProjectStatus.delivered.label, 'تم التسليم');
    });
  });

  group('Post', () {
    test('toJson/fromJson roundtrip with comments', () {
      final post = Post(
        id: 'po1',
        authorId: 'a1',
        text: 'نص',
        likes: const ['x1'],
        comments: [
          Comment(
            id: 'co1',
            authorId: 'a2',
            authorName: 'سارة',
            text: 'رائع',
            createdAt: DateTime(2025, 3, 3),
          ),
        ],
        createdAt: DateTime(2025, 3, 3),
      );
      final restored = Post.fromJson(post.toJson());
      expect(restored.comments, hasLength(1));
      expect(restored.comments.first.authorName, 'سارة');
      expect(restored.likes, contains('x1'));
    });
  });

  group('Architect', () {
    test('current user detection', () {
      const me = Architect(id: 'me', name: 'أنا', specialty: 'م');
      const other = Architect(id: 'a1', name: 'غيري', specialty: 'م');
      expect(me.isCurrent, isTrue);
      expect(other.isCurrent, isFalse);
    });
  });

  group('Sketch', () {
    test('toJson/fromJson roundtrip', () {
      final sketch = Sketch(
        id: 's1',
        name: 'مخطط',
        pixelsPerMeter: 40,
        createdAt: DateTime(2025, 1, 1),
        shapes: const [
          SketchShape(
            type: 'wall',
            a: Offset(0, 0),
            b: Offset(100, 0),
            thickness: 12,
          ),
        ],
      );
      final restored = Sketch.fromJson(sketch.toJson());
      expect(restored.shapes, hasLength(1));
      expect(restored.shapes.first.length, closeTo(100, 0.01));
      expect(restored.pixelsPerMeter, 40);
    });

    test('wall contains point near segment', () {
      const wall = SketchShape(
        type: 'wall',
        a: Offset(0, 0),
        b: Offset(100, 0),
        thickness: 12,
      );
      expect(wall.contains(const Offset(50, 0)), isTrue);
      expect(wall.contains(const Offset(50, 8)), isTrue);
      expect(wall.contains(const Offset(50, 200)), isFalse);
    });

    test('room contains point inside', () {
      const room = SketchShape(
        type: 'room',
        a: Offset(0, 0),
        b: Offset(100, 80),
      );
      expect(room.contains(const Offset(50, 40)), isTrue);
      expect(room.contains(const Offset(200, 200)), isFalse);
    });
  });

  group('formats', () {
    test('timeAgo', () {
      final now = DateTime(2025, 6, 1, 12, 0);
      expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
          'منذ 5 دقيقة');
      expect(timeAgo(now.subtract(const Duration(seconds: 30)), now: now), 'الآن');
      expect(
          timeAgo(now.subtract(const Duration(hours: 3)), now: now), 'منذ 3 ساعة');
    });

    test('formatMoney', () {
      expect(formatMoney(1250000), '1,250,000 ج.م');
      expect(formatMoney(0), '0 ج.م');
    });

    test('formatLength', () {
      expect(formatLength(3.5), '3.50 م');
      expect(formatLength(0.75), '75 سم');
    });
  });
}
