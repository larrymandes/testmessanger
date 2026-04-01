import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';
import 'main_screen.dart';

class AccountSelectScreen extends StatelessWidget {
  const AccountSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = TelegramTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                size: 80,
                color: theme.colors.accentTextColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Secure Messenger',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'E2EE over Email',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colors.subtitleTextColor,
                ),
              ),
              const SizedBox(height: 48),
              _buildAccountButton(
                context,
                theme,
                'Аккаунт 1',
                'makcim.evgenevich@bk.ru',
                'OOEviOdB7Yeg5Wa762Jt',
                CupertinoIcons.person,
              ),
              const SizedBox(height: 16),
              _buildAccountButton(
                context,
                theme,
                'Аккаунт 2',
                'xbox.makcim@bk.ru',
                'ak2DJdvV02aepi1OYLT5',
                CupertinoIcons.person_alt,
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                onPressed: () => _showAddAccountDialog(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, color: theme.colors.accentTextColor),
                    const SizedBox(width: 8),
                    Text(
                      'Добавить аккаунт',
                      style: TextStyle(color: theme.colors.accentTextColor),
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
    TelegramThemeData theme,
    String name,
    String email,
    String password,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
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
              Icon(icon, size: 40, color: theme.colors.accentTextColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 20,
                color: theme.colors.subtitleTextColor,
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
