import 'package:flutter/material.dart';
import '../theme.dart';
import 'warning_alert_screen.dart';
import 'guardian_screen.dart';
import 'security_status_screen.dart';
import 'daily_safety_tips_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) { // Security
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
          style: Theme.of(context).textTheme.headlineMedium,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Safe at Home Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryLightBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home, color: AppTheme.primaryDarkBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Safe at Home',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search protection tips...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 16),
              
              // Active Protection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.green, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Protection',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                              ),
                              Text(
                                'All systems monitoring',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security, color: AppTheme.primaryDarkBlue, size: 20),
                            const SizedBox(width: 8),
                            Text('24/7 Protection', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cloud_off, color: AppTheme.primaryDarkBlue, size: 20),
                            const SizedBox(width: 8),
                            Text('Offline Mode', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Grid
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Emergency',
                      icon: Icons.emergency,
                      color: AppTheme.errorRed,
                      backgroundColor: AppTheme.errorRed.withValues(alpha: 0.15),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Guardian',
                      icon: Icons.family_restroom,
                      color: AppTheme.primaryDarkBlue,
                      backgroundColor: AppTheme.primaryLightBlue.withValues(alpha: 0.6),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Safety Tips',
                      icon: Icons.lightbulb_outline,
                      color: AppTheme.textDark,
                      backgroundColor: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySafetyTipsScreen())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      color: AppTheme.textDark,
                      backgroundColor: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildActivityItem(
                      context,
                      title: '12 Scams Blocked',
                      subtitle: 'This week',
                      icon: Icons.gpp_bad_outlined,
                    ),
                    Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                    _buildActivityItem(
                      context,
                      title: '5 Calls Protected',
                      subtitle: 'This week',
                      icon: Icons.phone_disabled_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Today's Safety Tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDarkBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppTheme.primaryLightBlue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Safety Tip",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryLightBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Banks never ask for\nOTP over phone',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required Color backgroundColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryDarkBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
              ),
            ],
          ),
        ],
      ),
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

