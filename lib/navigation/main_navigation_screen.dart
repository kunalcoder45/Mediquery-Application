import 'package:flutter/material.dart';
import '../widgets/navigation_dock.dart';
import '../screens/dashboard_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Define your screens here
  final List<Widget> _screens = [
    const DashboardScreen(), // Home
    const AboutScreen(),     // About
    const ContactScreen(),   // Contact
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _screens[_currentIndex],
          
          // Floating dock at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: NavigationDock(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}