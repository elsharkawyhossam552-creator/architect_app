import 'package:flutter/material.dart';

import 'portfolio/portfolio_screen.dart';
import 'projects/projects_screen.dart';
import 'social/social_screen.dart';
import 'studio/studio_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    PortfolioScreen(),
    ProjectsScreen(),
    StudioScreen(),
    SocialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: 'البورتفوليو',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'المشاريع',
          ),
          NavigationDestination(
            icon: Icon(Icons.draw_outlined),
            selectedIcon: Icon(Icons.draw),
            label: 'الاستوديو',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'المجتمع',
          ),
        ],
      ),
    );
  }
}
