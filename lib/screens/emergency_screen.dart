import 'package:flutter/material.dart';
import '../theme.dart';
import 'warning_alert_screen.dart';
import 'guardian_screen.dart';
import 'home_screen.dart';
import 'security_status_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _selectedIndex = 0; // Keeping Home selected to match the mockup

  void _onItemTapped(int index) {
    if (index == 0) { // Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (index == 1) { // Security
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SecurityStatusScreen()));
    } else if (index == 2) { // Support
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
    } else if (index == 3) { // Settings
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.textDark),
          onPressed: () {},
        ),
        title: Text(
          'Safe Senior',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safe Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryDarkBlue.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppTheme.primaryDarkBlue, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You are Safe',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDarkBlue,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Scanning for scammers...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textDark.withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryDarkBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Tip of the Day Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 60,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip of the Day',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDarkBlue,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Never share your password or banking PIN with someone who calls you, even if they say they're from your bank.",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textDark,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Help Button
              GestureDetector(
                onLongPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WarningAlertScreen()));
                },
                child: Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorRed.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text(
                          'HELP ME!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Press and hold if you are in immediate\ndanger or need medical help.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
              ),
              
              const Spacer(),
              
              // Guardian Contact Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianScreen()));
                },
                icon: const Icon(Icons.contact_mail_outlined),
                label: const Text('My Guardian Contact'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppTheme.primaryDarkBlue,
                  backgroundColor: AppTheme.primaryLightBlue.withValues(alpha: 0.1),
                  side: BorderSide(color: AppTheme.primaryDarkBlue.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryDarkBlue,
        unselectedItemColor: AppTheme.textDark.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedIndex == 0 ? AppTheme.primaryLightBlue.withValues(alpha: 0.5) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_outlined),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.security),
            ),
            label: 'Security',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.help_outline),
            ),
            label: 'Support',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.settings_outlined),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
