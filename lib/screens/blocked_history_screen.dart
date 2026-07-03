import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';

class BlockedHistoryScreen extends StatefulWidget {
  const BlockedHistoryScreen({super.key});

  @override
  State<BlockedHistoryScreen> createState() => _BlockedHistoryScreenState();
}

class _BlockedHistoryScreenState extends State<BlockedHistoryScreen> {
  int _selectedIndex = 1; // Security selected

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
          'Blocked History',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Blocked Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryDarkBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Blocked',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                          ),
                          Text(
                            '12',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  height: 1.2,
                                ),
                          ),
                          Text(
                            'Scam messages intercepted this month.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Intercepted Threats Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INTERCEPTED THREATS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppTheme.primaryDarkBlue,
                        ),
                  ),
                  Text(
                    'Recent First',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textDark.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Threat List
              _buildThreatCard(
                context,
                time: 'Today, 10:42 AM',
                title: 'Unknown Number (+1 555-0192)',
                message: '"Your account has been suspended. Click here to verify your identity: http://scam-..."',
              ),
              const SizedBox(height: 12),
              _buildThreatCard(
                context,
                time: 'Yesterday, 4:15 PM',
                title: 'Potential Fraud (International)',
                message: '"IRS Alert: You have an unclaimed refund of \$2,400. Reply DEPOSIT to claim your..."',
              ),
              const SizedBox(height: 12),
              _buildThreatCard(
                context,
                time: 'Yesterday, 9:20 AM',
                title: 'Spam (Package Delivery)',
                message: '"USPS: Your package is on hold due to a missing house number. Please update..."',
              ),
              const SizedBox(height: 12),
              _buildThreatCard(
                context,
                time: 'Oct 24, 2:50 PM',
                title: 'Unknown Number',
                message: '"Grandson needs help. Please send \$500 via wire transfer to bail him out. Extremel..."',
              ),
              const SizedBox(height: 12),
              _buildThreatCard(
                context,
                time: 'Oct 22, 11:05 AM',
                title: 'Tech Support Scam',
                message: '"Microsoft Security: Your computer has been infected with a trojan virus. Call 1-..."',
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Safe Senior automatically deletes blocked messages after 30 days to protect your privacy.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildThreatCard(BuildContext context, {required String time, required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BLOCKED',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDark.withValues(alpha: 0.8),
                ),
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
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.shield_outlined),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedIndex == 1 ? AppTheme.primaryLightBlue.withValues(alpha: 0.5) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.security),
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
