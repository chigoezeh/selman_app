import 'package:flutter/material.dart';
import 'package:selman/main.dart'; // We need to import main.dart to get ContentListScreen
import 'package:selman/screens/library_screen.dart';
import 'package:selman/screens/search_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0; // The index of the currently selected tab

  // The list of screens to navigate between
  static const List<Widget> _widgetOptions = <Widget>[
    ContentListScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Theming for the navigation bar
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
