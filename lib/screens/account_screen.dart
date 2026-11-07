import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Text(
            'Your profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFEDE8FF),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF6546E8),
                size: 36,
              ),
            ),
            SizedBox(height: 13),
            Text(
              'Campus community',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text('Local preview', style: TextStyle(color: Color(0xFF727C94))),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'This first version keeps report data on this device while we build the main app experience. Accounts and staff roles will be added in a later step.',
        style: TextStyle(color: Color(0xFF727C94), height: 1.5),
      ),
    ],
  );
}
