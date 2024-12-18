import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'add/add_screen.dart';
import 'calendar/calendar_screen.dart';
import 'profile/profile_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final String title;
  final AuthService authService;

  const MainScreen({
    super.key,
    required this.title,
    required this.authService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomeScreen(title: widget.title, authService: widget.authService),
      const SearchScreen(),
      const AddScreen(),
      const CalendarScreen(),
      ProfileScreen(authService: widget.authService),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add_circled),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
