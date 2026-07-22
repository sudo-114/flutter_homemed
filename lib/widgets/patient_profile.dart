import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';

String convertToSentenceCase(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final name = storage.read('name');
    final dob = storage.read('dob');
    final gender = convertToSentenceCase(storage.read('gender'));
    final phone = storage.read('phone');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'Personal info',
                            style: text.bodyLarge!.copyWith(fontWeight: .w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'Full Name', value: name),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Date of Birth', value: dob),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Gender', value: gender),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Phone Number', value: phone),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Card.filled(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingTile(
                      title: 'Notifications',
                      icon: Icons.notifications_outlined,
                      onTap: () => debugPrint('Notification'),
                    ),
                    const Divider(),
                    _SettingTile(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => debugPrint('Privacy'),
                    ),
                    const Divider(),
                    _SettingTile(
                      title: 'Help & Support',
                      icon: Icons.help_outline,
                      onTap: () => debugPrint('Help'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  supabase.auth.signOut();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  iconColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: .bold)),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingTile({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontWeight: .w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
