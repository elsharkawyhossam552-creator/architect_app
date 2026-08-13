import 'package:uuid/uuid.dart';

import '../models/architect.dart';
import '../models/client_project.dart';
import '../models/portfolio_project.dart';
import '../models/post.dart';
import 'hive_boxes.dart';

const _uuid = Uuid();

class SeedData {
  SeedData._();

  static const _seedKey = 'seeded_v1';

  static Future<void> ensureSeeded() async {
    if (!HiveBoxes.ready) return;
    final meta = HiveBoxes.meta;
    if (meta.get(_seedKey) == true) return;

    final now = DateTime.now();

    // ----- Architects -----
    final architects = <Architect>[
      const Architect(
        id: 'me',
        name: 'أحمد ياسر',
        specialty: 'مهندس معماري',
        bio: 'أحب تحويل الأفكار إلى مساحات حقيقية. خبرة 8 سنوات في التصميم السكني والتجاري.',
        location: 'القاهرة',
        avatarColor: 0xFF0F766E,
        verified: true,
      ),
      const Architect(
        id: 'a1',
        name: 'سارة محمود',
        specialty: 'مصممة داخلية',
        bio: 'متخصصة في التصميم الداخلي والفراغات الصغيرة.',
        location: 'الإسكندرية',
        avatarColor: 0xFF7C3AED,
        verified: true,
        followers: ['x1', 'x2', 'me'],
      ),
      const Architect(
        id: 'a2',
        name: 'محمد عبدالله',
        specialty: 'مهندس إنشائي',
        bio: 'تصميم إنشائي وترميم المباني التاريخية.',
        location: 'جدة',
        avatarColor: 0xFF2563EB,
        followers: ['x1'],
      ),
      const Architect(
        id: 'a3',
        name: 'نورا حسن',
        specialty: 'مخطط عمراني',
        bio: 'تخطيط عمراني وتصميم فراغات عامة مستدامة.',
        location: 'دبي',
        avatarColor: 0xFFD97706,
        verified: true,
        followers: ['x1', 'x2'],
      ),
    ];
    for (final a in architects) {
      await HiveBoxes.architects.put(a.id, a.toJson());
    }

    // ----- Portfolio projects -----
    final portfolio = <PortfolioProject>[
      PortfolioProject(
        id: _uuid.v4(),
        title: 'فيلا الأمل الساحلية',
        description: 'فيلا من طابقين على الواجهة البحرية بتصميم عصري يدمج الخرسانة المكشوفة مع الزجاج والخشب، مع حديقة داخلية وإضاءة طبيعية مثالية.',
        category: ProjectCategory.villa,
        location: 'العين السخنة',
        year: 2025,
        favorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PortfolioProject(
        id: _uuid.v4(),
        title: 'شقة اللؤلؤة',
        description: 'إعادة تصميم شقة سكنية 180م بأسلوب بوهيمي أنيق مع مواد طبيعية وفتحات واسعة.',
        category: ProjectCategory.apartment,
        location: 'القاهرة الجديدة',
        year: 2025,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      PortfolioProject(
        id: _uuid.v4(),
        title: 'مقر شركة اوريدو',
        description: 'تصميم مكتبي عصري لمساحة 600م بواجهات زجاجية وقاعات اجتماعات مرنة.',
        category: ProjectCategory.office,
        location: 'الدقي',
        year: 2024,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      PortfolioProject(
        id: _uuid.v4(),
        title: 'معرض الزهراء التجاري',
        description: 'واجهة ومساحة عرض تجارية بتصميم يجذب الزائر ويسهل الحركة الداخلية.',
        category: ProjectCategory.commercial,
        location: 'شبرا الخيمة',
        year: 2024,
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      PortfolioProject(
        id: _uuid.v4(),
        title: 'فيلا الربع الخالي',
        description: 'منزل صحراوي مصمم للتكيف مع المناخ الحار بجدران سميكة وساحات داخلية.',
        category: ProjectCategory.villa,
        location: 'الرياض',
        year: 2023,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      PortfolioProject(
        id: _uuid.v4(),
        title: 'شقة البلكونة الخضراء',
        description: 'شقة 120م مع بلكونة موسعة مدمجة بالمساحات الخضراء، بتصميم وسطاء حديث.',
        category: ProjectCategory.apartment,
        location: 'الإسكندرية',
        year: 2023,
        favorite: true,
        createdAt: now.subtract(const Duration(days: 33)),
      ),
    ];
    for (final p in portfolio) {
      await HiveBoxes.portfolio.put(p.id, p.toJson());
    }

    // ----- Client projects -----
    final tasks1 = [
      const ProjectTask(id: 't1', title: 'استلام الموقع والمساحة', done: true, priority: 'عالية'),
      const ProjectTask(id: 't2', title: 'المخططات الأولية', done: true, priority: 'عالية'),
      const ProjectTask(id: 't3', title: 'اعتماد التشطيبات مع العميل', done: false, priority: 'متوسطة'),
      const ProjectTask(id: 't4', title: 'الرسومات التنفيذية', done: false, priority: 'عالية'),
    ];
    final tasks2 = [
      const ProjectTask(id: 't5', title: 'اجتماع بداية المشروع', done: true, priority: 'عالية'),
      const ProjectTask(id: 't6', title: 'تفصيل جداول الأبواب والشبابيك', done: false, priority: 'متوسطة'),
      const ProjectTask(id: 't7', title: 'التشطيب النهائي للواجهة', done: false, priority: 'منخفضة'),
    ];
    final projects = <ClientProject>[
      ClientProject(
        id: _uuid.v4(),
        title: 'عمارة سكنية - المعادي',
        clientName: 'م. خالد السيد',
        phone: '01001234567',
        description: 'عمارة سكنية من 6 طوابق بمساحة 900م مع جراج وواجهة حديثة.',
        address: 'شارع 9، المعادي، القاهرة',
        budget: 4200000,
        status: ProjectStatus.execution,
        progress: 65,
        createdAt: now.subtract(const Duration(days: 40)),
        startDate: now.subtract(const Duration(days: 30)),
        deadline: now.add(const Duration(days: 90)),
        notes: ['العميل يفضل ألوان فاتحة للواجهة', 'تم الاتفاق على تعديل غرفة النوم الرئيسية'],
        tasks: tasks1,
      ),
      ClientProject(
        id: _uuid.v4(),
        title: 'تجهيز شقة تمليك',
        clientName: 'أ. منى عادل',
        phone: '01112345678',
        description: 'تجهيز شقة 140م بتشطيبات سوبر لوكس لتسليمها كامل التشطيب.',
        address: 'مدينتي - القاهرة الجديدة',
        budget: 1800000,
        status: ProjectStatus.approved,
        progress: 25,
        createdAt: now.subtract(const Duration(days: 15)),
        startDate: now.subtract(const Duration(days: 10)),
        deadline: now.add(const Duration(days: 120)),
        notes: ['العميل طلب غرفة طعام بأرضية رخام'],
        tasks: tasks2,
      ),
      ClientProject(
        id: _uuid.v4(),
        title: 'تصميم واجهة عيادة',
        clientName: 'د. هالة فؤاد',
        phone: '01098765432',
        description: 'تصميم داخلي وخارجي لعيادة أسنان 80م.',
        address: 'التجمع الخامس',
        budget: 650000,
        status: ProjectStatus.initial,
        progress: 10,
        createdAt: now.subtract(const Duration(days: 4)),
        tasks: const [],
      ),
      ClientProject(
        id: _uuid.v4(),
        title: 'فيلا عائلية - 6 أكتوبر',
        clientName: 'م. محمد شاكر',
        phone: '01234567890',
        description: 'فيلا دورين بمساحة 350م مع حديقة وبركة سباحة صغيرة.',
        address: 'الحي السادس، 6 أكتوبر',
        budget: 9000000,
        status: ProjectStatus.inquiry,
        progress: 0,
        createdAt: now.subtract(const Duration(days: 1)),
        tasks: const [],
      ),
    ];
    for (final p in projects) {
      await HiveBoxes.clientProjects.put(p.id, p.toJson());
    }

    // ----- Posts -----
    final posts = <Post>[
      Post(
        id: _uuid.v4(),
        authorId: 'me',
        text: 'انتهيت من تسليم مشروع فيلا الأمل الساحلية. فخور جدا بالفريق والنتيجة النهائية!',
        likes: ['x1', 'x2'],
        comments: [
          Comment(
            id: _uuid.v4(),
            authorId: 'a1',
            authorName: 'سارة محمود',
            text: 'مبروك! اللمسات النهائية جميلة جدا.',
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: _uuid.v4(),
        authorId: 'a1',
        text: 'نصيحة لأي حد بيشتغل في التصميم الداخلي: الإضاءة هي نصف التصميم. استثمروا في دراسة الإضاءة من البداية.',
        likes: ['me', 'x1', 'x2'],
        comments: [
          Comment(
            id: _uuid.v4(),
            authorId: 'a2',
            authorName: 'محمد عبدالله',
            text: 'كلام سليم 100%',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 9)),
      ),
      Post(
        id: _uuid.v4(),
        authorId: 'a3',
        text: 'مشاركة تجربة في التخطيط العمراني لمشروع سكني جديد في دبي...',
        likes: ['me'],
        comments: const [],
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
    ];
    for (final p in posts) {
      await HiveBoxes.posts.put(p.id, p.toJson());
    }

    await meta.put(_seedKey, true);
  }
}
