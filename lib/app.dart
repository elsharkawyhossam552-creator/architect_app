import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'state/client_project_store.dart';
import 'state/portfolio_store.dart';
import 'state/social_store.dart';
import 'state/studio_store.dart';
import 'theme/app_theme.dart';

class ArchApp extends StatelessWidget {
  const ArchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioStore()..load()),
        ChangeNotifierProvider(create: (_) => ClientProjectStore()..load()),
        ChangeNotifierProvider(create: (_) => SocialStore()..load()),
        ChangeNotifierProvider(create: (_) => StudioStore()..load()),
      ],
      child: MaterialApp(
        title: 'معمار',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}
