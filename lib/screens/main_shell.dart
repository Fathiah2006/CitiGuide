import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import 'favourites/favourites_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

/// The signed-in shell — keeps the four primary tabs alive in an IndexedStack
/// beneath a shared bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSearchTap: () => _go(1)),
          const SearchScreen(),
          FavouritesScreen(onBrowse: () => _go(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CgBottomNav(currentIndex: _index, onTap: _go),
    );
  }
}
