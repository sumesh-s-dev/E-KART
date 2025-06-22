import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            const Text('User Name'),
            const SizedBox(height: 8),
            const Text('user@email.com'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Call AuthProvider.logout
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
