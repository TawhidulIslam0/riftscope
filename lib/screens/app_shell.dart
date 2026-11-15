import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'champions_screen.dart';
import 'items_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [HomeScreen(), SearchScreen(), ChampionsScreen(), ItemsScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: pages)),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.person_search_rounded), label: 'Players'),
        NavigationDestination(icon: Icon(Icons.shield_moon_outlined), label: 'Champions'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_mosaic_outlined), label: 'Items'),
      ],
    ),
  );
}
