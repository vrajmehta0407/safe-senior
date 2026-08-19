import 'package:flutter/material.dart';
import '../theme.dart';
import '../screens/home_screen.dart';
import '../screens/security_status_screen.dart';
import '../screens/guardian_contacts_screen.dart';
import '../screens/settings_screen.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const SecurityStatusScreen();
        break;
      case 2:
        page = const GuardianContactsScreen();
        break;
      case 3:
        page = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, 0, Icons.home_outlined, Icons.home),
            _navItem(context, 1, Icons.shield_outlined, Icons.shield),
            _navItem(context, 2, Icons.people_outline, Icons.people),
            _navItem(context, 3, Icons.settings_outlined, Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData outlineIcon, IconData filledIcon) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryTeal : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? filledIcon : outlineIcon,
          size: 22,
          color: isActive ? Colors.white : const Color(0xFF50605D),
        ),
      ),
    );
  }
}
