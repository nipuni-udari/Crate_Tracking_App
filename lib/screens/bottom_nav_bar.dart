import 'package:crate_tracking/screens/crates/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking/user_provider.dart';
import 'package:crate_tracking/screens/crates/crate_screen.dart';
import 'package:crate_tracking/screens/home/home_screen.dart';
import 'package:crate_tracking/screens/profile/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mobileNumber = userProvider.mobileNumber;

    if (index == currentIndex) return; // Prevents reloading the same page

    Widget screen;
    switch (index) {
      case 0:
        screen = HomeScreen(mobileNumber: mobileNumber);
        break;
      case 1:
        screen = CrateScreen();
        break;
      case 2:
        screen = SummaryScreen();
        break;
      case 3:
        screen = ProfileScreen(mobileNumber: mobileNumber);
        break;

      default:
        return;
    }

    // Using PageRouteBuilder for custom fade transition animation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define fade transition
          var opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

          return FadeTransition(opacity: opacityAnimation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: 600,
        ), // Set duration for smoothness
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: const Color.fromARGB(255, 249, 120, 45), // Light blue
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(255, 112, 112, 112),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, size: 30),
          label: 'Crate Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, size: 30),
          label: 'Loading summary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: 'Profile',
        ),
      ],
      showUnselectedLabels: true,
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
