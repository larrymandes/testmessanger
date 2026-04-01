import 'package:flutter/material.dart';
import 'chat_list_screen.dart';

class AccountSelectScreen extends StatelessWidget {
  const AccountSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0e1621), Color(0xFF17212b)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.white70,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Secure Messenger',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'E2EE over Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 48),
                _buildAccountButton(
                  context,
                  'Аккаунт 1',
                  'makcim.evgenevich@bk.ru',
                  Icons.person,
                ),
                const SizedBox(height: 16),
                _buildAccountButton(
                  context,
                  'Аккаунт 2',
                  'xbox.makcim@bk.ru',
                  Icons.person_outline,
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () => _showAddAccountDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить аккаунт'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountButton(
    BuildContext context,
    String name,
    String email,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListScreen(
                email: email,
                password: 'YOUR_PASSWORD', // TODO: Хранить в secure storage
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    // TODO: Диалог добавления нового аккаунта
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить аккаунт'),
        content: const Text('Функция в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
