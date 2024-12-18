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
  final _homeKey = GlobalKey<HomeScreenState>();
  bool _wasOnHomeTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            key: _homeKey,
            title: widget.title,
            authService: widget.authService,
          ),
          const SearchScreen(),
          const AddScreen(),
          const CalendarScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            if (index == 0) {
              if (_selectedIndex == 0 || !_wasOnHomeTab) {
                _homeKey.currentState?.refreshTasks();
              }
            }
            _selectedIndex = index;
            _wasOnHomeTab = (index == 0);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.add_circled),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
