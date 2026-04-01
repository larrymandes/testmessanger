import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'main_screen.dart';
import '../theme/app_theme.dart';

class AccountSelectScreen extends StatelessWidget {
  const AccountSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.lock_shield,
                size: 80,
                color: AppTheme.accentTextColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Secure Messenger',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'E2EE over Email',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.subtitleTextColor,
                ),
              ),
              const SizedBox(height: 48),
              _buildAccountButton(
                context,
                'Аккаунт 1',
                'makcim.evgenevich@bk.ru',
                'OOEviOdB7Yeg5Wa762Jt',
                CupertinoIcons.person,
              ),
              const SizedBox(height: 16),
              _buildAccountButton(
                context,
                'Аккаунт 2',
                'xbox.makcim@bk.ru',
                'ak2DJdvV02aepi1OYLT5',
                CupertinoIcons.person_alt,
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                onPressed: () => _showAddAccountDialog(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, color: AppTheme.accentTextColor),
                    SizedBox(width: 8),
                    Text(
                      'Добавить аккаунт',
                      style: TextStyle(color: AppTheme.accentTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountButton(
    BuildContext context,
    String name,
    String email,
    String password,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.sectionBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => MainScreen(
                email: email,
                password: password,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppTheme.accentTextColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 20,
                color: AppTheme.subtitleTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Добавить аккаунт'),
        content: const Text('Функция в разработке'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
