import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/scanned_message.dart';
import '../state/scanned_messages_provider.dart';
import 'otp_alert_screen.dart';
import 'home_screen.dart';

class ScannedMessagesScreen extends ConsumerStatefulWidget {
  const ScannedMessagesScreen({super.key});

  @override
  ConsumerState<ScannedMessagesScreen> createState() => _ScannedMessagesScreenState();
}

class _ScannedMessagesScreenState extends ConsumerState<ScannedMessagesScreen> {
  int _selectedIndex = 1;

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
              ...ref.watch(scannedMessagesProvider).map((msg) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMessageCardForMsg(context, msg),
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMessageCardForMsg(BuildContext context, ScannedMessage msg) {
    final isDanger = msg.riskLevelIndex == 2;
    final isCaution = msg.riskLevelIndex == 1;
    final String tag = isDanger ? 'BLOCKED' : isCaution ? 'SUSPECT' : 'SAFE';
    final Color tagColor = isDanger
        ? Colors.red[700]!
        : isCaution
            ? Colors.orange[800]!
            : AppTheme.primaryDarkBlue;
    final IconData icon = isDanger
        ? Icons.warning_amber_rounded
        : isCaution
            ? Icons.help_outline
            : Icons.verified_user_outlined;
    final Color iconColor = isDanger
        ? Colors.red[700]!
        : isCaution
            ? Colors.orange[800]!
            : AppTheme.primaryDarkBlue;
    final Color iconBgColor = isDanger
        ? Colors.red[50]!
        : isCaution
            ? Colors.orange[50]!
            : AppTheme.primaryLightBlue.withValues(alpha: 0.3);
    final Color? leftBorder = isCaution ? Colors.brown[900] : null;

    Widget? actionBtn;
    if (isDanger) {
      actionBtn = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ref.read(scannedMessagesProvider.notifier).markReported(msg);
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => OtpAlertScreen(message: msg),
            ));
          },
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
      );
    } else if (isCaution) {
      actionBtn = SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => OtpAlertScreen(message: msg),
            ));
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryDarkBlue,
            side: const BorderSide(color: AppTheme.primaryDarkBlue, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Verify Sender', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    return _buildMessageCard(
      context,
      title: msg.sender,
      time: _formatTime(msg.receivedAt),
      tag: tag,
      tagColor: tagColor,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      borderColor: Colors.grey.withValues(alpha: 0.3),
      leftBorderColor: leftBorder,
      content: Text(msg.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: isDanger ? FontStyle.italic : null)),
      actions: actionBtn,
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} AM';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
    return '${dt.month}/${dt.day}';
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
