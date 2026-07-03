import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';

class ScannedMessagesScreen extends StatefulWidget {
  const ScannedMessagesScreen({super.key});

  @override
  State<ScannedMessagesScreen> createState() => _ScannedMessagesScreenState();
}

class _ScannedMessagesScreenState extends State<ScannedMessagesScreen> {
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read, color: AppTheme.primaryDarkBlue),
            const SizedBox(width: 8),
            Text(
              'Scanned Messages',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
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
              Text(
                'We\'ve analyzed your latest texts to keep you\nprotected from scams.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              
              // BLOCKED Card
              _buildMessageCard(
                context,
                title: 'Unknown Number',
                time: '10:42 AM',
                tag: 'BLOCKED',
                tagColor: Colors.red[700]!,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.red[700]!,
                iconBgColor: Colors.red[50]!,
                borderColor: Colors.grey.withValues(alpha: 0.3),
                content: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"Your bank account has been suspended. Click here to verify your identity immediately: bit.ly/bank-alert-32..."',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                actions: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.report_problem_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Report Scam', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // SUSPECT Card
              _buildMessageCard(
                context,
                title: 'Amazon Support?',
                time: 'Yesterday',
                tag: 'SUSPECT',
                tagColor: Colors.orange[800]!,
                icon: Icons.help_outline,
                iconColor: Colors.orange[800]!,
                iconBgColor: Colors.orange[50]!,
                borderColor: Colors.grey.withValues(alpha: 0.3),
                leftBorderColor: Colors.brown[900], // Thick left border from design
                content: Text(
                  '"A large purchase of \$1,200 was made on your account. If this wasn\'t you, call..."',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                actions: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDarkBlue,
                      side: const BorderSide(color: AppTheme.primaryDarkBlue, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Verify Sender', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // SAFE Card 1
              _buildMessageCard(
                context,
                title: 'Sarah (Granddaughter)',
                time: 'Monday',
                tag: 'SAFE',
                tagColor: AppTheme.primaryDarkBlue,
                icon: Icons.verified_user_outlined,
                iconColor: AppTheme.primaryDarkBlue,
                iconBgColor: AppTheme.primaryLightBlue.withValues(alpha: 0.3),
                borderColor: Colors.grey.withValues(alpha: 0.3),
                content: Text(
                  '"Hi Grandpa! Just checking in to see if you\'re free for dinner this Sunday? Love you!"',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // SAFE Card 2
              _buildMessageCard(
                context,
                title: 'Pharmacy Plus',
                time: 'Oct 12',
                tag: 'SAFE',
                tagColor: AppTheme.primaryDarkBlue,
                icon: Icons.verified_user_outlined,
                iconColor: AppTheme.primaryDarkBlue,
                iconBgColor: AppTheme.primaryLightBlue.withValues(alpha: 0.3),
                borderColor: Colors.grey.withValues(alpha: 0.3),
                content: Text(
                  '"Your prescription is ready for pickup. Please visit the store before 9 PM tonight."',
                  style: Theme.of(context).textTheme.bodyLarge,
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

  Widget _buildMessageCard(
    BuildContext context, {
    required String title,
    required String time,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color borderColor,
    Color? leftBorderColor,
    required Widget content,
    Widget? actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leftBorderColor != null)
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: leftBorderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: tagColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    content,
                    if (actions != null) ...[
                      const SizedBox(height: 20),
                      actions,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
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
