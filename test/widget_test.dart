import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:architect_app/app.dart';
import 'package:architect_app/models/portfolio_project.dart';
import 'package:architect_app/screens/portfolio/portfolio_screen.dart';
import 'package:architect_app/screens/home_shell.dart';
import 'package:architect_app/state/client_project_store.dart';
import 'package:architect_app/state/portfolio_store.dart';
import 'package:architect_app/state/social_store.dart';
import 'package:architect_app/state/studio_store.dart';

void main() {
  Widget wrapApp(Widget child, {PortfolioStore? portfolio}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: portfolio ?? PortfolioStore(),
        ),
        ChangeNotifierProvider(create: (_) => ClientProjectStore()),
        ChangeNotifierProvider(create: (_) => SocialStore()),
        ChangeNotifierProvider(create: (_) => StudioStore()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  testWidgets('app shell renders four tabs', (tester) async {
    await tester.pumpWidget(const ArchApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('البورتفوليو'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('المشاريع'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('الاستوديو'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('المجتمع'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('portfolio shows empty state without data', (tester) async {
    await tester.pumpWidget(wrapApp(const PortfolioScreen()));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد مشاريع بعد'), findsOneWidget);
  });

  testWidgets('portfolio grid renders project titles', (tester) async {
    final store = PortfolioStore();
    store.add(PortfolioProject(
      id: 'x1',
      title: 'فيلا التجربة',
      category: ProjectCategory.villa,
      createdAt: DateTime(2025, 1, 1),
    ));
    store.add(PortfolioProject(
      id: 'x2',
      title: 'شقة الاختبار',
      category: ProjectCategory.apartment,
      createdAt: DateTime(2025, 1, 2),
    ));

    await tester.pumpWidget(wrapApp(const PortfolioScreen(), portfolio: store));
    await tester.pump();
    expect(find.text('فيلا التجربة'), findsOneWidget);
    expect(find.text('شقة الاختبار'), findsOneWidget);
  });

  testWidgets('tapping a tab switches screens', (tester) async {
    await tester.pumpWidget(wrapApp(const HomeShell()));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('المجتمع'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('المنشورات'), findsOneWidget);
  });
}
