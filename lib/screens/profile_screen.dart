import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Provider.of to get the AuthProvider instance
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Get the user from the provider. It should not be null if we are on this screen.
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(
                user?.name ?? 'Not available',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(
                user?.email ?? 'Not available',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(), // Pushes the logout button to the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Call the logout method from our provider
                  authProvider.logout();
                  // The AuthWrapper will automatically handle navigating back to the login screen.
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
